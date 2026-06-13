{ pkgs, root, ... }:

{
  imports = [
    "${root}/config/home/basic.nix"
    "${root}/config/home/secrets.nix"
  ];

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
}
