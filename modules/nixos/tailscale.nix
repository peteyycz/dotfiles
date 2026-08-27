{ ... }:
{
  flake.modules.nixos.tailscale = {
    services.tailscale = {
      enable = true;
      # Opens the UDP port Tailscale uses for direct connections (falls back to
      # DERP relays if it can't). No router port-forwarding required either way.
      openFirewall = true;
    };

    # Trust anything arriving over the tailnet: every listening port becomes
    # reachable from our other Tailscale devices (e.g. dev servers on homepc
    # hit from the laptop at http://homepc:PORT). Only authenticated nodes on
    # our tailnet can reach tailscale0 — the public internet cannot. Note this
    # exposes ALL ports to the tailnet, so don't bind untrusted services (DBs)
    # to 0.0.0.0 unless you mean to share them.
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };
}
