{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  IOKit,
  CoreFoundation,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "nushell_plugin_net";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "fennewald";
    repo = "nu_plugin_net";
    rev = "refs/tags/${version}";
    hash = "sha256-Cop2gI5xhhWhw5Cyb4CABSzqs2bxDreohOzgGh/wPXg=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-8IlCUI0HOsr06vsSv0WBxfoaEe1Dz21tZdWZ6jrNkaw=";

  nativeBuildInputs = [ rustPlatform.bindgenHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    CoreFoundation
    IOKit
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Nushell plugin to list system network interfaces";
    homepage = "https://github.com/fennewald/nu_plugin_net";
    license = licenses.mit;
    maintainers = with maintainers; [ happysalada ];
    mainProgram = "nu_plugin_net";
  };
}
