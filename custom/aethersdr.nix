{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  autoPatchelfHook,
  makeWrapper,
  cacert,
  fontconfig,
  freetype,
  libGL,
  libglvnd,
  vulkan-loader,
  alsa-lib,
  libjack2,
  pipewire,
  wayland,
  libdrm,
  libx11,
  libxext,
  libxrandr,
  libxrender,
  libxcb,
  e2fsprogs,
  libgpg-error,
  libsecret,
  systemdLibs,
  xkeyboard_config,
  zlib,
}:

let
  pname = "aethersdr";
  version = "26.10.1";

  sources = {
    x86_64-linux = {
      url = "https://github.com/aethersdr/AetherSDR/releases/download/v${version}/AetherSDR-v${version}-x86_64.AppImage";
      hash = "sha256-gB+eoZUKAPmy8EWdCMrQ+LAI349zOJyUXTDP700o5JQ=";
    };
    aarch64-linux = {
      url = "https://github.com/aethersdr/AetherSDR/releases/download/v${version}/AetherSDR-v${version}-aarch64.AppImage";
      hash = "sha256-cJlqC+FIeHYxXjqRi1U6RnYPahJZOEE4ov8Pqw0rdsE=";
    };
  };

  src = fetchurl (
    sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}")
  );

  appimageContents = appimageTools.extract { inherit pname version src; };
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version;
  src = appimageContents;

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

  buildInputs = [
    alsa-lib
    e2fsprogs
    fontconfig
    freetype
    libGL
    libdrm
    libglvnd
    libgpg-error
    libjack2
    libsecret
    libx11
    libxcb
    libxext
    libxrandr
    libxrender
    pipewire
    stdenv.cc.cc.lib
    systemdLibs
    vulkan-loader
    wayland
    zlib
  ];

  # Additional libraries needed for runtime dynamic loading (dlopen)
  runtimeDependencies = [ libGL libglvnd pipewire vulkan-loader ];

  dontBuild = true;
  dontStrip = true;

  # Remove outdated bundled libsystemd/libudev so autoPatchelfHook links against nixpkgs systemdLibs
  postPatch = ''
    rm -f usr/lib/libsystemd.so* usr/lib/libudev.so*
  '';

  installPhase = ''
    runHook preInstall
    cp -r usr $out
    runHook postInstall
  '';

  postFixup = ''
    for bin in $out/bin/AetherSDR $out/bin/aether-dv-waveform; do
      wrapProgram "$bin" \
        --set QT_PLUGIN_PATH "$out/plugins" \
        --set XKB_CONFIG_ROOT "${xkeyboard_config}/share/X11/xkb" \
        --set QT_XKB_CONFIG_ROOT "${xkeyboard_config}/share/X11/xkb" \
        --set SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt"
    done
  '';

  meta = {
    description = "Linux-native client for FlexRadio Systems transceivers";
    homepage = "https://github.com/aethersdr/AetherSDR";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = [ lib.maintainers.krishnans2006 ];
    mainProgram = "AetherSDR";
  };
})
