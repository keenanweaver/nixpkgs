{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "depotdownloader";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "SteamRE";
    repo = "DepotDownloader";
    rev = "DepotDownloader_${version}";
    hash = "sha256-zduNWIQi+ItNSh9RfRfY0giIw/tMQIMRh9woUzQ5pJw=";
  };

  postPatch = ''
    rm global.json
    substituteInPlace DepotDownloader/DepotDownloader.csproj \
      --replace-fail '<TargetFramework>net9.0</' '<TargetFramework>net10.0</'
  '';

  projectFile = "DepotDownloader.sln";
  nugetDeps = ./deps.json;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Steam depot downloader utilizing the SteamKit2 library";
    homepage = "https://github.com/SteamRE/DepotDownloader";
    changelog = "https://github.com/SteamRE/DepotDownloader/releases/tag/DepotDownloader_${version}";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.babbaj ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    mainProgram = "DepotDownloader";
  };
}
