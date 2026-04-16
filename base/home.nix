{ config, pkgs, ... }:

{
  imports = [
    ../config/home/basic.nix
    ../config/home/secrets.nix
  ];

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    pkg-config

    micro

    zsh-powerlevel10k
    meslo-lgs-nf

    kdePackages.kate
    kdePackages.bluedevil
    kdePackages.filelight
    # kdePackages.kdenlive
    # krita

    nodejs
    pnpm
    npm-check-updates
    sass

    vesktop
    discord-canary
    #libunity  # required for vesktop
    slack
    element-desktop
    signal-desktop
    mattermost-desktop
    zulip

    zoom-us

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
    poetry
    pipenv
    octodns

    ansible
    sshpass

    sshfs

    jdk

    platformio

    nixfmt

    # kicad
    # gimp

    qmk
    via
    #vial

    quickemu
    #quickgui

    audacity
    vlc
    obs-studio

    lc3tools

    lutris-free
    prismlauncher  # minecraft
    #sauerbraten
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

  programs.zoxide = {
    enable = true;
    options = [ "--cmd" "cd" ];
  };

  # direnv for auto-activation of .envrc (and devenv)
  programs.direnv = {
    enable = true;
    #enableBashIntegration = true;
    nix-direnv.enable = true;
    config = {
      global."warn_timeout" = 0;
    };
  };

  programs.vscode.enable = true;
}
