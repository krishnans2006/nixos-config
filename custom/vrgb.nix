{ lib, stdenvNoCC, fetchFromGitHub, python3, writeText, udevCheckHook }:

# Usage:
# In NixOS, add the package to services.udev.packages for seat users to get
# hidraw access without root:
#   services.udev.packages = [ vrgb ];

let
  # Upstream only embeds this in install.sh (no rules file in the repo)
  # Prefer TAG+=uaccess over GROUP="vrgb" for NixOS.
  # Must sort before 73-seat-late.rules (which applies uaccess).
  udevRules = writeText "70-vrgb.rules" ''
    SUBSYSTEM=="hidraw", KERNELS=="i2c-ITE5570*", MODE="0660", TAG+="uaccess"
  '';
in
stdenvNoCC.mkDerivation {
  pname = "vrgb";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "vrgb-dev";
    repo = "vrgb";
    rev = "1b480e5cbb77f373a9a34d1c0987019c90ae3f48";
    hash = "sha256-5m2auHvprWeh0Xb2NI3IJYV+22t43NSVM5D89GjAbIo=";
  };

  buildInputs = [ python3 ];

  nativeInstallCheckInputs = [ udevCheckHook ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 vrgb.py $out/bin/vrgb
    install -Dm644 ${udevRules} $out/lib/udev/rules.d/70-vrgb.rules

    runHook postInstall
  '';

  meta = {
    description = "RGB control for ASUS Vivobook HID LampArray keyboards";
    homepage = "https://github.com/vrgb-dev/vrgb";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.krishnans2006 ];
    platforms = lib.platforms.linux;
    mainProgram = "vrgb";
  };
}
