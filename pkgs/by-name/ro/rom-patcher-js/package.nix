{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
  nixosTests,
  runCommand,
}:

buildNpmPackage (finalAttrs: {
  pname = "rom-patcher-js";
  version = "3.2.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "marcrobledo";
    repo = "RomPatcher.js";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bIEvna+8Xfb+np8V3vFRPxtWrlNjEKd0CDp2ayoKnGM=";
  };

  # upstream doesn't ship a package-lock.json
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-GJzFbPUyfJonqxHxs46zTFqfu1gZvUV8fsC1d2AR21Q=";

  # test.js needs copyrighted ROMs
  doCheck = false;

  postInstall = ''
    mkdir -p $out/share/rom-patcher-js
    cp -r index.html legacy manifest.json rom-patcher-js webapp $out/share/rom-patcher-js
    substituteInPlace $out/share/rom-patcher-js/webapp/webapp.js \
      --replace-fail "const FORCE_HTTPS = true;" "const FORCE_HTTPS = false;"
    substituteInPlace $out/share/rom-patcher-js/legacy/js/RomPatcher.js \
      --replace-fail "const FORCE_HTTPS=true;" "const FORCE_HTTPS=false;"
  '';

  dontNpmBuild = true;

  passthru = {
    tests = {
      inherit (nixosTests) rom-patcher-js;
      roundtrip =
        runCommand "rom-patcher-js-roundtrip" { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
          ''
            head -c 65536 /dev/urandom > original.bin
            cp original.bin modified.bin
            printf 'nixpkgs' | dd of=modified.bin bs=1 seek=4096 conv=notrunc
            for format in aps bps ips ppf rup ups; do
              RomPatcher create original.bin modified.bin --format $format
              RomPatcher patch original.bin modified.$format
              cmp 'original (patched).bin' modified.bin
              rm 'original (patched).bin'
            done
            touch $out
          '';
    };
    updateScript = nix-update-script { extraArgs = [ "--generate-lockfile" ]; };
  };

  meta = {
    description = "ROM patcher supporting IPS, UPS, APS, BPS, RUP, PPF, EBP, BDF and xdelta";
    homepage = "https://www.marcrobledo.com/RomPatcher.js/";
    changelog = "https://github.com/marcrobledo/RomPatcher.js/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ keenanweaver ];
    mainProgram = "RomPatcher";
  };
})
