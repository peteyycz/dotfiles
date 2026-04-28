{ ... }:
{
  flake.modules.homeManager.options = { lib, ... }: {
    options.peteyycz = {
      isLaptop = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      primaryMonitors = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      hyprlandExtraBinds = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      hyprlandExtraWindowRules = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      wayleCustomModules = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
        default = { };
        description = ''
          Keyed by custom module id. Value is the Wayle custom-module config
          without the `id` field (id is injected from the attribute name).
        '';
      };
    };
  };
}
