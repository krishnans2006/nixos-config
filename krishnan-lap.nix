{ ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./krishnan-lap-hardware-configuration.nix
    ];

  networking.hostName = "krishnan-lap"; # Define your hostname.
}
