{ config, ... }:
{
  flake.modules.nixos.nordvpn = {
    # Ships both the `nordvpn` CLI and the `nordvpn-gui` app, and runs the
    # nordvpnd daemon behind a socket in /run/nordvpn.
    services.nordvpn.enable = true;

    # The kill-switch sends replies back through the tunnel interface rather
    # than the one the route table would pick for the source address, so
    # strict reverse-path filtering drops them as martians. Upstream requires
    # this relaxed whenever the firewall is on — it is, via tailscale.nix.
    networking.firewall.checkReversePath = "loose";

    # The CLI reaches the daemon through a socket owned by the nordvpn group;
    # without this every `nordvpn` command fails with a permission error.
    users.users.${config.username}.extraGroups = [ "nordvpn" ];
  };
}
