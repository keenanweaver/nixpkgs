{
  lib,
  stdenv,
  fetchFromGitHub,
  hidapi,
  udevCheckHook,
  profile ? "/etc/g810-led/profile",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "g810-led";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "MatMoul";
    repo = "g810-led";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GKHtQ7DinqfhclDdPO94KtTLQhhonAoWS4VOvs6CMhY=";
  };

  postPatch = ''
    substituteInPlace udev/g810-led.rules \
      --replace "/usr" $out \
      --replace "/etc/g810-led/profile" "${profile}"
  '';

  # GCC 13 cannot find `uint16_t` and other similar types by default anymore
  env.CXXFLAGS = "-include cstdint";

  buildInputs = [
    hidapi
  ];

  nativeBuildInputs = [
    udevCheckHook
  ];

  doInstallCheck = true;

  installPhase = ''
    runHook preInstall

    install -D bin/g810-led $out/bin/g810-led

    # See https://github.com/MatMoul/g810-led#compatible-keyboards-
    for keyboard in {g213,g410,g413,g512,g513,g610,g815,g910,gpro}; do
      ln -s \./g810-led $out/bin/$keyboard-led
    done

    install -D udev/g810-led.rules $out/etc/udev/rules.d/90-g810-led.rules

    runHook postInstall
  '';

  meta = with lib; {
    description = "Linux LED controller for some Logitech G Keyboards";
    homepage = "https://github.com/MatMoul/g810-led";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ fab ];
    platforms = platforms.linux;
  };
})
