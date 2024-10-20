{ ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./krishnan-pc-hardware-configuration.nix
    ];

  networking.hostName = "krishnan-pc"; # Define your hostname.
}
