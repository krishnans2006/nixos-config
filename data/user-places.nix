{ home }:

{
  places = [
    {
      "Home" = {
        href = "file://${home}";
        icon = "user-home";
      };
    }
    {
      "Desktop" = {
        href = "file://${home}/Desktop";
        icon = "user-desktop";
      };
    }
    {
      "Documents" = {
        href = "file://${home}/Documents";
        icon = "folder-documents";
      };
    }
    {
      "Downloads" = {
        href = "file://${home}/Downloads";
        icon = "folder-downloads";
      };
    }
    {
      "Music" = {
        href = "file://${home}/Music";
        icon = "folder-music";
      };
    }
    {
      "Pictures" = {
        href = "file://${home}/Pictures";
        icon = "folder-pictures";
      };
    }
    {
      "Videos" = {
        href = "file://${home}/Videos";
        icon = "folder-videos";
      };
    }
    {
      "Trash" = {
        href = "trash:/";
        icon = "user-trash";
      };
    }
    {
      "School" = {
        href = "file://${home}/School";
        icon = "inode-directory";
      };
    }
    {
      "Tech" = {
        href = "file://${home}/Tech";
        icon = "inode-directory";
      };
    }
    {
      "Network" = {
        href = "remote:/";
        icon = "folder-network";
      };
    }
    {
      "Recent Files" = {
        href = "recentlyused:/files";
        icon = "document-open-recent";
      };
    }
    {
      "Recent Locations" = {
        href = "recentlyused:/locations";
        icon = "folder-open-recent";
      };
    }
  ];
}
