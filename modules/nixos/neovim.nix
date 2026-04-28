{ ... }:
{
  flake.modules.nixos.neovim = {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
