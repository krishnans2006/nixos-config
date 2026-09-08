{ pkgs, root, ... }:

let
  custom-nixfmt = pkgs.callPackage (root + "/formatter/package.nix") { };
in
{
  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    custom-nixfmt
    nix-diff

    (python314.withPackages (
      ps: with ps; [
        jupyterlab
        jupyterlab-lsp
        jedi-language-server
        tqdm
        matplotlib
        numpy
        scipy
        pandas
        discordpy
      ]
    ))

    # kicad
    # gimp

    via

    audacity
    vlc
    obs-studio

    zoom-us

    claude-code
  ];

  programs.vscode.enable = true;
  programs.java.enable = true;
}
