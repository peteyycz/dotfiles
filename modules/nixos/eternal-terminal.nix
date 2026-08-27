{ ... }:
{
  flake.modules.nixos.eternal-terminal = {
    # etserver listens on TCP 2022. Not exposed publicly — the firewall stays
    # closed and it is reachable only over the tailnet via
    # networking.firewall.trustedInterfaces (see tailscale.nix). The client
    # bootstraps a session over SSH (Tailscale SSH on the tailnet), then
    # connects here directly for a reconnecting, scrollback-preserving shell
    # that survives laptop suspend/resume and network changes.
    services.eternal-terminal.enable = true;
  };
}
