{ self, ... }:
{
  flake.modules.homeManager.qutebrowser = {
    programs.qutebrowser = {
      enable = true;
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
            directory = "~/res/downloads";
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
      # keyBindings = {
      #   normal = {
      #     "<Ctrl-l>" = "config-cycle content.proxy socks5://localhost:1080 none";
      #     "zz" = "hint links spawn yt-dlp -P ~/res/downloads --proxy socks5://localhost:1080 {hint-url}";
      #   };
      # };
    };
  };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.qutebrowser
    ];
  };
}
