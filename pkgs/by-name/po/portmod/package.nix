{
  lib,
  bubblewrap,
  cacert,
  cargo,
  fetchFromGitLab,
  git,
  imagemagick,
  openmw,
  pkg-config,
  python3Packages,
  rustc,
  rustPlatform,
  tes3cmd,
  tr-patcher,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  zstd,
}:

# nixpkgs-update: no auto update
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "portmod";
  version = "2.9.2";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "portmod";
    repo = "Portmod";
    rev = "aa454a8ed943758a2f73efa82766d5f627bb3ccd"; # Release 2.9.2 has no upstream tag
    hash = "sha256-bnCyjHy3I5ETnfvkTGPEwVD5LtrvavU9AisFvQ942l8=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-KVs1LqwsfWaQb91mhlyKMAh0uDEDDAJHsUSLMIfJq18=";
  };

  build-system = with python3Packages; [
    setuptools
    setuptools-rust
    setuptools-scm
  ];

  nativeBuildInputs = [
    cargo
    pkg-config
    rustc
    rustPlatform.cargoSetupHook
  ];

  buildInputs = [
    zstd
  ];

  dependencies = with python3Packages; [
    chardet
    colorama
    fasteners
    gitpython
    packaging
    patool
    progressbar2
    python-sat
    redbaron
    requests
    restrictedpython
  ];

  pythonImportsCheck = [
    "portmod"
    "portmodlib.portmod"
  ];

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    versionCheckHook
    writableTmpDirAsHomeHook
    bubblewrap
    git
  ];

  preCheck = ''
    cp $out/${python3Packages.python.sitePackages}/portmodlib/portmod*.so portmodlib/
  '';

  # some test require network access
  disabledTests = [
    "test_masters_esp"
    "test_logging"
    "test_execute_network_permissions"
    "test_execute_permissions_bleed"
    "test_git"
    "test_sync"
    "test_manifest"
    "test_add_repo"
    "test_init_prefix_interactive"
    "test_scan_sources"
    "test_unpack"
  ];

  makeWrapperArgs = [
    "--set-default"
    "GIT_SSL_CAINFO"
    "${cacert}/etc/ssl/certs/ca-bundle.crt"
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      bubblewrap
      git
      python3Packages.virtualenv
      tr-patcher
      tes3cmd
      imagemagick
      openmw
    ])
  ];

  postInstall = ''
    rm $out/bin/portmod-gui
  '';

  meta = {
    description = "Mod manager for openMW based on portage";
    homepage = "https://gitlab.com/portmod/portmod";
    changelog = "https://gitlab.com/portmod/portmod/-/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ marius851000 ];
    platforms = lib.platforms.linux;
    mainProgram = "portmod";
  };
})
