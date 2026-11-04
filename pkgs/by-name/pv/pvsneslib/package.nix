{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  doxygen,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pvsneslib";
  version = "4.6.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "alekmaul";
    repo = "pvsneslib";
    tag = finalAttrs.version;
    hash = "sha256-e5R0/48kzaGCi8umgk4szILp1HG3IISKRf3kmmpc7vc=";
    fetchSubmodules = true;
  };

  # nixpkgs has no static libc by default
  postPatch = ''
    substituteInPlace tools/*/Makefile --replace-quiet '-static' ""
    substituteInPlace tools/snesbrr/makeinclude \
      --replace-fail '-static -static-libgcc -static-libstdc++ ' ""
  '';

  nativeBuildInputs = [
    cmake
    doxygen
  ];

  dontUseCmakeConfigure = true;

  hardeningDisable = [ "format" ];

  preBuild = ''
    export PVSNESLIB_HOME=$(pwd)
  '';

  installPhase = ''
    runHook preInstall
    cp -r . $out
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Free and open source development kit for the Nintendo SNES";
    homepage = "https://github.com/alekmaul/pvsneslib";
    changelog = "https://github.com/alekmaul/pvsneslib/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ soyouzpanda ];
    platforms = lib.platforms.all;
  };
})
