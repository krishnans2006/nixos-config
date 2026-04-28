{ config, lib, pkgs, root, ... }:

with lib;

let
  cfg = config.modules.packages.zed-editor;

  wakatime-ls = import "${root}/custom/wakatime-ls.nix" { inherit pkgs; };
in
{
  options.modules.packages.zed-editor = {
    enable = mkEnableOption "Install Zed code editor";
  };

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      installRemoteServer = true;

      extraPackages = with pkgs; [
        nil
        nixd
        ruff
        zed-discord-presence
        wakatime-ls
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
        "html"
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
        };

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
        icon_theme.dark = "Material Icon Theme";
        icon_theme.light = "Material Icon Theme";
        ## Buffer Font
        buffer_font_family = ".ZedMono";  # Alias to Lilex
        buffer_font_size = 15;
        buffer_font_weight = 400;
        buffer_line_height = "standard"; # "comfortable" or buffer_line_height.custom = 1 (compact), 2 (loose)
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
        hide_mouse = "on_typing_and_movement";  # "never", "on_typing"
        ## Highlighting
        unnecessary_code_fade = 0.3;
        current_line_highlight = "all";  # "none", "gutter", "line"
        selection_highlight = true;
        rounded_selection = true;
        minimum_contrast_for_highlights = 45;
        ## Guides
        show_wrap_guides = true;
        wrap_guides = [ 80 100 120 ];

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
        scroll_beyond_last_line = "one_page";  # "off", "vertical_scroll_margin"
        vertical_scroll_margin = 3;
        horizontal_scroll_margin = 5;
        scroll_sensitivity = 1.0;
        fast_scroll_sensitivity = 4.0;
        autoscroll_on_clicks = false;
        sticky_scroll.enabled = false;
        ## Signature Help
        auto_signature_help = false;
        show_signature_help_after_edits = false;
        snippet_sort_order = "inline";  # "top"
        ## Hover Popover
        hover_popover_enabled = true;
        hover_popover_delay = 300;
        ## Drag And Drop Selection
        drag_and_drop_selection.enabled = true;
        drag_and_drop_selection.delay = 300;
        ## Gutter
        gutter.line_numbers = true;
        relative_line_numbers = "disabled";  # "enabled", "wrapped"
        gutter.runnables = true;
        gutter.breakpoints = true;
        gutter.folds = true;
        gutter.min_line_number_digits = 4;
        inline_code_actions = true;
        ## Scrollbar
        scrollbar.show = "auto";  # "system", "always", "never"
        scrollbar.cursors = true;
        scrollbar.git_diff = true;
        scrollbar.search_results = true;
        scrollbar.selected_text = true;
        scrollbar.selected_symbol = true;
        scrollbar.diagnostics = "all";  # "information", "warning", "error", "none"
        scrollbar.axes.horizontal = true;
        scrollbar.axes.vertical = true;
        ## Minimap
        minimap.show = "always";  # "auto", "never"
        minimap.display_in = "active_editor";  # "all_editors"
        minimap.thumb = "always";  # "hover", "never"
        minimap.thumb_border = "left_open";  # "full", "right_open", "left_only", "none"
        minimap.current_line_highlight = null;  # Inherits from editor setting
        minimap.max_width_columns = 80;
        ## Toolbar
        toolbar.breadcrumbs = true;
        toolbar.quick_actions = true;
        toolbar.selections_menu = true;
        toolbar.agent_review = true;
        toolbar.code_actions = false;
        ## Vim
        vim.default_mode = "normal";  # "insert"
        vim.toggle_relative_line_numbers = false;
        vim.use_system_clipboard = "always";  # "never", "on_yank"
        vim.use_smartcase_find = false;
        vim.gdefault = false;
        vim.highlight_on_yank_duration = 200;
        vim.cursor_shape.normal = "block";
        vim.cursor_shape.insert = "inherit";
        vim.cursor_shape.replace = "underline";
        vim.cursor_shape.visual = "block";
        #vim.custom_digraphs = {};
        ## Indentation
        tab_size = 4;
        hard_tabs = false;
        auto_indent = true;
        auto_indent_on_paste = true;
        ## Wrapping
        soft_wrap = "none";  # "editor_width", "preferred_line_length", "bounded"
        preferred_line_length = 80;
        allow_rewrap = "in_comments";  # "anywhere", "in_selections"
        ## Indent Guides
        indent_guides.enabled = true;
        indent_guides.line_width = 1;
        indent_guides.active_line_width = 1;
        indent_guides.coloring = "fixed";  # "indent_aware"
        indent_guides.background_coloring = "disabled";  # "indent_aware"
        ## Formatting
        format_on_save = "on";  # "off"
        remove_trailing_whitespace_on_save = true;
        ensure_final_newline_on_save = true;
        #formatter = "auto";
        use_on_type_format = true;
        #code_actions_on_format = {};
        ## Autoclose
        use_autoclose = true;
        use_auto_surround = true;
        always_treat_brackets_as_autoclosed = false;
        jsx_tag_auto_close.enabled = true;
        ## Whitespace
        show_whitespaces = "selection";  # "all", "none", "boundary"
        #whitespace_map.space = "\u2022";
        #whitespace_map.tab = "\u2192";
        ## Completions
        show_completions_on_input = true;
        show_completion_documentation = true;
        completions.words = "fallback";  # "enabled", "disabled"
        completions.words_min_length = 3;
        completion_menu_scrollbar = "never";  # "auto", "always"
        completion_detail_alignment = "left";  # "right"
        ## Inlay Hints
        inlay_hints.enabled = true;
        inlay_hints.show_value_hints = true;
        inlay_hints.show_type_hints = true;
        inlay_hints.show_parameter_hints = true;
        inlay_hints.show_other_hints = true;
        inlay_hints.show_background = false;
        inlay_hints.edit_debounce_ms = 700;
        inlay_hints.scroll_debounce_ms = 50;
        #inlay_hints.toggle_on_modifiers_press
        lsp_document_colors = "inlay";  # "background", "border", "none"
        ## Tasks
        tasks.enabled = true;
        #tasks.variables = {};
        tasks.prefer_lsp = true;
        ## Miscellaneous
        word_diff_enabled = true;
        #debuggers
        middle_click_paste = true;
        extend_comment_on_newline = true;
        colorize_brackets = false;
        image_viewer.unit = "binary";  # "decimal"
        message_editor.auto_replace_emoji_shortcode = true;
        drop_target_size = 0.2;

        # Languages & Tools

        ## LSP
        enable_language_server = true;
        #language_servers = ["..."];
        linked_edits = true;
        go_to_definition_fallback = "find_all_references";  # "none"
        semantic_tokens = "off";  # "combined", "full"
        document_folding_ranges = "off";  # "on"
        document_symbols = "off";  # "on"
        ## LSP Completions
        completions.lsp = true;
        completions.lsp_fetch_timeout_ms = 0;
        completions.lsp_insert_mode = "replace_suffix";  # "insert", "replace", "replace_subsequence"
        ## Debuggers (per-language)
        #debuggers
        ## Prettier
        prettier.allowed = false;
        prettier.parser = "";
        #prettier.plugins = [];
        #prettier.options = {};
        ## File Types
        #file_type_associations
        ## Diagnostics
        diagnostics_max_severity = "all";  # "error", "warning", "info", "hint"
        diagnostics.include_warnings = true;
        ## Inline Diagnostics
        diagnostics.inline.enabled = false;
        diagnostics.inline.update_debounce_ms = 150;
        diagnostics.inline.padding = 4;
        diagnostics.inline.min_column = 0;
        ## LSP Pull Diagnostics
        diagnostics.lsp_pull_diagnostics.enabled = true;
        diagnostics.lsp_pull_diagnostics.debounce_ms = 50;
        ## LSP Highlights
        lsp_highlight_debounce = 75;

        # Search & Files

        ## Search
        search.whole_word = false;
        search.case_sensitive = false;
        use_smartcase_search = false;
        search.include_ignored = false;
        search.regex = false;
        search_wrap = true;
        search.center_on_match = false;
        seed_search_query_from_cursor = "always";  # "selection", "never"
        ## File Finder
        file_finder.include_ignored = "smart";  # "all", "indexed"
        file_finder.file_icons = true;
        file_finder.modal_max_width = "small";  # "medium", "large", "xlarge", "full"
        file_finder.skip_focus_for_active_in_search = true;
        file_finder.git_status = true;
        ## File Scan
        #file_scan_exclusions = ["**/.git" "**/.svn" "**/.hg" "**/.jj" "**/.sl" "**/.repo" "**/CVS" "**/.DS_Store" "**/Thumbs.db" "**/.classpath" "**/.settings"];
        #file_scan_inclusions = [".env*"];
        restore_on_file_reopen = true;
        close_on_file_delete = false;

        # Window & Layout

        ## Status Bar
        project_panel.button = true;
        status_bar.active_language_button = true;
        status_bar.active_encoding_button = "non_utf8";  # "always", "never"
        status_bar.cursor_position_button = true;
        terminal.button = true;
        diagnostics.button = true;
        search.button = true;
        debugger.button = true;
        ## Title Bar
        title_bar.show_branch_icon = false;
        title_bar.show_branch_name = true;
        title_bar.show_project_items = true;
        title_bar.show_onboarding_banner = true;
        title_bar.show_sign_in = true;
        title_bar.show_user_menu = true;
        title_bar.show_user_picture = true;
        title_bar.show_menus = false;
        ## Tab Bar
        tab_bar.show = true;
        tabs.git_status = true;
        tabs.file_icons = true;
        tabs.close_position = "right";  # "left"
        #max_tabs = null;
        tab_bar.show_nav_history_buttons = true;
        tab_bar.show_tab_bar_buttons = true;
        tab_bar.show_pinned_tabs_in_separate_row = false;
        ## Tab Settings
        tabs.activate_on_close = "history";  # "neighbour", "left_neighbour"
        tabs.show_diagnostics = "off";  # "errors", "all"
        tabs.show_close_button = "hover";  # "always", "hidden"
        ## Preview Tabs
        preview_tabs.enabled = true;
        preview_tabs.enable_preview_from_project_panel = true;
        preview_tabs.enable_preview_from_file_finder = false;
        preview_tabs.enable_preview_from_multibuffer = true;
        preview_tabs.enable_preview_multibuffer_from_code_navigation = false;
        preview_tabs.enable_preview_file_from_code_navigation = true;
        preview_tabs.enable_keep_preview_on_code_navigation = false;
        ## Layout
        bottom_dock_layout = "contained";  # "full", "left_aligned", "right_aligned"
        centered_layout.left_padding = 0.2;
        centered_layout.right_padding = 0.2;
        ## Window
        use_system_window_tabs = false;
        window_decorations = "client";  # "server"
        ## Pane Modifiers
        active_pane_modifiers = {
          inactive_opacity = 1.0;
          border_size = 0;
        };
        zoomed_padding = true;
        ## Pane Split Direction
        pane_split_direction_vertical = "right";  # "left"
        pane_split_direction_horizontal = "down";  # "up"

        # Panels

        ## Project Panel
        project_panel.dock = "left";  # "right"
        project_panel.default_width = 300;
        project_panel.hide_gitignore = false;
        project_panel.entry_spacing = "standard";  # "standard"
        project_panel.file_icons = true;
        project_panel.folder_icons = true;
        project_panel.git_status = true;
        project_panel.indent_size = 20;
        project_panel.auto_reveal_entries = true;
        project_panel.starts_open = true;
        project_panel.auto_fold_dirs = true;
        project_panel.bold_folder_labels = false;
        project_panel.scrollbar.show = null;  # Inherits; "auto", "system", "always", "never"
        project_panel.show_diagnostics = "all";  # "errors", "off"
        project_panel.diagnostic_badges = true;
        project_panel.sticky_scroll = true;
        project_panel.indent_guides.show = "always";  # "active", "never"
        project_panel.drag_and_drop = true;
        project_panel.hide_root = true;
        project_panel.hide_hidden = false;
        #worktree.hidden_files = ["**/.*"];
        ### Auto Open Files
        project_panel.auto_open.on_create = true;
        project_panel.auto_open.on_paste = true;
        project_panel.auto_open.on_drop = true;
        project_panel.sort_mode = "directories_first";  # "mixed", "files_first"
        ## Terminal Panel
        terminal.dock = "bottom";  # "left", "right"
        ## Outline Panel
        outline_panel.button = true;
        outline_panel.dock = "left";  # "right", "bottom"
        outline_panel.default_width = 300;
        outline_panel.file_icons = true;
        outline_panel.folder_icons = true;
        outline_panel.git_status = true;
        outline_panel.indent_size = 20;
        outline_panel.auto_reveal_entries = true;
        outline_panel.auto_fold_dirs = true;
        outline_panel.indent_guides.show = "always";  # "never"
        ## Git Panel
        git_panel.button = true;
        git_panel.dock = "left";  # "bottom", "right"
        git_panel.default_width = 300;
        git_panel.status_style = "icon";  # "letter"
        git_panel.fallback_branch_name = "main";
        git_panel.sort_by_path = false;
        git_panel.collapse_untracked_diff = false;
        git_panel.scrollbar.show = null;  # Inherits; "auto", "always", "never"
        #git_panel.starts_open = false;
        ## Debugger Panel
        debugger.dock = "bottom";  # "left", "right"
        ## Notification Panel
        notification_panel.button = true;
        notification_panel.dock = "right";  # "left", "bottom"
        notification_panel.default_width = 380;
        #notification_panel.show_count_badge = false;
        ## Collaboration Panel
        collaboration_panel.button = true;
        collaboration_panel.dock = "left";  # "right", "bottom"
        collaboration_panel.default_width = 240;
        ## Agent Panel
        agent.button = true;
        agent.dock = "right";  # "left", "bottom"
        agent.default_width = 640;
        agent.default_height = 320;

        # Debugger

        ## General
        debugger.stepping_granularity = "line";  # "statement", "instruction"
        debugger.save_breakpoints = true;
        debugger.timeout = 2000;
        debugger.log_dap_communications = true;
        debugger.format_dap_log_messages = true;

        # Terminal

        ## Environment
        terminal.shell = "system";  # "program", or { program = "..."; args = [...]; }
        terminal.working_directory = "current_project_directory";  # "current_file_directory", "first_project_directory", "always_home", { always = "..."; }
        #terminal.env = {};
        terminal.detect_venv.on = {
          directories = [ ".venv" "venv" ];  # Default also includes "env" and ".env"
          activate_script = "default";  # "csh", "fish", "nushell"
        };
        ## Font
        terminal.font_size = null;  # Inherits buffer_font_size
        terminal.font_family = null;  # Inherits buffer_font_family
        #terminal.font_fallbacks
        terminal.font_weight = 400;
        #terminal.font_features
        ## Display Settings
        terminal.line_height = "standard";  # "comfortable" or line_height.custom = int
        terminal.cursor_shape = "block";  # "bar", "underline", "hollow"
        terminal.blinking = "terminal_controlled";  # "off", "on"
        terminal.alternate_scroll = "on";  # "off"
        terminal.minimum_contrast = 45;
        ## Behavior Settings
        terminal.option_as_meta = false;
        terminal.copy_on_select = false;
        terminal.keep_selection_on_copy = true;
        ## Layout Settings
        terminal.default_width = 640;
        terminal.default_height = 320;
        ## Advanced Settings
        terminal.max_scroll_history_lines = 100000;  # Default 10000, 0 disables scrolling entirely
        terminal.scroll_multiplier = 1.0;
        ## Toolbar
        terminal.toolbar.breadcrumbs = false;
        ## Scrollbar
        terminal.scrollbar.show = null;  # Inherits; "auto", "always", "never"

        # Version Control

        ## Git Integration
        git.disable_git = false;
        git.enable_status = true;
        git.enable_diff = true;
        ## Git Gutter
        git.git_gutter = "tracked_files";  # "hide"
        git.gutter_debounce = 0;
        ## Inline Git Blame
        git.inline_blame.enabled = true;
        git.inline_blame.delay_ms = 0;
        git.inline_blame.padding = 7;
        git.inline_blame.min_column = 0;
        git.inline_blame.show_commit_summary = false;
        ## Git Blame View
        git.blame.show_avatar = true;
        ## Branch Picker
        git.branch_picker.show_author_name = true;
        ## Git Hunks
        git.hunk_style = "staged_hollow";  # "unstaged_hollow"
        git.path_style = "file_name_first";  # "file_path_first"

        # Collaboration

        ## Calls
        calls.mute_on_join = false;
        calls.share_on_join = false;
        ## Audio
        audio.experimental.rodio_audio  = true;
        audio.experimental.auto_microphone_volume = true;
        audio.experimental.auto_speaker_volume = true;
        audio.experimental.denoise = true;
        audio.experimental.legacy_audio_compatible = false;
        audio.experimental.output_audio_device = null;  # System default if null
        audio.experimental.input_audio_device = null;  # System default if null

        # AI

        ## General
        disable_ai = false;
        ## Agent Configuration
        #agent.tool_permissions  # Configured via sub-page
        agent.single_file_review = false;
        agent.enable_feedback = true;
        agent.notify_when_agent_waiting = "primary_screen";  # "never", "all_screens"
        agent.play_sound_when_agent_done = true;
        agent.expand_edit_card = true;
        agent.expand_terminal_card = true;
        agent.cancel_generation_on_terminal_stop = true;
        agent.use_modifier_to_send = false;
        agent.message_editor_min_lines = 4;
        agent.show_turn_stats = true;
        ## Context Servers
        context_server_timeout = 60;
        ## Edit Predictions
        edit_predictions.provider = "copilot";  # "zed"
        show_edit_predictions = true;
        #edit_predictions_disabled_in = [];
        edit_predictions.mode = "eager";  # "subtle"
        edit_predictions.enabled_in_text_threads = true;

        # Network

        ## Network
        proxy = "";
        server_url = "https://zed.dev";

        # Other stuff that isn't categorized
        #language_models = {};
        agent.default_model = {
          provider = "openrouter";
          model = "anthropic/claude-opus-4.6";
          enable_thinking = true;
        };
      };
    };
  };
}
