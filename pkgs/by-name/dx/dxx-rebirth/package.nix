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
  makeBinaryWrapper,
  physfs,
  pkg-config,
  scons,
  sdl_gamecontrollerdb,
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
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ makeBinaryWrapper ]
  ++ lib.optionals withSC55Music [ _7zz ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    libpng
    physfs
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libGL
    libGLU
  ];

  env = lib.optionalAttrs stdenv.cc.isGNU { NIX_CFLAGS_COMPILE = "-ffat-lto-objects"; };

  doCheck = true;
  checkInputs = [ boost ];

  postInstall =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      for game in d1x-rebirth d2x-rebirth; do
        install -Dm644 $game/$game.desktop \
          $out/share/applications/io.github.dxx_rebirth.dxx_rebirth.$game.desktop
        install -Dm644 -t $out/share/metainfo \
          $game/io.github.dxx_rebirth.dxx_rebirth.$game.metainfo.xml
      done
      install -Dm644 contrib/packaging/linux/descent.svg \
        $out/share/icons/hicolor/scalable/apps/d1x-rebirth.svg
      install -Dm644 contrib/packaging/linux/descent2.svg \
        $out/share/icons/hicolor/scalable/apps/d2x-rebirth.svg
      d1xData=$out/share/games/d1x-rebirth
      d2xData=$out/share/games/d2x-rebirth
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications
      cp -R build/D1X-Rebirth.app build/D2X-Rebirth.app $out/Applications
      makeWrapper $out/Applications/D1X-Rebirth.app/Contents/MacOS/d1x-rebirth $out/bin/d1x-rebirth
      makeWrapper $out/Applications/D2X-Rebirth.app/Contents/MacOS/d2x-rebirth $out/bin/d2x-rebirth
      d1xData=$out/Applications/D1X-Rebirth.app/Contents/Resources
      d2xData=$out/Applications/D2X-Rebirth.app/Contents/Resources
    ''
    + ''
      for game in d1x-rebirth d2x-rebirth; do
        install -Dm644 -t $out/share/doc/$game $game/*.txt $game/*.ini
      done
      install -Dm644 -t $out/share/doc/dxx-rebirth *.txt
      mkdir -p $d1xData $d2xData
      ln -s ${sdl_gamecontrollerdb}/share/gamecontrollerdb.txt $d1xData/
      ln -s ${sdl_gamecontrollerdb}/share/gamecontrollerdb.txt $d2xData/
    ''
    + lib.optionalString withSC55Music ''
      ln -s ${finalAttrs.passthru.sc55Music.d1x.part1} d1xr-sc55-music.7z.001
      ln -s ${finalAttrs.passthru.sc55Music.d1x.part2} d1xr-sc55-music.7z.002
      7zz x -o$d1xData d1xr-sc55-music.7z.001
      install -Dm644 ${finalAttrs.passthru.sc55Music.d2x} $d2xData/d2xr-sc55-music.dxa
    '';

  checkTarget = "check";

  enableParallelBuilding = true;

  installTargets =
    if stdenv.hostPlatform.isDarwin then
      [
        "build/D1X-Rebirth.app"
        "build/D2X-Rebirth.app"
      ]
    else
      [ "install" ];

  sconsFlags = [
    "sdl2=1"
    "register_runtime_test_link_targets=${lib.boolToString finalAttrs.finalPackage.doCheck}"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ "macos_add_frameworks=0" ];

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
    license = lib.licenses.mkLicense {
      free = false;
      fullName = "DXX-Rebirth License";
      shortName = "dxx-rebirth";
      url = "https://github.com/dxx-rebirth/dxx-rebirth/blob/master/COPYING.txt";
    };
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
