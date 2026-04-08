{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.packages.zed-editor;
in
{
  options.modules.packages.zed-editor = {
    enable = mkEnableOption "Install Zed code editor";
  };

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      installRemoteServer = true;

      mutableUserSettings = false;
      mutableUserKeymaps = false;
      mutableUserTasks = false;
      mutableUserDebug = false;

      userSettings = {
        # General

        ## General Settings
        when_closing_with_no_tabs = "keep_window_open";
        on_last_window_closed = "quit_app";
        use_system_path_prompts = true;
        use_system_prompts = false; # Cannot be true on Linux
        redact_private_values = true;
        private_files = [ "**/.env*" "**/*.pem" "**/*.key" "**/*.cert" "**/*.crt" "**/secrets.yml" ];
        ## Security
        session.trust_all_worktrees = false;
        ## Workspace Restoration
        session.restore_unsaved_buffers = false; # If true, won't be prompted to save on quit
        restore_on_startup = "last_workspace";
        ## Scoped Settings
        #preview_channel_settings
        #settings_profiles
        ## Privacy
        telemetry.metrics = false;
        telemetry.diagnostics = false;
        ## Auto Update
        auto_update = false;  # Nix handles updates

        # Appearance

        ## Theme
        theme.mode = "dark";
        theme.dark = "One Dark";
        theme.light = "One Light";
        icon_theme.mode = "dark";
        icon_theme.dark = "Zed (Default)";
        icon_theme.light = "Zed (Default)";
        ## Buffer Font
        buffer_font_family = ".ZedMono";  # Alias to Lilex
        buffer_font_size = 15;
        buffer_font_weight = 400;
        buffer_line_height = "comfortable";
        #buffer_font_features
        #buffer_font_fallbacks
        ## UI Font
        ui_font_family = ".ZedSans";  # Alias to IBM Plex
        ui_font_size = 16;
        ui_font_weight = 400;
        #ui_font_features
        #ui_font_fallbacks
        ## Agent Panel Font
        agent_ui_font_size = null;  # If null, uses UI font size
        agent_buffer_font_size = null;  # If null, uses Buffer font size
        ## Text Rendering
        text_rendering_mode = "platform_default";
        ## Cursor
        multi_cursor_modifier = "alt";  # "cmd_or_ctrl"
        cursor_blink = true;
        cursor_shape = "bar";  # "block", "underline", "hollow"
        hide_cursor = "on_typing_and_movement";  # "never", "on_typing"
        ## Highlighting
        unnecessary_code_fade = 0.3;
        current_line_highlight = "all";  # "none", "gutter", "line"
        selection_highlight = true;
        rounded_selection = true;
        minimum_contrast_for_highlights = 45;
        ## Guides
        show_wrap_guides = true;
        wrap_guides = [80 100 120];

        # Keymap

        ## Keybindings
        ## See userKeymaps
        ## Base Keybinds
        base_keymap = "VSCode";  # "Atom", "JetBrains", "None", "Sublime Text", "TextMate"
        ## Modal Editing
        vim_mode = false;
        helix_mode = false;

        # Editor

        ## Auto Save
        autosave = "on_focus_change";  # "off", "on_window_change", "after_delay"
        ## Which-key Menu
        which_key.enabled = true;
        which_key.delay_ms = 1000;
        ## Multibuffer
        double_click_in_multibuffer = "select";  # "open"
        expand_excerpt_lines = 5;
        excerpt_context_lines = 2;
        outline_panel.expand_outlines_with_depth = 100;
        diff_view_style = "split";  # "unified"
        ## Scrolling

        # Languages & Tools

        # Search & Files

        # Window & Layout

        # Panels

        # Debugger

        # Terminal

        # Version Control

        # Collaboration

        # AI

        # Network

        active_pane_modifiers = {
          border_size = 0;
          inactive_opacity = 1;
        };

        format_on_save = "on";
      };
    };
  };
}
