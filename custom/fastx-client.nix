{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  wrapQtAppsHook,
  qtbase,
  qtsvg,
  qtdeclarative,
  qtwebengine,
  qtwebchannel,
  qtwebsockets,
  qtpositioning,
  qtcharts,
  qtimageformats,
  cacert,
  fontconfig,
  freetype,
  libGL,
  libglvnd,
  libxcb,
  libxcb-keysyms,
  libxkbcommon,
  xkeyboard_config,
  zlib,
}:

let
  icon = fetchurl {
    url = "https://www.starnet.com/wp-content/uploads/2025/08/Fastx-logo.png";
    hash = "sha256-Hnm5qB0BmKpS8H+oiG1SpjNzOMqJXpebJANSqjBmSnw=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "fastx-client";
  version = "5.1.14";

  src = fetchurl {
    url = "https://www.starnet.com/files/private/FastX-client/FastX5-${finalAttrs.version}.rhel9.x86_64.tar.gz";
    hash = "sha256-NrUcY1Tkzo5CQL2SqD+8QgbBNS4K3e1CSF1UbxC4FmM=";
  };

  sourceRoot = "FastX5";

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtsvg
    qtdeclarative
    qtwebengine
    qtwebchannel
    qtwebsockets
    qtpositioning
    qtcharts
    qtimageformats
    fontconfig
    freetype
    libGL
    libglvnd
    libxcb
    libxcb-keysyms
    libxkbcommon
    stdenv.cc.cc.lib
    zlib
  ];

  dontBuild = true;
  dontStrip = true;

  # Upstream ships a full Qt 6.4 tree; use nixpkgs Qt instead (see p4v).
  postPatch = ''
    rm -rf lib plugins libexec resources translations qt.conf
    rm -f AppRun integrate integrate.readme
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "fastx";
      desktopName = "FastX Client";
      genericName = "Remote Desktop Client";
      comment = "Connect to a FastX server via SSH or HTTPS";
      exec = "fastx5";
      icon = "fastx";
      terminal = false;
      categories = [
        "Network"
        "RemoteAccess"
      ];
      startupNotify = true;
      startupWMClass = "fastx5";
      keywords = [
        "fastx"
        "remote"
        "ssh"
        "vnc"
      ];
    })
    (makeDesktopItem {
      name = "fastx-uri";
      desktopName = "FastX URL Handler";
      exec = "fastxuri %u";
      icon = "fastx";
      categories = [ "Network" ];
      noDisplay = true;
      mimeTypes = [ "x-scheme-handler/fastx" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,opt/fastx,share/icons/hicolor/512x512/apps}
    cp -a . $out/opt/fastx/

    install -Dm644 ${icon} $out/share/icons/hicolor/512x512/apps/fastx.png

    for bin in fastx5 fastxcli fastxuri fastx-askpass FastXSSHAgent; do
      ln -s ../opt/fastx/$bin $out/bin/$bin
    done
    ln -s fastx5 $out/bin/fastx

    runHook postInstall
  '';

  # wrapQtAppsHook wraps $out/bin symlinks into scripts pointing at the binaries.
  qtWrapperArgs = [
    "--set-default"
    "QT_QPA_PLATFORM"
    "xcb"
    "--set"
    "QTWEBENGINEPROCESS_PATH"
    "${qtwebengine}/libexec/QtWebEngineProcess"
    "--set"
    "QTWEBENGINE_DISABLE_SANDBOX"
    "1"
    "--set"
    "QT_XKB_CONFIG_ROOT"
    "${xkeyboard_config}/share/X11/xkb"
    "--set"
    "SSL_CERT_FILE"
    "${cacert}/etc/ssl/certs/ca-bundle.crt"
    "--prefix"
    "PATH"
    ":"
    "${placeholder "out"}/bin"
  ];

  meta = {
    description = "Connect to a FastX server via SSH or HTTPS";
    homepage = "https://www.starnet.com/fastx/";
    downloadPage = "https://www.starnet.com/download-fastx-client/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    maintainers = [ lib.maintainers.krishnans2006 ];
    mainProgram = "fastx5";
  };
})
