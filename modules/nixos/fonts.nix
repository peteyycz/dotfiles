{ ... }:
{
  flake.modules.nixos.fonts = { pkgs, ... }: {
    fonts.packages = with pkgs.nerd-fonts; [ symbols-only jetbrains-mono ];
  };
}
