{
  # Extension specifications
  extensions = {
    # Pinned
    darkreader = {
      id = "addon@darkreader.org";
      slug = "darkreader";
      pinned = true;
      pinOrder = 1;
    };
    bitwarden = {
      id = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
      slug = "bitwarden-password-manager";
      pinned = true;
      pinOrder = 2;
      enterpriseConfig.environment.base = "https://vault.krishy.dev";
    };
    ublock-origin = {
      id = "uBlock0@raymondhill.net";
      slug = "ublock-origin";
      pinned = true;
      pinOrder = 3;
      enterpriseConfig.userSettings = [ [ "showIconBadge" "false" ] ];
    };

    # Unpinned
    sponsorblock = {
      id = "sponsorBlocker@ajay.app";
      slug = "sponsorblock";
    };
    seven-tv = {
      id = "moz-addon-prod@7tv.app";
      slug = "7tv-extension";
    };
    improve-youtube = {
      id = "{3c6bf0cc-3ae2-42fb-9993-0d33104fdcaf}";
      slug = "youtube-addon";
      localConfigFile = ./improve-youtube.json;
    };
    violentmonkey = {
      id = "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}";
      slug = "violentmonkey";
    };
    foxy-gestures = {
      id = "{e839c3f9-298e-4cd0-99e0-464431cb7c34}";
      slug = "foxy-gestures";
      localConfigFile = ./foxy-gestures.json;
    };
    working-vpn = {
      id = "{6b1d4418-eff5-4ede-ae7c-950ab7476049}";
      slug = "workingvpn";
    };
    youtube-nonstop = {
      id = "{0d7cafdd-501c-49ca-8ebb-e3341caaa55e}";
      slug = "youtube-nonstop";
    };
    cookie-editor = {
      id = "{c3c10168-4186-445c-9c5b-63f12b8e2c87}";
      slug = "cookie-editor";
    };
    auto-claim-twitch-points = {
      id = "{8e1ef2d7-d78f-47f9-9b69-c2806eb534fc}";
      slug = "auto-claim-twitch-chnnl-points";
    };
    return-youtube-dislike = {
      id = "{762f9885-5a13-4abd-9c77-433dcd38b8fd}";
      slug = "return-youtube-dislikes";
    };
    foxyproxy = {
      id = "foxyproxy@eric.h.jung";
      slug = "foxyproxy-standard";
    };
    tab-unloader = {
      id = "tab-unloader-we@afnankhan";
      slug = "tab-unloader-we";
    };
    ttv-ad-blocker = {
      id = "{71e91189-9cd2-4e46-895d-bcc38f0053c4}";
      slug = "ttv-ab-twitch-ad-blocker";
    };
    wakatime = {
      id = "addons@wakatime.com";
      slug = "wakatimes";
    };
  };

  # Workspaces
  spaces = [
    {
      name = "";
      icon = "🔴";
    }
    {
      name = "";
      icon = "🟠";
    }
    {
      name = "";
      icon = "🟡";
    }
    {
      name = "";
      icon = "🟢";
    }
    {
      name = "";
      icon = "🔵";
    }
    {
      name = "";
      icon = "🟣";
    }
  ];

  # Essentials
  essentials = [
    "https://mail.google.com/mail/u/0/"
    "https://mail.google.com/mail/u/1/"
    "https://calendar.google.com/calendar/u/0/r"
    "https://www.youtube.com/"
    "https://music.youtube.com/"
  ];

  # Declarative Zen Mods
  mods = {
    add-new-tab-urlbar-icon = "378ba8b9-cd36-45f5-88df-595df5288795";
    better-unloaded-tabs = "f7c71d9a-bce2-420f-ae44-a64bd92975ab";
    custom-menubutton = "5bb07b6e-c89f-4f4a-a0ed-e483cc535594";
    superpins = "ad97bb70-0066-4e42-9b5f-173a5e42c6fc";
    vertical-split-tab-groups = "4c2bec61-7f6c-4e5c-bdc6-c9ad1aba1827";
    lean = "1e86cf37-a127-4f24-b919-d265b5ce29a0";
    bleeding-corners-fix = "7d577b21-4685-4db2-bb17-d39d08eec199";
  };
}
