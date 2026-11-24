{
  den.aspects.mako = {
    provides.to-users.homeManager = {
      services.mako = {
        enable = true;
        settings = {
          default-timeout = 5000;
          max-timeout = 10000;
          width = 360;
          height = 150;
          margin = "10";
          padding = "10";
          border-size = 2;
          border-radius = 8;
          icons = true;
          max-icon-size = 48;
          anchor = "top-right";
          layer = "overlay";
          background-color = "#222222";
          text-color = "#dfdfdf";
          border-color = "#d65d0e";
          progress-color = "over #076678";
          font = "Noto Sans 11";
          format = "<b>%s</b>\n%b";
          sort = "-time";
          group-by = "app-name";
        };
      };
    };
  };
}
