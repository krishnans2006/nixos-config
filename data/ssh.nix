{
  sshConfig = {
    "*" = {
      AddKeysToAgent = "yes";
      # ControlMaster = "auto";
      # ControlPath = "~/.ssh/master-%r@%h:%p";
      # ControlPersist = "3s";
    };
    "ews" = {
      HostName = "linux.ews.illinois.edu";
      IdentityFile = "~/.ssh/id_ed25519";
      User = "ks128";
      ForwardX11 = true;
      ForwardX11Trusted = true;
      RequestTTY = "yes";
      RemoteCommand = "/bin/zsh";
    };
    "ews-391" = {
      HostName = "eceb-3026.ews.illinois.edu";
      IdentityFile = "~/.ssh/id_ed25519";
      User = "ks128";
      ForwardX11 = true;
      ForwardX11Trusted = true;
      RequestTTY = "yes";
      RemoteCommand = "/bin/zsh";
    };
    "ncsa-delta" = {
      HostName = "login.delta.ncsa.illinois.edu";
      User = "krishnans2006";
      ForwardX11 = true;
    };
    "oracle-amp" = {
      HostName = "150.136.13.65";
      IdentityFile = "~/.ssh/id_ed25519";
      User = "ubuntu";
    };
    "oracle-vm1" = {
      HostName = "150.136.122.56";
      IdentityFile = "~/.ssh/id_ed25519";
      User = "ubuntu";
    };
    "oracle-vm2" = {
      HostName = "129.153.27.23";
      IdentityFile = "~/.ssh/id_ed25519";
      User = "ubuntu";
    };
    "piserver.local" = {
      HostName = "piserver.local";
      User = "krishnan";
    };
    "tjfridge" = {
      HostName = "fridge.tjhsst.edu";  # 198.38.23.53
      User = "kshankar";
    };
    "tjras" = {
      HostName = "ras2.tjhsst.edu";  # 198.38.18.201
      User = "2024kshankar";
    };
    "janux-spr5" = {
      HostName = "janux-spr5.csl.illinois.edu";
      User = "ks128";
    };
    "janux-emr2" = {
      HostName = "janux-emr2-01.csl.illinois.edu";
      User = "ks128";
    };
    "janux-emr3" = {
      HostName = "janux-emr3-02.csl.illinois.edu";
      User = "ks128";
    };
    "janux-08" = {
      HostName = "janux-00.csl.illinois.edu";
      User = "ks128";
    };
    "janux-gnr3" = {
      HostName = "janux-gnr3.csl.illinois.edu";
      User = "ks128";
    };
    "janux-styx" = {
      HostName = "csl-213-04.csl.illinois.edu";
      User = "ks128";
    };
  };
}
