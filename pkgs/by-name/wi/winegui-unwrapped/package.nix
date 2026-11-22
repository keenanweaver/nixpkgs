{
  lib,
  stdenv,
  fetchFromGitHub,
  cabextract,
  cmake,
  ctestCheckHook,
  gnutar,
  gtest,
  gtkmm4,
  ninja,
  nix-update-script,
  nlohmann_json,
  p7zip,
  pkg-config,
  python3,
  unzip,
  util-linux,
  versionCheckHook,
  wget,
  wrapGAppsHook4,
  xz,
  zenity,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "winegui-unwrapped";
  version = "4.5.2";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "winegui";
    repo = "WineGUI";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3N8/M9XSzHqjjHHkd58A6ZO4Nd3CAvL/XELhxU0VqsY=";
  };

  postPatch = ''
    substituteInPlace misc/winegui.desktop \
      --replace-fail 'Exec=/usr/bin/winegui' 'Exec=winegui'
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtkmm4
    nlohmann_json
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CUSTOM_PROJECT_VERSION" finalAttrs.version)
    # compared against the literal "OFF"
    (lib.cmakeOptionType "bool" "CHECK_FOR_UPDATE" "OFF")
    (lib.cmakeBool "GSETTINGS_COMPILE" true)
  ];

  postInstall = ''
    rm -r $out/share/winegui/apps
    install -Dm644 ../misc/org.melroy.winegui.metainfo.xml -t $out/share/metainfo
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${
        lib.makeBinPath [
          cabextract
          gnutar
          p7zip
          python3
          unzip
          util-linux
          wget
          xz
          zenity
        ]
      }
    )
  '';

  passthru = {
    # UNITTEST=ON builds only the tests
    tests.withTests = finalAttrs.finalPackage.overrideAttrs (previousAttrs: {
      cmakeFlags = previousAttrs.cmakeFlags ++ [
        (lib.cmakeBool "UNITTEST" true)
        (lib.cmakeBool "INSTALL_GTEST" false)
        (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_GOOGLETEST" "${gtest.src}")
      ];
      ctestFlags = [
        "--test-dir"
        "tst"
        "--no-tests=error"
      ];
      doCheck = true;
      doInstallCheck = false;
      dontUseNinjaCheck = true;
      env.GTEST_FILTER = "-${
        lib.concatStringsSep ":" [
          "HelperTest.DetectsRunningWineApplicationButIgnoresBackgroundServices"
          "HelperTest.SystemRunnerCannotBeReplacedByBottlePathOverride"
        ]
      }";
      installPhase = ''
        runHook preInstall
        mkdir $out
        runHook postInstall
      '';
      nativeCheckInputs = [
        ctestCheckHook
        util-linux
      ];
      postInstall = "";
    });
    updateScript = nix-update-script { };
  };

  meta = {
    description = "User-friendly Wine graphical interface";
    homepage = "https://gitlab.melroy.org/melroy/winegui";
    changelog = "https://github.com/winegui/WineGUI/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ keenanweaver ];
    platforms = lib.platforms.linux;
    mainProgram = "winegui";
  };
})
