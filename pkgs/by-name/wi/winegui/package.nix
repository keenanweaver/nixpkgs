{
  steam,
  winegui-unwrapped,
  extraEnv ? { },
  extraLibraries ? _: [ ],
  extraPkgs ? _: [ ],
}:

steam.buildRuntimeEnv {
  inherit (winegui-unwrapped) version;
  inherit extraEnv;

  pname = "winegui";

  extraInstallCommands = ''
    mkdir -p $out/share
    ln -s ${winegui-unwrapped}/share/applications $out/share
    ln -s ${winegui-unwrapped}/share/icons $out/share
    ln -s ${winegui-unwrapped}/share/metainfo $out/share
  '';

  # https://wiki.winehq.org/Building_Wine
  extraLibraries =
    pkgs:
    with pkgs;
    [
      alsa-lib
      cups
      dbus
      fontconfig
      freetype
      glib
      gnutls
      gsm
      libglvnd
      libgphoto2
      libjpeg_turbo
      libkrb5
      libpcap
      libpng
      libpulseaudio
      libtiff
      libunwind
      libusb1
      libv4l
      libxml2
      mpg123
      ocl-icd
      openldap
      samba4
      sane-backends
      SDL2

      libsm
      libx11
      libxcb
      libxcomposite
      libxcursor
      libxext
      libxfixes
      libxi
      libxinerama
      libxrandr
      libxrender
      libxxf86vm

      libxkbcommon
      wayland
    ]
    ++ (with pkgs.gst_all_1; [
      gstreamer
      gst-plugins-base
      gst-plugins-good
      gst-plugins-ugly
      gst-plugins-bad
      gst-libav
    ])
    ++ extraLibraries pkgs;

  extraPkgs = pkgs: [ winegui-unwrapped ] ++ extraPkgs pkgs;
  privateTmp = false;
  runScript = "winegui";

  meta = winegui-unwrapped.meta // {
    # needs i686 multilib; runners are x86 only
    platforms = [ "x86_64-linux" ];
  };
}
