{ ... }:

{
  # Must be enabled in system config
  services.flatpak = {
    remotes = [
      { name = "flathub"; location = "https://dl.flathub.org/repo/flathub.flatpakrepo"; }
    ];
    update.onActivation = true;

    # Populated by other modules (see modules/packages/*.nix)
    packages = [];
  };
}
