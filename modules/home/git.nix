{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.git;
in
{
  options.modules.git = {
    enable = mkEnableOption "Enable custom git configuration";
    enablePdfDiff = mkEnableOption "Enable visual PDF diffs with diff-pdf";
  };

  config = mkIf cfg.enable (mkMerge [
    {
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
    }

    (mkIf cfg.enablePdfDiff {
      home.packages = with pkgs; [ diff-pdf ];

      programs.git = {
        settings."diff \"diff-pdf\"".command = ''f() { diff-pdf --view "$2" "$5"; }; f'';
        attributes = [ "*.pdf diff=diff-pdf" ];
      };
    })
  ]);
}
