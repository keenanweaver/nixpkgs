{ lib
, stdenv
, fetchFromGitHub
, cmake
, SDL2
}:

stdenv.mkDerivation rec {
  pname = "bstone";
  version = "1.2.12";

  src = fetchFromGitHub {
    owner = "bibendovsky";
    repo = "bstone";
    rev = "v${version}";
    hash = "sha256-wtW595cSoVTZaVykxOkJViNs3OmuIch9nA5s1SqwbJo=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [ SDL2 ];

  installPhase = ''
    mkdir -p $out/bin
    make install prefix=$out
    mv $out/bstone* $out/bin/
  '';

  meta = with lib; {
    description = "Unofficial source port for Blake Stone series";
    homepage = "https://github.com/bibendovsky/bstone";
    changelog = "https://github.com/bibendovsky/bstone/blob/${src.rev}/CHANGELOG.md";
    license = with licenses; [ gpl2 mit ];
    maintainers = with maintainers; [ keenanweaver ];
  };
}
