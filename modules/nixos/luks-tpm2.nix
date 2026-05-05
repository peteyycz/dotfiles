{ ... }:
{
  flake.modules.nixos.luks-tpm2 =
    { ... }:
    {
      boot.initrd.systemd.enable = true;

      boot.initrd.luks.devices.cryptroot = {
        allowDiscards = true;
        crypttabExtraOpts = [
          "tpm2-device=auto"
          "tpm2-measure-pcr=yes"
        ];
      };
    };
}
