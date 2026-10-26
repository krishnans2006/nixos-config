{
  lib,
  fetchFromGitHub,
  flutter,
  copyDesktopItems,
  makeDesktopItem,
  alsa-lib,
  mpv-unwrapped,
  sqlite,
  zlib,
  jdk,
}:

flutter.buildFlutterApplication rec {
  pname = "jellybox";
  version = "2.10.0";

  src = fetchFromGitHub {
    owner = "avdept";
    repo = "JellyBoxPlayer";
    tag = "v${version}";
    hash = "sha256-XhaIPI2JVJ3q+KHdhbTBjpFc+N+iogLufqHZq4Lpur8=";
  };

  autoPubspecLock = src + "/pubspec.lock";

  postPatch = ''
        cat << 'EOF' >> pubspec.yaml

    hooks:
      user_defines:
        sqlite3:
          source: system
    EOF
  '';

  nativeBuildInputs = [ copyDesktopItems ];

  buildInputs = [ alsa-lib mpv-unwrapped sqlite zlib ];

  env = {
    CMAKE_PREFIX_PATH = "${zlib.dev}:${zlib}";
    JAVA_HOME = "${jdk}/lib/openjdk";
    NIX_CFLAGS_COMPILE = "-Wno-error=unused-result";
  };

  extraWrapProgramArgs = ''
    --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ mpv-unwrapped ]}
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "jellybox";
      exec = "jellybox";
      icon = "jellybox";
      desktopName = "JellyBox";
      genericName = "Music Player";
      comment = "Jellyfin music player";
      categories = [ "AudioVideo" "Audio" "Player" "Network" ];
      startupWMClass = "com.prodigytech.jellybox";
    })
  ];

  postInstall = ''
    install -Dm644 linux/packaging/jellybox.png $out/share/icons/hicolor/256x256/apps/jellybox.png
    install -Dm644 assets/images/jellybox_logo.svg $out/share/icons/hicolor/scalable/apps/jellybox.svg
  '';

  meta = {
    description = "A fast and modern desktop and mobile Jellyfin music player built with Flutter";
    homepage = "https://github.com/avdept/JellyBoxPlayer";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "jellybox";
  };
}
