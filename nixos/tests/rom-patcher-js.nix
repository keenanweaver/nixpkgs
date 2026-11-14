{ lib, pkgs, ... }:

let
  site = pkgs.linkFarm "rom-patcher-js-embed" {
    "index.html" = pkgs.writeText "index.html" ''
      <title>My patcher</title>
      <script src="./rom-patcher-js/RomPatcher.webapp.js"></script>
    '';

    "my_patches.zip" = pkgs.writeText "my_patches.zip" "patches";
  };
in
{
  name = "rom-patcher-js";

  nodes = {
    caddy = {
      services.caddy.globalConfig = "auto_https off";

      services.rom-patcher-js = {
        enable = true;
        caddy.enable = true;
        domain = "http://localhost";
      };
    };

    caddyEmbed = {
      services.caddy.globalConfig = "auto_https off";

      services.rom-patcher-js = {
        enable = true;

        caddy = {
          enable = true;

          virtualHost.extraConfig = ''
            @site not path /rom-patcher-js/*
            root @site ${site}
          '';
        };

        domain = "http://localhost";
      };
    };

    defaults.services.rom-patcher-js.enable = true;

    nginx.services.rom-patcher-js = {
      enable = true;
      domain = "localhost";
      nginx.enable = true;
    };

    nginxEmbed.services.rom-patcher-js = {
      enable = true;
      domain = "localhost";

      nginx = {
        enable = true;

        virtualHost.locations = {
          "/".root = site;
          "/rom-patcher-js/" = { };
        };
      };
    };
  };

  testScript = ''
    start_all()

    defaults.wait_for_unit("multi-user.target")
    defaults.fail("systemctl cat nginx.service caddy.service")

    for machine, unit in [(nginx, "nginx.service"), (caddy, "caddy.service")]:
        machine.wait_for_unit(unit)
        machine.wait_for_open_port(80)
        assert "<title>Rom Patcher JS</title>" in machine.succeed("curl --fail --silent http://localhost/")
        assert "RomPatcherWeb" in machine.succeed("curl --fail --silent http://localhost/rom-patcher-js/RomPatcher.webapp.js")
        assert "const FORCE_HTTPS = false;" in machine.succeed("curl --fail --silent http://localhost/webapp/webapp.js")
        machine.fail("curl --fail --silent http://localhost/package.json")

    for machine, unit in [(nginxEmbed, "nginx.service"), (caddyEmbed, "caddy.service")]:
        machine.wait_for_unit(unit)
        machine.wait_for_open_port(80)
        assert "<title>My patcher</title>" in machine.succeed("curl --fail --silent http://localhost/")
        assert "patches" in machine.succeed("curl --fail --silent http://localhost/my_patches.zip")
        assert "RomPatcherWeb" in machine.succeed("curl --fail --silent http://localhost/rom-patcher-js/RomPatcher.webapp.js")
        machine.succeed("curl --fail --silent --output /dev/null http://localhost/rom-patcher-js/RomPatcher.webworker.apply.js")
        machine.fail("curl --fail --silent http://localhost/webapp/webapp.js")
  '';

  meta.maintainers = with lib.maintainers; [ keenanweaver ];
}
