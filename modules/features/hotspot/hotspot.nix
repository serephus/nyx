{
  den.aspects.hotspot =
    let
      # Physical WiFi radio. Client mode (wpa_supplicant) keeps using it, so the
      # AP is put on a separate virtual interface created on top of it.
      radio = "wlp0s20f3";
      apInterface = "wlan-ap0";

      # The AP is a WWAN fallback: it only runs while the WiFi client is down,
      # so there is no client channel to mirror. Keep it on 2.4 GHz; this card's
      # self-managed (LAR) regulatory domain currently marks 5 GHz as "no IR",
      # which hostapd cannot beacon on.
      fallbackBand = "2g";
      fallbackChannel = 11;

      # Policy timings (seconds).
      pollEvery = 5;   # main loop interval
      debounce = 25;   # wait after a disconnect before bringing the AP up
      scanEvery = 60;  # how often to look for configured SSIDs
      wifiGrace = 300; # keep the AP down this long trying to connect
      wifiRetry = 600; # then give the AP a turn before scanning again

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

          # `iw` is used by the hotspot policy to check the link and scan.
          environment.systemPackages = [ pkgs.iw ];

          # Create the AP VIF as a *down* managed interface. It must not be
          # brought up until hostapd flips it to AP mode: iwlwifi only allows
          # `managed <= 1`, so a second active managed interface makes the
          # driver refuse to bring up wlp0s20f3. `hotspot-policy` owns the
          # interface lifetime and address.
          networking.wlanInterfaces = {
            ${radio}.device = radio;
            ${apInterface}.device = radio;
          };

          # Keep wpa_supplicant on the client interface only, and keep dhcpcd
          # off the AP interface.
          networking.wireless.interfaces = [ radio ];
          networking.dhcpcd.denyInterfaces = [ apInterface ];

          # `hotspot-policy` owns the AP lifecycle, so don't start hostapd at
          # boot, and don't let `nixos-rebuild switch` restart it behind the
          # policy's back while WiFi is connected.
          systemd.services.hostapd = {
            wantedBy = lib.mkForce [ ];
            restartIfChanged = false;
            # Give the AP its gateway address however hostapd is started
            # (`hotspot-policy`, a manual `systemctl start`, ...). dnsmasq will
            # not answer DHCP on wlan-ap0 until the interface has an address.
            postStart = ''
              ${pkgs.iproute2}/bin/ip addr replace ${apAddress}/24 dev ${apInterface}
            '';
          };

          services.hostapd = {
            enable = true;
            radios.${apInterface} = {
              # The AP only runs while the WiFi client is down, so there is no
              # client channel to follow; the fixed fallback is always used.
              band = fallbackBand;
              channel = fallbackChannel;
              wifi5.enable = false; # VHT is 5 GHz only
              # Stay at 20 MHz: mismatched widths can make the driver refuse to
              # start the AP alongside the client.
              wifi4.capabilities = [ "SHORT-GI-20" ];
              countryCode = "CN";

              networks.${apInterface} = {
                ssid = "nyx";
                authentication.saePasswords = [
                  { passwordFile = config.vaultix.secrets.hotspotWifiPassword.path; }
                ];
              };
            };
          };

          # The hotspot is a WWAN fallback:
          #
          #   WiFi associated          -> AP down
          #   WiFi down, WWAN up       -> AP up
          #   configured SSID visible  -> AP down (let WiFi connect)
          #   otherwise                -> AP down
          #
          # iwlwifi only allows AP+STA on one channel, so the AP has to be down
          # before the client can associate on another channel. That is why a
          # visible configured SSID also stops the AP. If it stays visible but
          # never connects, the AP gets a turn again after `wifiGrace` seconds.
          systemd.services.hotspot-policy = {
            description = "Run the hotspot only when WiFi is down and WWAN is up";
            after = [ "network.target" "wpa_supplicant-${radio}.service" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              Type = "simple";
              Restart = "always";
              RestartSec = 5;
              ExecStart = pkgs.writeShellScript "hotspot-policy" ''
                set -u

                radio=${radio}
                ap=${apInterface}
                ap_address=${apAddress}
                wpa_conf=/etc/wpa_supplicant/nixos.conf

                poll_every=${toString pollEvery}
                debounce=${toString debounce}
                scan_every=${toString scanEvery}
                wifi_grace=${toString wifiGrace}
                wifi_retry=${toString wifiRetry}

                log() {
                  ${pkgs.coreutils}/bin/echo "hotspot-policy: $*" >&2
                }

                stop_ap() {
                  if ${pkgs.systemd}/bin/systemctl is-active --quiet hostapd.service; then
                    ${pkgs.systemd}/bin/systemctl stop hostapd.service || true
                    log "stopped AP"
                  fi
                  ${pkgs.iproute2}/bin/ip addr del "$ap_address/24" dev "$ap" 2>/dev/null || true
                  ${pkgs.iproute2}/bin/ip link set "$ap" down 2>/dev/null || true
                }

                start_ap() {
                  if ${pkgs.systemd}/bin/systemctl is-active --quiet hostapd.service; then
                    return 0
                  fi
                  # hostapd flips the VIF to AP mode and brings it up; its unit
                  # then assigns the gateway address dnsmasq serves on.
                  ${pkgs.iproute2}/bin/ip link set "$ap" down 2>/dev/null || true
                  if ${pkgs.systemd}/bin/systemctl start hostapd.service; then
                    log "started AP (WWAN uplink, no WiFi)"
                  else
                    log "failed to start AP"
                  fi
                }

                wifi_connected() {
                  ${pkgs.iw}/bin/iw dev "$radio" link 2>/dev/null \
                    | ${pkgs.gnugrep}/bin/grep -q '^Connected to'
                }

                wwan_up() {
                  ${pkgs.iproute2}/bin/ip -4 addr show dev wwan0 2>/dev/null \
                    | ${pkgs.gnugrep}/bin/grep -q 'inet ' &&
                  ${pkgs.iproute2}/bin/ip route show default 2>/dev/null \
                    | ${pkgs.gnugrep}/bin/grep -q 'dev wwan0'
                }

                # 0: a configured SSID is visible
                # 1: none visible
                # 2: scan failed (keep the previous decision)
                known_visible() {
                  [ -r "$wpa_conf" ] || return 1

                  known=$(${pkgs.gnused}/bin/sed -n 's/^[[:space:]]*ssid="\(.*\)"$/\1/p' "$wpa_conf" \
                    | ${pkgs.coreutils}/bin/sort -u)
                  [ -n "$known" ] || return 1

                  # The client interface must be up for a scan, even while the
                  # AP is running and the client is not associated.
                  ${pkgs.iproute2}/bin/ip link set "$radio" up 2>/dev/null || true

                  scan=$(${pkgs.iw}/bin/iw dev "$radio" scan 2>/dev/null) || return 2

                  if ${pkgs.coreutils}/bin/printf '%s\n' "$scan" \
                       | ${pkgs.gnused}/bin/sed -n 's/^[[:space:]]*SSID: //p' \
                       | ${pkgs.gnugrep}/bin/grep -Fxq -f <(${pkgs.coreutils}/bin/printf '%s\n' "$known"); then
                    return 0
                  fi
                  return 1
                }

                down_since=0
                visible=0
                visible_since=0
                next_scan=0

                while :; do
                  now=$(${pkgs.coreutils}/bin/date +%s)

                  if wifi_connected; then
                    stop_ap
                    down_since=0
                    visible=0
                    visible_since=0
                  else
                    [ "$down_since" -eq 0 ] && down_since=$now

                    if [ "$now" -ge "$next_scan" ]; then
                      known_visible
                      case $? in
                        0)
                          if [ "$visible" -eq 0 ]; then
                            visible_since=$now
                            log "a configured SSID is in range, yielding the radio to WiFi"
                          fi
                          visible=1
                          ;;
                        1)
                          visible=0
                          visible_since=0
                          ;;
                        *)
                          # Scan failed; keep the previous decision.
                          ;;
                      esac
                      next_scan=$((now + scan_every))
                    fi

                    if [ "$visible" -eq 1 ] && [ $((now - visible_since)) -ge "$wifi_grace" ]; then
                      log "could not connect to the visible network, giving the AP a turn"
                      visible=0
                      visible_since=0
                      next_scan=$((now + wifi_retry))
                    fi

                    if [ "$visible" -eq 1 ]; then
                      stop_ap
                    elif wwan_up && [ $((now - down_since)) -ge "$debounce" ]; then
                      start_ap
                    else
                      stop_ap
                    fi
                  fi

                  ${pkgs.coreutils}/bin/sleep "$poll_every"
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
