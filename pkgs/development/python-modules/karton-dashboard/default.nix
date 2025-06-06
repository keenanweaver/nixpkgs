{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  flask,
  karton-core,
  mistune,
  networkx,
  prometheus-client,
  pythonOlder,
}:

buildPythonPackage rec {
  pname = "karton-dashboard";
  version = "1.6.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "CERT-Polska";
    repo = "karton-dashboard";
    tag = "v${version}";
    hash = "sha256-VzBC7IATF8QBtTXMv4vmorAzBlImEsayjenQ2Uz5jIo=";
  };

  pythonRelaxDeps = [
    "Flask"
    "mistune"
    "networkx"
    "prometheus-client"
  ];

  propagatedBuildInputs = [
    flask
    karton-core
    mistune
    networkx
    prometheus-client
  ];

  # Project has no tests. pythonImportsCheck requires MinIO configuration
  doCheck = false;

  meta = with lib; {
    description = "Web application that allows for Karton task and queue introspection";
    mainProgram = "karton-dashboard";
    homepage = "https://github.com/CERT-Polska/karton-dashboard";
    changelog = "https://github.com/CERT-Polska/karton-dashboard/releases/tag/v${version}";
    license = with licenses; [ bsd3 ];
    maintainers = with maintainers; [ fab ];
  };
}
