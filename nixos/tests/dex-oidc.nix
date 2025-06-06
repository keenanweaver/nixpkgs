{ lib, ... }:
{
  name = "dex-oidc";
  meta.maintainers = with lib.maintainers; [ Flakebi ];

  nodes.machine =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [ jq ];
      services.dex = {
        enable = true;
        settings = {
          issuer = "http://127.0.0.1:8080/dex";
          storage = {
            type = "postgres";
            config.host = "/var/run/postgresql";
          };
          web.http = "127.0.0.1:8080";
          oauth2.skipApprovalScreen = true;
          staticClients = [
            {
              id = "oidcclient";
              name = "Client";
              redirectURIs = [ "https://example.com/callback" ];
              secretFile = "/etc/dex/oidcclient";
            }
          ];
          connectors = [
            {
              type = "mockPassword";
              id = "mock";
              name = "Example";
              config = {
                username = "admin";
                password = "password";
              };
            }
          ];
        };
      };

      # This should not be set from nix but through other means to not leak the secret.
      environment.etc."dex/oidcclient" = {
        mode = "0400";
        user = "dex";
        text = "oidcclientsecret";
      };

      services.postgresql = {
        enable = true;
        ensureDatabases = [ "dex" ];
        ensureUsers = [
          {
            name = "dex";
            ensureDBOwnership = true;
          }
        ];
      };
    };

  testScript = ''
    with subtest("Web server gets ready"):
        machine.wait_for_unit("dex.service", timeout=120)
        # Wait until server accepts connections
        machine.wait_until_succeeds("curl -fs 'localhost:8080/dex/auth/mock?client_id=oidcclient&response_type=code&redirect_uri=https://example.com/callback&scope=openid'", timeout=120)

    with subtest("Login"):
        state = machine.succeed("curl -fs 'localhost:8080/dex/auth/mock?client_id=oidcclient&response_type=code&redirect_uri=https://example.com/callback&scope=openid' | sed -n 's/.*state=\\(.*\\)\">.*/\\1/p'").strip()
        print(f"Got state {state}")
        # Login request returns 303 with redirect_url that has code as query parameter:
        # https://example.com/callback?code=kibsamwdupuy2iwqnlbqei3u6&state=
        code = machine.succeed(f"curl -fs 'localhost:8080/dex/auth/mock/login?back=&state={state}' -d 'login=admin&password=password' -w '%{{redirect_url}}' | sed -n 's/.*code=\\(.*\\)&.*/\\1/p'")
        print(f"Got approval code {code}")
        bearer = machine.succeed(f"curl -fs localhost:8080/dex/token -u oidcclient:oidcclientsecret -d 'grant_type=authorization_code&redirect_uri=https://example.com/callback&code={code}' | jq .access_token -r").strip()
        print(f"Got access token {bearer}")

    with subtest("Get userinfo"):
        assert '"sub"' in machine.succeed(
            f"curl -fs localhost:8080/dex/userinfo --oauth2-bearer {bearer}"
        )
  '';
}
