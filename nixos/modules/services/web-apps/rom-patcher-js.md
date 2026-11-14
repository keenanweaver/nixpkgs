# Rom Patcher JS {#module-services-rom-patcher-js}

[Rom Patcher JS](https://github.com/marcrobledo/RomPatcher.js) is a ROM patcher that runs entirely in the browser.
The module serves its static web app through an nginx or Caddy virtual host.
It doesn't open any firewall ports.

## HTTPS with nginx {#module-services-rom-patcher-js-nginx}

```nix
{
  services.rom-patcher-js = {
    enable = true;
    domain = "patcher.example.org";
    nginx = {
      enable = true;
      virtualHost = {
        enableACME = true;
        forceSSL = true;
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@example.org";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
```

The certificate is obtained through the HTTP-01 challenge, so the domain must resolve to the host and port 80 must be reachable.
To use a certificate the host already manages, set {option}`services.rom-patcher-js.nginx.virtualHost.useACMEHost` instead of `enableACME`.

## HTTPS with Caddy {#module-services-rom-patcher-js-caddy}

```nix
{
  services.rom-patcher-js = {
    enable = true;
    domain = "patcher.example.org";
    caddy.enable = true;
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
```

Caddy obtains the certificate and redirects HTTP to HTTPS on its own.
For hosts without public DNS, set {option}`services.rom-patcher-js.caddy.virtualHost.extraConfig` to `tls internal` to use Caddy's local CA.

## Custom patcher page {#module-services-rom-patcher-js-embed}

Instead of the full app, you can serve your own page that offers your patches, as described in [Embedding Rom Patcher JS](https://github.com/marcrobledo/RomPatcher.js/wiki/Embedding-Rom-Patcher-JS).
Put the page and the patches in a directory, for example {file}`./patcher` with {file}`index.html` and {file}`my_patches.zip`.
The page loads {file}`./rom-patcher-js/RomPatcher.webapp.js` as in upstream's `index_template.html`, and the `rom-patcher-js/` folder is served from the package.

With nginx:

```nix
{
  services.rom-patcher-js = {
    enable = true;
    domain = "patcher.example.org";
    nginx = {
      enable = true;
      virtualHost.locations = {
        "/".root = ./patcher;
        "/rom-patcher-js/" = { };
      };
    };
  };
}
```

With Caddy:

```nix
{
  services.rom-patcher-js = {
    enable = true;
    domain = "patcher.example.org";
    caddy = {
      enable = true;
      virtualHost.extraConfig = ''
        @site not path /rom-patcher-js/*
        root @site ${./patcher}
      '';
    };
  };
}
```

The HTTPS settings above apply unchanged.

## Plain HTTP {#module-services-rom-patcher-js-http}

Upstream's app redirects every `http:` visit to `https:`.
The package disables that, so the app also works over plain HTTP, for example on a LAN or behind a proxy that terminates TLS.
