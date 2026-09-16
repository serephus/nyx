{
  den.aspects.hotspot =
    let
      # Physical WiFi radio. Client mode (wpa_supplicant) keeps using it, so the
      # AP is put on a separate virtual interface created on top of it.
      radio = "wlp0s20f3";
      apInterface = "wlan-ap0";

      # Only used if hostapd is ever started while the client is down; normally
      # `hotspot-follow` keeps it stopped in that case and picks the real
      # channel from the connected client at every start.
      fallbackBand = "2g";
      fallbackChannel = 11;

      # When the client disconnects, keep the AP up on its last channel so
      # hotspot clients can keep using the wwan fallback. Caveat: a running AP
      # pins the radio to that channel, so the client may be unable to join a
      # network on a different channel until the AP is stopped. Leave `false`
      # if you switch WiFi often.
      keepApOnDisconnect = false;

      # Private subnet handed out to hotspot clients.
      hotspotSubnet = "10.42.0";
      apAddress = "${hotspotSubnet}.1";
    in
    {
      nixos =
        {
          pkgs,
          lib,
          config,
          ...
        }:
        {
          vaultix.secrets.hotspotWifiPassword.file = ./hotspot-wifi-password.age;

          # `iw` is handy for finding the client's current channel.
          environment.systemPackages = [ pkgs.iw ];

          # Create the AP VIF as a *down* managed interface. It must not be
          # brought up until hostapd flips it to AP mode: iwlwifi only allows
          # `managed <= 1`, so a second active managed interface makes the
          # driver refuse to bring up wlp0s20f3. `hotspot-follow` owns the
          # interface lifetime and address.
          networking.wlanInterfaces = {
            ${radio}.device = radio;
            ${apInterface}.device = radio;
          };

          # Keep wpa_supplicant on the client interface only, and keep dhcpcd
          # off the AP interface.
          networking.wireless.interfaces = [ radio ];
          networking.dhcpcd.denyInterfaces = [ apInterface ];

          # `hotspot-follow` owns the AP lifecycle, so don't start hostapd at
          # boot: doing so on a stale channel could stop the client from joining
          # a network on a different one.
          systemd.services.hostapd.wantedBy = lib.mkForce [ ];

          services.hostapd = {
            enable = true;
            radios.${apInterface} = {
              # Fallback only; overwritten below from the client's channel.
              band = fallbackBand;
              channel = fallbackChannel;
              wifi5.enable = false; # VHT is 5 GHz only
              # Stay at 20 MHz: mismatched widths can make the driver refuse to
              # start the AP alongside the client.
              wifi4.capabilities = [ "SHORT-GI-20" ];
              countryCode = "CN";

              # Run at every hostapd start, after the radio's own settings, so
              # the appended hw_mode/channel win (hostapd takes the last value).
              dynamicConfigScripts."50-follow-client-channel" =
                pkgs.writeShellScript "hostapd-follow-client-channel" ''
                  set -eu
                  HOSTAPD_CONFIG=$1

                  link=$(${pkgs.iw}/bin/iw dev ${radio} link 2>/dev/null || true)
                  freq=$(printf '%s\n' "$link" \
                    | ${pkgs.gawk}/bin/awk '/freq:/ { print $2; exit }' \
                    | ${pkgs.coreutils}/bin/cut -d. -f1)

                  if [ -z "''${freq:-}" ]; then
                    exit 0
                  fi

                  if [ "$freq" -ge 5000 ]; then
                    hw_mode=a
                    channel=$(( (freq - 5000) / 5 ))
                  else
                    hw_mode=g
                    channel=$(( (freq - 2407) / 5 ))
                  fi

                  printf '\n# Added by hotspot: mirror the associated client channel.\nhw_mode=%s\nchannel=%s\n' \
                    "$hw_mode" "$channel" >> "$HOSTAPD_CONFIG"
                '';

              networks.${apInterface} = {
                ssid = "nyx";
                authentication.saePasswords = [
                  { passwordFile = config.vaultix.secrets.hotspotWifiPassword.path; }
                ];
              };
            };
          };

          # Keep the AP in sync with the WiFi client: (re)start it on the
          # client's channel when connected, and stop it when disconnected so
          # the radio is free to join a network on a different channel. Driven
          # by `iw event`, so there's no polling delay.
          systemd.services.hotspot-follow = {
            description = "Keep the hotspot AP on the WiFi client's channel";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              Type = "simple";
              Restart = "always";
              RestartSec = 5;
              ExecStart = pkgs.writeShellScript "hotspot-follow" ''
                set -u

                apply() {
                  link=$(${pkgs.iw}/bin/iw dev ${radio} link 2>/dev/null || true)
                  if printf '%s' "$link" | ${pkgs.gnugrep}/bin/grep -q '^Connected to'; then
                    # hostapd flips the VIF to AP mode and brings it up; then give
                    # it the gateway address dnsmasq serves on.
                    ${pkgs.systemd}/bin/systemctl restart hostapd.service || true
                    ${pkgs.iproute2}/bin/ip addr replace ${apAddress}/24 dev ${apInterface}
                  else
                    ${
                      if keepApOnDisconnect then
                        "true"
                      else
                        "${pkgs.systemd}/bin/systemctl stop hostapd.service || true; "
                        + "${pkgs.iproute2}/bin/ip addr del ${apAddress}/24 dev ${apInterface} 2>/dev/null || true; "
                        + "${pkgs.iproute2}/bin/ip link set ${apInterface} down || true"
                    }
                  fi
                }

                # `iw event` only reports changes, so sync the current state once.
                apply

                # React to connect/disconnect/roam. Note "disconnected" also
                # contains "connected", so one pattern covers both.
                ${pkgs.iw}/bin/iw event | while IFS= read -r line; do
                  case "$line" in
                    *${radio}*)
                      case "$line" in
                        *connected*|*roamed*)
                          apply
                          ;;
                      esac
                      ;;
                  esac
                done
              '';
            };
          };

          # DHCP + DNS for hotspot clients.
          services.dnsmasq = {
            enable = true;
            # Don't rewrite the host's /etc/resolv.conf; only serve the AP.
            resolveLocalQueries = false;
            settings = {
              interface = apInterface;
              bind-dynamic = true;
              "dhcp-range" = [ "${hotspotSubnet}.10,${hotspotSubnet}.200,255.255.255.0,12h" ];
              "dhcp-option" = [
                "option:router,${apAddress}"
                "option:dns-server,${apAddress}"
              ];
              "domain-needed" = true;
              "bogus-priv" = true;
            };
          };

          # Share whatever upstream currently has connectivity. Leaving
          # externalInterface unset lets NAT apply to all outbound links
          # (ethernet, wwan, or a Wi-Fi client).
          networking.nat = {
            enable = true;
            internalInterfaces = [ apInterface ];
          };

          # DHCP/DNS need to reach the host from the internal AP interface.
          networking.firewall.trustedInterfaces = [ apInterface ];
        };
    };
}
