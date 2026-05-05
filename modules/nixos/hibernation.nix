{ ... }:
{
  flake.modules.nixos.hibernation =
    { config, ... }:
    {
      assertions = [
        {
          assertion = config.boot.resumeDevice != "";
          message = ''
            nixos.hibernation requires boot.resumeDevice to be set. Import
            nixos.disko (which sets resumeDevice via the swap LV) or set
            boot.resumeDevice manually.
          '';
        }
      ];
    };
}
