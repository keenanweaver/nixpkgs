{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  _7zz,
  boost,
  libGL,
  libGLU,
  libpng,
  physfs,
  pkg-config,
  scons,
  unstableGitUpdater,
  withSC55Music ? true,
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
  ]
  ++ lib.optionals withSC55Music [ _7zz ];

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
    for game in d1x-rebirth d2x-rebirth; do
      install -Dm644 $game/$game.desktop \
        $out/share/applications/io.github.dxx_rebirth.dxx_rebirth.$game.desktop
      install -Dm644 -t $out/share/metainfo \
        $game/io.github.dxx_rebirth.dxx_rebirth.$game.metainfo.xml
      install -Dm644 -t $out/share/doc/$game $game/*.txt $game/*.ini
    done
    install -Dm644 contrib/packaging/linux/descent.svg \
      $out/share/icons/hicolor/scalable/apps/d1x-rebirth.svg
    install -Dm644 contrib/packaging/linux/descent2.svg \
      $out/share/icons/hicolor/scalable/apps/d2x-rebirth.svg
    install -Dm644 -t $out/share/doc/dxx-rebirth *.txt
  ''
  + lib.optionalString withSC55Music ''
    ln -s ${finalAttrs.passthru.sc55Music.d1x.part1} d1xr-sc55-music.7z.001
    ln -s ${finalAttrs.passthru.sc55Music.d1x.part2} d1xr-sc55-music.7z.002
    7zz x -o$out/share/games/d1x-rebirth d1xr-sc55-music.7z.001
    install -Dm644 ${finalAttrs.passthru.sc55Music.d2x} $out/share/games/d2x-rebirth/d2xr-sc55-music.dxa
  '';

  checkTarget = "check";

  enableParallelBuilding = true;

  sconsFlags = [
    "sdl2=1"
    "register_runtime_test_link_targets=${lib.boolToString finalAttrs.finalPackage.doCheck}"
  ];

  passthru = {
    sc55Music = {
      d1x = {
        part1 = fetchurl {
          url = "https://raw.githubusercontent.com/pudlez/dxx-addons/8a624db1abdc8a87bd63719065e668e4be809628/d1xr-sc55-music/d1xr-sc55-music.7z.001";
          hash = "sha256-34lpSx3FoGzz/B66VtHfySibfPVai700OTa87fBClRs=";
        };
        part2 = fetchurl {
          url = "https://raw.githubusercontent.com/pudlez/dxx-addons/8a624db1abdc8a87bd63719065e668e4be809628/d1xr-sc55-music/d1xr-sc55-music.7z.002";
          hash = "sha256-9K8ptuCJCLXh4bMP2jWFF6Dl8ksczZstezJ0y+vXEdM=";
        };
      };
      d2x = fetchurl {
        url = "https://raw.githubusercontent.com/pudlez/dxx-addons/8a624db1abdc8a87bd63719065e668e4be809628/d2xr-sc55-music/d2xr-sc55-music.dxa";
        hash = "sha256-rOFSGCxwuaeub5Eb3bwjlWYiCih6tUGcqyYNWvc5vxY=";
      };
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
