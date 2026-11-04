{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gcc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pvsneslib";
  version = "4.6.0";

  src = fetchFromGitHub {
    owner = "alekmaul";
    repo = "pvsneslib";
    tag = finalAttrs.version;
    hash = "sha256-e5R0/48kzaGCi8umgk4szILp1HG3IISKRf3kmmpc7vc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    gcc
    cmake
  ];

  dontConfigure = true;

  hardeningDisable = [ "format" ];

  # nixpkgs has no static libc by default
  postPatch = ''
    substituteInPlace tools/*/Makefile --replace-quiet '-static' ""
    substituteInPlace tools/snesbrr/makeinclude \
      --replace-fail '-static -static-libgcc -static-libstdc++ ' ""
  '';

  preBuild = ''
    export PVSNESLIB_HOME=$(pwd)
  '';

  installPhase = ''
    runHook preInstall
    cp -r . $out
    runHook postInstall
  '';

  meta = {
    description = "Free and open source development kit for the Nintendo SNES";
    homepage = "https://github.com/alekmaul/pvsneslib";
    changelog = "https://github.com/alekmaul/pvsneslib/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ soyouzpanda ];
    mainProgram = "pvsneslib";
    platforms = lib.platforms.all;
  };
})
