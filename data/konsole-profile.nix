{
  name = "Krishnan";
  command = "/run/current-system/sw/bin/zsh";
  font = {
    name = "Hack";
    size = 10;
  };

  extraConfig = {
    General.Parent = "FALLBACK/";
    Scrolling.HistoryMode = "2";
    "Terminal Features".BellMode = "0";
  };
}
