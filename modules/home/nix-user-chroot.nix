{ config, lib, ... }:

with lib;

let
  cfg = config.modules.nix-user-chroot;

  homeDirectory = config.home.homeDirectory;
  nixProfileDirectory = "${homeDirectory}/.nix-profile";
  launcherPath = "${homeDirectory}/.local/bin/home-only-shell";

  launcherContent = ''
    #!/bin/sh

    unset FPATH
    export HOME_ONLY_CHROOT=1
    set -x
    exec "${homeDirectory}/.local/bin/nix-user-chroot" \
      "${homeDirectory}/.nix" \
      "${nixProfileDirectory}/bin/zsh" -l
  '';

  loginHookContent = ''
    # Enter the Home Manager nix-user-chroot.
    if [ -z "''${HOME_ONLY_CHROOT:-}" ] && [ -t 0 ] && [ -x "${launcherPath}" ]; then
      exec "${launcherPath}"
    fi
  '';

  patchShellFiles = [
    "${homeDirectory}/.bash_profile"
    "${homeDirectory}/.zprofile"
    "${homeDirectory}/.zshrc"
  ];
in
{
  options.modules.nix-user-chroot = {
    enable = mkEnableOption "rootless Nix shell integration using nix-user-chroot";
  };

  config = mkIf cfg.enable {
    home.activation.installNixUserChrootHostIntegration =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ${escapeShellArg (dirOf launcherPath)}
        printf %s ${escapeShellArg launcherContent} > ${escapeShellArg launcherPath}
        chmod 0755 ${escapeShellArg launcherPath}

        for loginProfile in ${escapeShellArgs patchShellFiles}; do
          touch "$loginProfile"
          if ! grep -Fq "# Enter the Home Manager nix-user-chroot." "$loginProfile"; then
            printf %s ${escapeShellArg loginHookContent} >> "$loginProfile"
          fi
        done
      '';

    # Instead of "compinit" use "compinit -u" to avoid errors
    # from zsh completion system when in a chroot environment
    programs.zsh.completionInit = "autoload -U compinit && compinit -u";
  };
}
