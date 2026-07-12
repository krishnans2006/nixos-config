{ pkgs, root, ... }:

{
  imports = [
    "${root}/utils/secrets-home.nix"
  ];

  home.username = "krishnan";
  home.homeDirectory = "/home/krishnan";

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    (python314.withPackages (ps: with ps; [
      jupyterlab
      jupyterlab-lsp
      jedi-language-server
      tqdm
      matplotlib
      numpy
      scipy
      pandas
      discordpy
    ]))

    # kicad
    # gimp

    via

    audacity
    vlc
    obs-studio

    zoom-us

    claude-code
  ];

  # Nanorc
  home.file.".nanorc".text = ''
    set autoindent
    set tabsize 4
    set tabstospaces
    set linenumbers
  '';

  # GDB (for ECE 391)
  home.file.".config/gdb/gdbinit" = {
    text = "set auto-load safe-path /";
  };

  programs.vscode.enable = true;
  programs.java.enable = true;

  # Pull in some files through secrets
  sops.secrets = {
    # Yubikey auth (see modules/system/yubikey-auth.nix)
    "yubikey/u2f_keys".path = "/home/krishnan/.config/Yubico/u2f_keys";

    # WakaTime config (pick one to use)
    "wakatime/wakatime" = {};  # Unused
    "wakatime/wakapi".path = "/home/krishnan/.wakatime.cfg";
    "wakatime/hackatime" = {};  # Unused
  };
}
