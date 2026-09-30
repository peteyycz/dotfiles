{ inputs, config, ... }:
let
  inherit (config.flake.modules) homeManager;

  # The macOS account name, which is not the flake-wide `username`: that one is
  # the NixOS login (users.users.<name>, ssh keys, polkit), while this Mac is
  # provisioned with a corporate account name.
  macUser = "peter.czibik";
in
{
  # Standalone home-manager for the macOS machine. Unlike the NixOS hosts —
  # which get home-manager as a NixOS module and pull in every homeManager
  # module via attrValues — this lists modules explicitly, because a good
  # number of them (plasma, dconf, cursor, autostart, laptop, apps) are
  # Linux-only. Keeping the list explicit avoids having to split the
  # flake.modules.homeManager namespace by platform; modules that are mostly
  # portable (packages, tmux-scripts) instead guard their Linux-only bits with
  # pkgs.stdenv.hostPlatform.isLinux so they can be listed here.
  #
  #   home-manager switch -b hm-bak --flake .#'peter.czibik@bud-mbp-0021'
  #
  # -b matters on the first switch: claude-code writes ~/.claude/settings.json
  # itself on first run, and home-manager aborts rather than clobber a file it
  # does not own. (backupFileExtension is a NixOS/nix-darwin module option; a
  # standalone configuration has only the CLI flag.)
  flake.homeConfigurations."peter.czibik@bud-mbp-0021" =
    inputs.home-manager.lib.homeManagerConfiguration
      {
        # The NixOS hosts inherit allowUnfree from nixos/base.nix through
        # useGlobalPkgs; a standalone configuration builds its own pkgs, so it has
        # to be set here (vault-bin, mongodb-compass, claude-code).
        pkgs = import inputs.nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };

        modules = [
          homeManager.options # base reads peteyycz.wallpaperPath
          homeManager.base
          homeManager.nix
          homeManager.fish
          homeManager.git
          homeManager.tmux
          homeManager.tmux-scripts
          homeManager.neovim
          homeManager.starship
          homeManager.fzf
          homeManager.zoxide
          homeManager.ripgrep
          homeManager.direnv
          homeManager.difftastic
          homeManager.dev-scripts
          homeManager.packages
          homeManager.peon-ping # installs ~/.openpeon/peon.sh, which claude-code hooks call
          homeManager.claude-code

          ({ ... }: {
            home.username = macUser;
            home.homeDirectory = "/Users/${macUser}";
            # Without this the `home-manager` CLI only exists for as long as the
            # `nix run` that bootstrapped the first generation.
            programs.home-manager.enable = true;
          })
        ];
      };
}
