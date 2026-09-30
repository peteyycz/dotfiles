{ ... }:
{
  # Home-manager rather than NixOS, so the macOS configuration — which has no
  # NixOS module layer — gets the same editor as the Linux hosts.
  #
  # Deliberately not `programs.neovim`: that module writes
  # ~/.config/nvim/init.lua, and ~/.config/nvim is a symlink to the separate
  # peteyycz/nvim repo, which has an init.lua of its own. So just the binary,
  # plus the vi/vim names that programs.neovim's viAlias/vimAlias used to
  # provide (real symlinks, not shell aliases, so EDITOR=vim resolves too).
  #
  # tree-sitter is the CLI, not the library: nvim-treesitter's `main` branch
  # shells out to `tree-sitter build` for every parser it installs.
  flake.modules.homeManager.neovim =
    { lib, pkgs, ... }:
    {
      home.packages = [
        pkgs.neovim
        pkgs.tree-sitter
        (pkgs.runCommand "neovim-vi-aliases" { } ''
          mkdir -p $out/bin
          ln -s ${lib.getExe pkgs.neovim} $out/bin/vi
          ln -s ${lib.getExe pkgs.neovim} $out/bin/vim
        '')
      ];
    };
}
