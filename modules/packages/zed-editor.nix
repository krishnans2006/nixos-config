{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.packages.zed-editor;

  wakatime-ls = import "${root}/custom/wakatime-ls.nix" { inherit pkgs; };

  # This patch modifies zed-editor to use copilot-language-server from PATH
  # instead of npm-installing it into ~/.local/share/zed/copilot
  # This was a "regression" introduced by:
  # - https://github.com/zed-industries/zed/pull/56635
  # The ${root} interpolation won't work here, since it uses the derivation
  # of the root flake as a dependency (which technically works, but forces a
  # full rebuild of zed whenever anything in this config changes)
  zed-editor-patched = pkgs.zed-editor.overrideAttrs (prev: {
    patches = prev.patches ++ [ ../../custom/zed-editor-copilot.patch ];
  });
in
{
  options.modules.packages.zed-editor = {
    enable = mkEnableOption "Install Zed code editor";
  };

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      package = zed-editor-patched;
      installRemoteServer = true;

      extraPackages = with pkgs; [
        nil
        nixd
        nixfmt
        ruff
        texlab
        package-version-server

        cursor-cli

        zed-discord-presence
        wakatime-ls
        copilot-language-server
      ];

      mutableUserSettings = false;
      mutableUserKeymaps = false;
      mutableUserTasks = false;
      mutableUserDebug = false;

      # Note: Ideally, all LSPs are bundled in with extensions, so we shouldn't need to configure
      # them manually in userSettings.language_servers.
      extensions = [
        "ansible"
        "dockerfile"
        "docker-compose"
        "make"
        "sql"
        "svelte"

        "caddyfile"
        "django"
        "git-firefly"
        #jupyter??
        "latex"
        "linkerscript"
        "nix"
        "typst"
        "verilog"

        "discord-presence"
        "wakatime"

        # Maybe "one-dark-darkened", "vscode-dark-polished", ..?
        "material-icon-theme"
      ];

      userSettings = {
        # Extension/LSP/Language Settings

        # lsp.nil.initialization_options.formatting.command = [ "nixfmt" ];
        # lsp.nixd.initialization_options.formatting.command = [ "nixfmt" ];

        languages = {
          "Nix".formatter.external.command = "nixfmt";
          "Nix".format_on_save = "off";
          "Nix".tab_size = 2;

          "YAML".tab_size = 2;

          "Typst".soft_wrap = "editor_width";
          "Typst".tab_size = 2;
        };

        lsp = {
          "tinymist" = {
            # 127.0.0.1:23635
            initialization_options.preview.background.enabled = true;

            settings.formatterMode = "typstyle";  # "typstfmt"
          };
        };

        # General

        when_closing_with_no_tabs = "keep_window_open";
        on_last_window_closed = "quit_app";
        use_system_prompts = false; # Cannot be true on Linux
        redact_private_values = true;

        session.restore_unsaved_buffers = false; # If true, won't be prompted to save on quit
        restore_on_startup = "last_workspace";

        telemetry.metrics = false;
        telemetry.diagnostics = false;

        auto_update = false;  # Nix handles updates

        # Appearance

        theme.mode = "dark";
        theme.dark = "One Dark";
        theme.light = "One Light";
        icon_theme.mode = "dark";
        icon_theme.dark = "Material Icon Theme";
        icon_theme.light = "Material Icon Theme";

        buffer_line_height = "standard"; # "comfortable" or buffer_line_height.custom = 1 (compact), 2 (loose)

        wrap_guides = [ 80 100 120 ];

        # Editor

        autosave = "on_focus_change";  # "off", "on_window_change", "after_delay"

        which_key.enabled = true;

        minimap.show = "always";  # "auto", "never"

        preferred_line_length = 120;

        inlay_hints.enabled = true;

        # Window & Layout

        tabs.git_status = true;
        tabs.file_icons = true;

        # Panels

        project_panel.dock = "left";  # "right"
        project_panel.default_width = 300;
        project_panel.entry_spacing = "standard";  # "standard"
        project_panel.diagnostic_badges = true;
        project_panel.hide_root = true;

        outline_panel.dock = "left";  # "right", "bottom"

        git_panel.dock = "left";  # "bottom", "right"
        git_panel.default_width = 300;

        collaboration_panel.dock = "left";  # "right", "bottom"

        agent.dock = "right";  # "left", "bottom"

        # Terminal

        terminal.detect_venv.on = {
          directories = [ ".venv" "venv" ];  # Default also includes "env" and ".env"
        };

        terminal.max_scroll_history_lines = 100000;  # Default 10000, 0 disables scrolling entirely

        # AI

        agent.play_sound_when_agent_done = "always";  # "never", "on_failure"
        agent.show_turn_stats = true;

        edit_predictions.provider = "copilot";  # "zed"

        agent.default_model = {
          provider = "openrouter";
          model = "anthropic/claude-opus-4.6";
          enable_thinking = true;
        };

        agent_servers = {
          "cursor" = {
            type = "custom";
            command = "cursor-agent";
            # --force auto-approves tool calls from cursor
            # --approve-mcps approves MCP calls from cursor
            # See agent.always_allow_external_agent_tools which will come in the future
            args = [ "--force" "--approve-mcps" "acp" ];
            env."CURSOR_AGENT_EXECUTABLE" = "${pkgs.cursor-cli}/bin/cursor-agent";
            default_config_options.model = "claude-opus-4-8[thinking=true,context=300k,effort=high,fast=false]";
          };
        };
      };
    };

    # Impermanence
    # ~/.config/zed doesn't need persistence since it's declaratively configured
    modules.impermanence.persistDirs = [ ".local/share/zed" ".config/cursor" ];
  };
}
