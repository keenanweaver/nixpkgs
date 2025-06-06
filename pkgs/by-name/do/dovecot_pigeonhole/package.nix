{
  lib,
  stdenv,
  fetchurl,
  dovecot,
  openssl,
}:
let
  dovecotMajorMinor = lib.versions.majorMinor dovecot.version;
in
stdenv.mkDerivation rec {
  pname = "dovecot-pigeonhole";
  version = "0.5.21.1";

  src = fetchurl {
    url = "https://pigeonhole.dovecot.org/releases/${dovecotMajorMinor}/dovecot-${dovecotMajorMinor}-pigeonhole-${version}.tar.gz";
    hash = "sha256-A3fbKEtiByPeBgQxEV+y53keHfQyFBGvcYIB1pJcRpI=";
  };

  buildInputs = [
    dovecot
    openssl
  ];

  preConfigure = ''
    substituteInPlace src/managesieve/managesieve-settings.c --replace \
      ".executable = \"managesieve\"" \
      ".executable = \"$out/libexec/dovecot/managesieve\""
    substituteInPlace src/managesieve-login/managesieve-login-settings.c --replace \
      ".executable = \"managesieve-login\"" \
      ".executable = \"$out/libexec/dovecot/managesieve-login\""
  '';

  configureFlags = [
    "--with-dovecot=${dovecot}/lib/dovecot"
    "--with-moduledir=${placeholder "out"}/lib/dovecot/modules"
    "--without-dovecot-install-dirs"
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    homepage = "https://pigeonhole.dovecot.org/";
    description = "Sieve plugin for the Dovecot IMAP server";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ globin ];
    teams = [ teams.helsinki-systems ];
    platforms = platforms.unix;
  };
}
