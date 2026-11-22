{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  discord-rpc,
  fluidsynth,
  libebur128,
  libsndfile,
  libspng,
  libxmp,
  miniz,
  nix-update-script,
  openal,
  pkg-config,
  python3,
  sdl3,
  versionCheckHook,
  yyjson,
  withDiscordRpc ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "woof-doom";
  version = "16.0.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "fabiangreffrath";
    repo = "woof";
    tag = "woof_${finalAttrs.version}";
    hash = "sha256-YiMLaAfMmLBLG5Zhl7hAhHVSWpUFUqH/CR4G3jwCFHk=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    python3
  ];

  buildInputs = [
    fluidsynth
    libebur128
    libsndfile
    libspng
    libxmp
    miniz
    openal
    sdl3
    yyjson
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ alsa-lib ]
  ++ lib.optionals withDiscordRpc [ discord-rpc ];

  cmakeFlags = [
    (lib.cmakeBool "WITH_DISCORD_RPC" withDiscordRpc)
    (lib.cmakeBool "WITH_FLUIDSYNTH" true)
    (lib.cmakeBool "WITH_SNDFILE" true)
    (lib.cmakeBool "WITH_XMP" true)
  ];

  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "woof_(.*)"
    ];
  };

  meta = {
    description = "Doom source port based on Boom/MBF";
    homepage = "https://fabiangreffrath.github.io/woof/";
    changelog = "https://github.com/fabiangreffrath/woof/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ keenanweaver ];
    platforms = lib.platforms.unix;
    mainProgram = "woof";
  };
})
