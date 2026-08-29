{
  den.aspects.qutebrowser = {
    nixos = {
      vaultix.secrets.tokenLeetcodeSecrets = {
        file = ./token-update-leetcode-secrets.age;
        mode = "0644";
      };
    };
    provides.to-users = { user, ... }: {
      nixos = {
        preservation.preserveAt."/persist" = {
          users."${user.userName}" = {
            directories = [ ".local/share/qutebrowser" ];
          };
        };
      };
      homeManager = { config, osConfig, ... }: {
        programs.qutebrowser = {
          enable = true;
          # with home manager, we won't be able to add quickmarks in qutebrowser
          quickmarks = {
            y = "https://youtube.com";
            g = "https://www.google.com";
            ddg = "https://duckduckgo.com";
            gh = "https://github.com";
            gl = "https://gitlab.com";
            blog = "https://sereph.us";
            gb = "https://godbolt.org";
            tr = "https://github.com/trending/rust?since=daily";
            ext = "https://ext.to";
            cron = "https://crontab.guru";
            "4c" = "https://4chan.org";
            ph = "https://pornhub.com";
            cf = "https://cloudflare.com";
            lc = "https://leetcode.com";
            lcr = "https://leetcode.com/problems/random-one-question/all";
            dw = "https://deepwiki.com";
            ds = "https://chat.deepseek.com";
            gc = "https://gitcode.com";
            cb = "https://codeberg.org";
          };
          searchEngines = {
            DEFAULT = "https://google.com/search?q={}";
            d = "https://duckduckgo.com/?q={}";
            y = "https://youtube.com/results?search_query={}";
            w = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
            aw = "https://wiki.archlinux.org/?search={}";
            nw = "https://wiki.nixos.org/wiki/{}";
            no = "https://search.nixos.org/options?channel=unstable&query={}";
            ho = "https://home-manager-options.extranix.com/?query={}";
            ns = "https://search.nüschtos.de/?query={}";
            g = "https://www.google.com/search?hl=en&q={}";
            r = "https://doc.rust-lang.org/stable/std/?search={}";
            c = "https://en.cppreference.com/w/cpp/keyword/{}";
            gh = "https://github.com/search/?q={}";
            rc = "https://crates.io/search/?q={}";
            rd = "https://docs.rs/releases/search?query={}";
          };
          settings = {
            tabs = {
              position = "bottom";
              show = "multiple";
            };
            zoom.default = "150%";
            fonts.default_size = "16pt";
            confirm_quit = [ "downloads" ];
            scrolling.smooth = true;
            downloads = {
              location = {
                suggestion = "filename";
                directory = "${config.home.homeDirectory}/res/downloads";
              };
              position = "bottom";
              remove_finished = 8000;
            };
            colors = {
              hints = {
                fg = "#EFF0EB";
                bg = "#1E1F29";
                match.fg = "#5AF78E";
              };
              webpage = {
                darkmode.enabled = true;
                preferred_color_scheme = "dark";
              };
            };
            content = {
              geolocation = false;
              headers.do_not_track = true;
              cookies.accept = "no-3rdparty";
              dns_prefetch = true;
              xss_auditing = true;

              blocking = {
                enabled = true;
                method = "both";
                adblock.lists = [
                  "https://easylist.to/easylist/easylist.txt"
                  "https://easylist.to/easylist/easyprivacy.txt"
                  "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt"
                  "https://easylist.to/easylist/fanboy-annoyance.txt"
                  "https://secure.fanboy.co.nz/fanboy-annoyance.txt"
                  "https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances.txt"
                  "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2020.txt"
                  "https://github.com/uBlockOrigin/uAssets/raw/master/filters/unbreak.txt"
                  "https://github.com/uBlockOrigin/uAssets/raw/master/filters/resource-abuse.txt"
                  "https://github.com/uBlockOrigin/uAssets/raw/master/filters/privacy.txt"
                  "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters.txt"
                ];
                hosts.lists = [
                  "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
                ];
              };
            };
          };
          extraConfig = ''
            # manually update leetcode cookies in github repo secrets is very
            # tedious, so I created this script to do it with a simple command
            # retrieve cookies with qutebrowser APIs prove to be a deadend as
            # of 2026/08/29, so we just read the cookies directly from disk
            import base64
            import os
            import sqlite3
            import requests
            # currently pynacl is bundled into qutebrowser
            from nacl.public import PublicKey, SealedBox
            from qutebrowser.api import cmdutils, message

            GITHUB_OWNER = "serephus"
            GITHUB_REPO = "blog"
            GITHUB_TOKEN_FILE = "${osConfig.vaultix.secrets.tokenLeetcodeSecrets.path}"
            LEETCODE_SESSION_SECRET = "LEETCODE_SESSION"
            CSRF_TOKEN_SECRET = "LEETCODE_CSRF_TOKEN"

            def _leetcode_cookie(name):
                cookie_db = os.path.expanduser("~/.local/share/qutebrowser/webengine/Cookies")

                if not os.path.exists(cookie_db):
                    return None

                try:
                    conn = sqlite3.connect(f"file:{cookie_db}?mode=ro", uri=True)
                except sqlite3.Error:
                    return None

                try:
                    cur = conn.cursor()
                    cur.execute(
                        """
                        SELECT value
                        FROM cookies
                        WHERE name = ? AND host_key LIKE ?
                        ORDER BY length(host_key) DESC, last_access_utc DESC
                        LIMIT 1
                        """,
                        (name, "%leetcode.com"),
                    )
                    row = cur.fetchone()
                    if row and row[0]:
                        return row[0]
                    return None
                finally:
                    conn.close()

            def _github_token():
                with open(GITHUB_TOKEN_FILE, "r", encoding="utf-8") as f:
                    return f.read().strip()

            def _github_public_key():
                response = requests.get(
                    f"https://api.github.com/repos/{GITHUB_OWNER}/{GITHUB_REPO}/actions/secrets/public-key",
                    headers={
                        "Accept": "application/vnd.github+json",
                        "Authorization": f"Bearer {_github_token()}",
                        "X-GitHub-Api-Version": "2022-11-28",
                    },
                    timeout=10,
                )
                response.raise_for_status()
                data = response.json()
                return data["key_id"], base64.b64decode(data["key"])

            def _encrypt_secret(value, public_key_bytes):
                sealed_box = SealedBox(PublicKey(public_key_bytes))
                return base64.b64encode(sealed_box.encrypt(value.encode())).decode()

            def _set_github_secret(secret_name, value):
                if not value:
                    message.error(f"{secret_name} not found")
                    return False

                key_id, public_key_bytes = _github_public_key()
                encrypted_value = _encrypt_secret(value, public_key_bytes)

                response = requests.put(
                    f"https://api.github.com/repos/{GITHUB_OWNER}/{GITHUB_REPO}/actions/secrets/{secret_name}",
                    headers={
                        "Accept": "application/vnd.github+json",
                        "Authorization": f"Bearer {_github_token()}",
                        "X-GitHub-Api-Version": "2022-11-28",
                    },
                    json={
                        "encrypted_value": encrypted_value,
                        "key_id": key_id,
                    },
                    timeout=10,
                )
                response.raise_for_status()
                return True

            @cmdutils.register(name="leetcode-secrets-to-github")
            def leetcode_secrets_to_github():
                session = _leetcode_cookie("LEETCODE_SESSION")
                csrf = _leetcode_cookie("csrftoken")

                ok_session = _set_github_secret(LEETCODE_SESSION_SECRET, session)
                ok_csrf = _set_github_secret(CSRF_TOKEN_SECRET, csrf)

                if ok_session and ok_csrf:
                    message.info("Updated GitHub repo secrets from LeetCode cookies")
          '';
        };
      };
    };
  };
}
