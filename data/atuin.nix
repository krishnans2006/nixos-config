{ config }:

{
  # https://docs.atuin.sh/configuration/config/
  settings = {
    db_path = "~/.local/share/atuin/history.db";
    key_path = config.sops.secrets."atuin/key_b64".path;
    session_path = "~/.local/share/atuin/session";
    dialect = "us";

    auto_sync = true;
    update_check = false;
    sync_address = "https://atuin.krishy.dev";
    sync_frequency = "5m";

    search_mode = "fuzzy";
    filter_mode = "global";
    workspaces = false;  # Filter mode for when in a git repository

    style = "auto";  # Full when possible
    invert = false;
    inline_height = 0;
    show_preview = true;
    max_preview_height = 4;
    show_help = true;
    show_tabs = false;
    exit_mode = "return-original";

    store_failed = true;
    secrets_filter = true;

    network_timeout = 30;
    network_connect_timeout = 5;
    local_timeout = 5;

    enter_accept = true;
    sync.records = true;
  };
}
