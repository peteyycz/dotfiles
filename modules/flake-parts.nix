{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.nix-wrapper-modules.flakeModules.wrappers
  ];
}
