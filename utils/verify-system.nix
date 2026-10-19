{ lib, osConfig ? null, option, type ? "required", reason ? null }:

with lib;

# Utility helper for Home Manager modules that interact with or depend on
# system-level NixOS configuration (osConfig).
#
# Arguments:
#   lib: nixpkgs lib
#   osConfig: The system configuration passed to the home module (attrset on NixOS, null on standalone).
#   option: Option path to check (e.g. "modules.tailscale.enable" or [ "modules" "tailscale" "enable" ]).
#   type: Verification requirement mode:
#     - "required": System option must be true.
#     - "optional": Warning if false or non-NixOS, but does not block evaluation.
#     - "forbidden": System option must be false (or host non-NixOS).
#   reason: Optional string describing why the option is required/recommended.
#
# Returns an attrset:
#   satisfied: bool - true if the system option condition is met.
#   apply: function (subConfig -> attrset) - merges assertions and warnings into the given module config.
#
# Usage:
#   let
#     verify-system = import (root + "/utils/verify-system.nix") {
#       inherit lib osConfig;
#       option = "modules.aethersdr.enable";
#       type = "optional";
#       reason = "to open required firewall ports for FlexRadio / AetherSDR";
#     };
#   in
#   config = mkIf cfg.enable (verify-system.apply {
#     home.packages = [ aethersdr ];
#   });

let
  isNixOS = osConfig != null;

  attrPath = if isList option then option else splitString "." option;
  optionName = if isString option then option else concatStringsSep "." option;

  optionValue = if isNixOS then attrByPath attrPath false osConfig else null;

  reasonSuffix = if reason != null then " (${reason})" else "";

  satisfied =
    if type == "required" then
      isNixOS && optionValue == true
    else if type == "forbidden" then
      !isNixOS || optionValue == false
    else if type == "optional" then
      isNixOS && optionValue == true
    else
      throw "utils/verify-system.nix: invalid verification type '${type}'. Expected 'required', 'optional', or 'forbidden'.";

  msgNixOS =
    if type == "required" then
      "${optionName} is not enabled in the NixOS system configuration${reasonSuffix}."
    else if type == "forbidden" then
      "${optionName} must be disabled in the NixOS system configuration${reasonSuffix}."
    else
      "${optionName} is not enabled in the NixOS system configuration${reasonSuffix}. Some functionality may be limited.";

  msgNonNixos =
    if type == "required" then
      "${optionName} is required by this home module, but cannot be configured on a non-NixOS host${reasonSuffix}."
    else if type == "forbidden" then
      ""  # Non-NixOS always satisfies forbidden
    else
      "Host OS is not NixOS; ${optionName} cannot be configured by Home Manager${reasonSuffix}. Ensure any host system prerequisites are configured manually.";

  activeMessage = if isNixOS then msgNixOS else msgNonNixos;

  assertions = optional (type != "optional" && !satisfied) {
    assertion = false;
    message = activeMessage;
  };

  warnings = optional (type == "optional" && !satisfied) activeMessage;

  apply = subConfig: mkMerge [
    { inherit assertions warnings; }
    subConfig
  ];
in
{ inherit satisfied apply; }
