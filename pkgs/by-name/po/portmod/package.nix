{
  lib,
  fetchFromGitLab,
  bubblewrap,
  cacert,
  cargo,
  git,
  imagemagick,
  installShellFiles,
  openmw,
  pkg-config,
  python3Packages,
  rustPlatform,
  rustc,
  tes3cmd,
  tr-patcher,
  unar,
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
    installShellFiles
    pkg-config
    python3Packages.argcomplete
    rustc
    rustPlatform.cargoSetupHook
  ];

  buildInputs = [
    zstd
  ];

  dependencies = with python3Packages; [
    argcomplete
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
      unar
    ])
  ];

  postInstall = ''
    rm $out/bin/portmod-gui

    installShellCompletion --cmd portmod \
      --bash <(register-python-argcomplete portmod --shell bash) \
      --fish <(register-python-argcomplete portmod --shell fish) \
      --zsh <(register-python-argcomplete portmod --shell zsh)
  '';

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
