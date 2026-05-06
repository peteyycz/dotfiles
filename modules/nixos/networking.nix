{ ... }:
{
  flake.modules.nixos.networking =
    { pkgs, ... }:
    {
      networking.networkmanager = {
        enable = true;
        plugins = with pkgs; [ networkmanager-openvpn ];
        unmanaged = [
          "interface-name:docker0"
          "interface-name:br-*"
          "interface-name:veth*"
        ];
      };

      networking.extraHosts = ''
        127.0.0.1 local.dev.loveherfilms.com local-api.dev.loveherfilms.com local-admin.dev.loveherfilms.com
        127.0.0.1 local.dev.loveherfeet.com local-api.dev.loveherfeet.com local-admin.dev.loveherfeet.com
        127.0.0.1 local.dev.loveherboobs.com local-api.dev.loveherboobs.com local-admin.dev.loveherboobs.com
        127.0.0.1 local.dev.loveherbutt.com local-api.dev.loveherbutt.com local-admin.dev.loveherbutt.com
        127.0.0.1 local.dev.shelovesblack.com local-api.dev.shelovesblack.com local-admin.dev.shelovesblack.com
        127.0.0.1 admin.local.oktogonmedia.com
      '';
    };
}
