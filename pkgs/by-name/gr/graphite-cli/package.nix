{
  lib,
  buildNpmPackage,
  fetchurl,
  git,
  installShellFiles,
}:

buildNpmPackage rec {
  pname = "graphite-cli";
  version = "1.6.4";

  src = fetchurl {
    url = "https://registry.npmjs.org/@withgraphite/graphite-cli/-/graphite-cli-${version}.tgz";
    hash = "sha256-NxqqYghE9QNbO8VdBH4MsUomeRUvYNRijQMqrlE7/II=";
  };

  npmDepsHash = "sha256-LDSn5lIEHRyYyicP6b7/CTs5VivzcspeCUQzR+BqrS0=";

  postPatch = ''
    ln -s ${./package-lock.json} package-lock.json
  '';

  nativeBuildInputs = [
    git
    installShellFiles
  ];

  dontNpmBuild = true;

  postInstall = ''
    installShellCompletion --cmd gt \
      --bash <($out/bin/gt completion) \
      --fish <(GT_PAGER= $out/bin/gt fish) \
      --zsh <(ZSH_NAME=zsh $out/bin/gt completion)
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    changelog = "https://graphite.dev/docs/cli-changelog";
    description = "CLI that makes creating stacked git changes fast & intuitive";
    downloadPage = "https://www.npmjs.com/package/@withgraphite/graphite-cli";
    homepage = "https://graphite.dev/docs/graphite-cli";
    license = lib.licenses.unfree; # no license specified
    mainProgram = "gt";
    maintainers = with lib.maintainers; [ joshheinrichs-shopify ];
  };
}
