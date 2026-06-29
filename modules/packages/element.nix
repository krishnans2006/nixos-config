{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.packages.element;
in
{
  options.modules.packages.element = {
    enable = mkEnableOption "Install Element (Matrix client)";
    autostart = mkEnableOption "Enable autostart for Element";
  };

  config = mkIf cfg.enable {
    programs.element-desktop = {
      enable = true;
      settings = {
        brand = "Element";
        default_theme = "dark";

        default_server_config = {
          "m.homeserver" = {
            base_url = "https://matrix-client.matrix.org";
            server_name = "matrix.org";
          };
          "m.identity_server" = {
            base_url = "https://vector.im";
          };
        };
        disable_custom_urls = true;  # Force matrix.org for now

        force_verification = true;  # Must verify new logins
        disable_login_language_selector = true;  # Hide language selector
        disable_3pid_login = true;  # Disable email/phone login
        disable_guests = false;

        # https://web-docs.element.dev/config.html#integration-managers
        integrations_ui_url = "https://scalar.vector.im/";
        integrations_rest_url = "https://scalar.vector.im/api";
        integrations_widgets_urls = [
          "https://scalar.vector.im/_matrix/integrations/v1"
          "https://scalar.vector.im/api"
          "https://scalar-staging.vector.im/_matrix/integrations/v1"
          "https://scalar-staging.vector.im/api"
        ];
      };
    };

    # Impermanence
    modules.impermanence.persistDirs = [
      ".config/Element/IndexedDB"  # E2E Keys, auth
      ".config/Element/EventStore"  # Seshat database for search
      ".config/Element/Local Storage"  # Session ids, theme
    ];
    modules.impermanence.persistFiles = [
      # This needs to be symlinked due to atomic write (copying temp file) shenanigans
      { file = ".config/Element/electron-config.json"; method = "symlink"; }
      ".config/Element/window-state.json"
    ];

    # Autostart
    xdg.configFile."autostart/element.desktop" = mkIf cfg.autostart {
      text = builtins.replaceStrings [ "element-desktop %u" ] [ "element-desktop --hidden %u" ] (
        builtins.readFile "${pkgs.element-desktop}/share/applications/element-desktop.desktop"
      );
    };
  };
}
