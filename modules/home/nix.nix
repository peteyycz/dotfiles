{ ... }:
{
  # The NixOS hosts get this from nixos/base.nix (nix.settings). macOS has no
  # NixOS layer and its /etc/nix/nix.conf carries only build-users-group, so
  # without this every nix command — `home-manager switch` included — has to be
  # run with --extra-experimental-features.
  #
  # Written as a plain file rather than through home-manager's `nix.settings`:
  # that module asserts on `nix.package`, which would pull a second nix into
  # the user profile ahead of the daemon's own client on PATH.
  flake.modules.homeManager.nix =
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      home.file.".config/nix/nix.conf".text = ''
        experimental-features = nix-command flakes
      '';
    };
}
