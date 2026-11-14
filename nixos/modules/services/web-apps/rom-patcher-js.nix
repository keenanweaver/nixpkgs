{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.rom-patcher-js;
  webroot = "${cfg.package}/share/rom-patcher-js";
in
{
  options.services.rom-patcher-js = {
    enable = lib.mkEnableOption "the web version of Rom Patcher JS, a ROM patcher that runs in the browser";
    package = lib.mkPackageOption pkgs "rom-patcher-js" { };

    caddy = {
      enable = lib.mkEnableOption "a virtual host to serve Rom Patcher JS through Caddy";

      virtualHost = lib.mkOption {
        default = { };
        description = "Extra configuration for the Caddy virtual host of Rom Patcher JS.";

        example = lib.literalExpression ''
          {
            serverAliases = [ "patcher.''${config.networking.domain}" ];
          }
        '';

        type = lib.types.submodule (
          import ../web-servers/caddy/vhost-options.nix { cfg = config.services.caddy; }
        );
      };
    };

    domain = lib.mkOption {
      description = "Domain to use for the virtual host.";
      example = "patcher.example.org";
      type = lib.types.str;
    };

    nginx = {
      enable = lib.mkEnableOption "a virtual host to serve Rom Patcher JS through nginx";

      virtualHost = lib.mkOption {
        default = { };
        description = "Extra configuration for the nginx virtual host of Rom Patcher JS.";

        example = lib.literalExpression ''
          {
            enableACME = true;
            forceSSL = true;
          }
        '';

        type = lib.types.submodule (import ../web-servers/nginx/vhost-options.nix { inherit config lib; });
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = lib.mkIf cfg.caddy.enable {
      enable = lib.mkDefault true;

      virtualHosts.${cfg.domain} = lib.mkMerge [
        cfg.caddy.virtualHost
        {
          extraConfig = ''
            root * ${webroot}
            file_server
          '';

          hostName = lib.mkForce cfg.domain;
        }
      ];
    };

    services.nginx = lib.mkIf cfg.nginx.enable {
      enable = lib.mkDefault true;

      virtualHosts.${cfg.domain} = lib.mkMerge [
        cfg.nginx.virtualHost
        { root = lib.mkForce webroot; }
      ];
    };
  };

  meta = {
    doc = ./rom-patcher-js.md;
    maintainers = with lib.maintainers; [ keenanweaver ];
  };
}
