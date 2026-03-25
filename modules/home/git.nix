{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.git;
in
{
  options.modules.git = {
    enable = mkEnableOption "Enable custom git configuration";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        user.name = "Krishnan Shankar";
        user.email = "krishnans2006@gmail.com";

        init.defaultBranch = "main";
        core.autocrlf = "input";
        pull.rebase = false;
        push.autoSetupRemote = true;
      };
      signing = {
        key = "A30C1843F47048435D543D6829CB06A840D0E14A";
        signByDefault = true;
      };
      ignores = [
        ".idea/"
        ".vscode/"
        ".direnv/"
        ".envrc"
      ];
    };
  };
}
