{ pkgs, root, ... }:

{
  imports = [
    "${root}/config/home/basic.nix"
    "${root}/config/home/secrets.nix"
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

    (pkgs.lutris-free.override {
      # Override the underlying lutris package
      lutris = pkgs.lutris.override {
        # Intercept buildFHSEnv to modify target packages
        buildFHSEnv = args: pkgs.buildFHSEnv (args // {
          multiPkgs = envPkgs:
            let
              # Fetch original package list
              originalPkgs = args.multiPkgs envPkgs;

              # Disable tests for openldap
              customLdap = envPkgs.openldap.overrideAttrs (_: { doCheck = false; });
            in
            # Replace broken openldap with the custom one
            builtins.filter (p: (p.pname or "") != "openldap") originalPkgs ++ [ customLdap ];
        });
      };
    })
    prismlauncher  # minecraft
    #sauerbraten

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
}
