{ ... }:
{
  flake.modules.nixos.networking =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      # Vhosts served by the local dev stack. On the machine that RUNS the stack
      # (homepc) these resolve to loopback; other machines set
      # `services.devHosts.target` to homepc's tailnet IP to reach it remotely.
      devDomains = [
        "local.dev.loveherfilms.com local-api.dev.loveherfilms.com local-admin.dev.loveherfilms.com"
        "local.dev.loveherfeet.com local-api.dev.loveherfeet.com local-admin.dev.loveherfeet.com"
        "local.dev.loveherboobs.com local-api.dev.loveherboobs.com local-admin.dev.loveherboobs.com"
        "local.dev.loveherbutt.com local-api.dev.loveherbutt.com local-admin.dev.loveherbutt.com"
        "local.dev.shelovesblack.com local-api.dev.shelovesblack.com local-admin.dev.shelovesblack.com"
        "admin.local.oktogonmedia.com api.local.oktogonmedia.com"
      ];
    in
    {
      options.services.devHosts.target = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "IP the local dev vhosts resolve to (override on remote machines to homepc's tailnet IP).";
      };

      config = {
        networking.networkmanager = {
          enable = true;
          plugins = with pkgs; [ networkmanager-openvpn ];
          unmanaged = [
            "interface-name:docker0"
            "interface-name:br-*"
            "interface-name:veth*"
          ];
        };

        networking.extraHosts = lib.concatMapStringsSep "\n" (
          names: "${config.services.devHosts.target} ${names}"
        ) devDomains;
      };
    };
}
