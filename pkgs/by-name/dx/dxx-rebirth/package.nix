{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  boost,
  libGL,
  libGLU,
  libpng,
  physfs,
  pkg-config,
  scons,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dxx-rebirth";
  version = "0.60.0-beta2-unstable-2026-11-15";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "dxx-rebirth";
    repo = "dxx-rebirth";
    rev = "fda30d3aa27e36ce6d72465d8dcf78dd44b64c26";
    hash = "sha256-v3IKVSTZmABmCxn1iUj0mwMEOj6djf15LDSuZ3Rcwqk=";
  };

  nativeBuildInputs = [
    pkg-config
    scons
  ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    libGL
    libGLU
    libpng
    physfs
  ];

  env = lib.optionalAttrs stdenv.cc.isGNU { NIX_CFLAGS_COMPILE = "-ffat-lto-objects"; };

  doCheck = true;
  checkInputs = [ boost ];

  postInstall = ''
    install -Dm644 ${finalAttrs.passthru.music} $out/share/games/dxx-rebirth/${finalAttrs.passthru.music.name}
    install -Dm644 -t $out/share/doc/dxx-rebirth *.txt
  '';

  checkTarget = "check";

  enableParallelBuilding = true;

  sconsFlags = [
    "sdl2=1"
    "register_runtime_test_link_targets=${lib.boolToString finalAttrs.finalPackage.doCheck}"
  ];

  passthru = {
    music = fetchurl {
      url = "https://www.dxx-rebirth.com/download/dxx/res/d2xr-sc55-music.dxa";
      hash = "sha256-rOFSGCxwuaeub5Eb3bwjlWYiCih6tUGcqyYNWvc5vxY=";
    };
    updateScript = unstableGitUpdater {
      # The latest tag is too old to be found by deepening a shallow clone
      shallowClone = false;
    };
  };

  meta = {
    description = "Source port of the Descent 1 and 2 engines";
    homepage = "https://www.dxx-rebirth.com/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = lib.platforms.linux;
  };
})
