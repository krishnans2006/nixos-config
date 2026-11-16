{ lib, stdenv, rustPlatform, fetchFromGitHub, pkg-config, alsa-lib, udev }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "shurectl";
  version = "2.17.1";

  src = fetchFromGitHub {
    owner = "Humblemonk";
    repo = "shurectl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7YMDR7FXo7/cG9uPVccXxjDGo6/oo2OnBJVwIlhuXNk=";
  };

  cargoHash = "sha256-i86oDGJelXOdolpV5xs0nhDNPt4BFMMKKUIHxxh30xY=";

  # Keep the MV6 usable when its Mute Button query goes unanswered.
  patches = [ ./shurectl-mv6-mute-button.patch ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ alsa-lib udev ];

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    install -Dm644 62-shure.rules $out/lib/udev/rules.d/62-shure.rules
  '';

  meta = {
    description = "Terminal UI for configuring Shure USB audio interfaces and microphones";
    homepage = "https://github.com/Humblemonk/shurectl";
    changelog = "https://github.com/Humblemonk/shurectl/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.krishnans2006 ];
    mainProgram = "shurectl";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
