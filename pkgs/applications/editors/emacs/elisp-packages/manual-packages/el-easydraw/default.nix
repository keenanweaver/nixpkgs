{ lib
, melpaBuild
, fetchFromGitHub
, writeText
, writeScript
, gzip
}:

let
  rev = "a6c849619abcdd80dc82ec5417195414ad438fa3";
in
melpaBuild {
  pname = "edraw";
  version = "20240701.444";

  src = fetchFromGitHub {
    owner = "misohena";
    repo = "el-easydraw";
    inherit rev;
    hash = "sha256-CbcI1mmghc3HObg80bjScVDcJ1DHx9aX1WP2HlhAshs=";
  };

  commit = rev;

  packageRequires = [ gzip ];

  recipe = writeText "recipe" ''
    (edraw
      :repo "misohena/el-easydraw"
      :fetcher github
      :files
      ("*.el"
       "msg"))
  '';

  passthru.updateScript = writeScript "update.sh" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p common-updater-scripts coreutils git gnused
    set -eu -o pipefail
    tmpdir="$(mktemp -d)"
    git clone --depth=1 https://github.com/misohena/el-easydraw.git "$tmpdir"
    pushd "$tmpdir"
    commit=$(git show -s --pretty='format:%H')
    # Based on: https://github.com/melpa/melpa/blob/2d8716906a0c9e18d6c979d8450bf1d15dd785eb/package-build/package-build.el#L523-L533
    version=$(TZ=UTC git show -s --pretty='format:%cd' --date='format-local:%Y%m%d.%H%M' | sed 's|\.0*|.|')
    popd
    update-source-version emacsPackages.el-easydraw $version --rev="$commit"
  '';

  meta = {
    homepage = "https://github.com/misohena/el-easydraw";
    description = "Embedded drawing tool for Emacs";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ brahyerr ];
    platforms = lib.platforms.all;
  };
}
