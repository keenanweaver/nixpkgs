{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "nak";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "fiatjaf";
    repo = "nak";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0x9fMcB8voV9MFX+XxkXgrb2WdnQONPyLQgG1bJwu2Q=";
  };

  vendorHash = "sha256-5W7uqHT9iP5NbE3EFiFBSdjsINIWv5lIkz3K6yMcgrM=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  # Integration tests fail (requires connection to relays)
  doCheck = false;

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line tool for Nostr things";
    homepage = "https://github.com/fiatjaf/nak";
    changelog = "https://github.com/fiatjaf/nak/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ nartsiss ];
    mainProgram = "nak";
  };
})
