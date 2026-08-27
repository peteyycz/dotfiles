{ config, ... }:
{
  flake.modules.nixos.ssh =
    { ... }:
    {
      services.openssh = {
        enable = true;
        # Interactive logins go through Tailscale SSH (tailscale.nix), which owns
        # port 22 on the tailnet. This sshd listens on 2222 instead so it is NOT
        # shadowed by Tailscale SSH — a genuine key-only break-glass path,
        # reachable over the tailnet (trusted interface) if a bad ACL ever locks
        # Tailscale SSH out. openFirewall = false keeps it off the public net.
        ports = [ 2222 ];
        openFirewall = false;
        settings = {
          # Key-only. No password brute-force surface.
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
        };
      };

      users.users.${config.username}.openssh.authorizedKeys.keys = [
        # Break-glass key for the key-only sshd on port 2222. Kept so a
        # misconfigured tailnet ACL can't lock us out entirely; Tailscale SSH
        # handles normal logins. Reach it with: ssh -p 2222 homepc
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMgu1itELlCptDaMosOTnHbMW1NTRQNLErX10Bejpy2r peteyycz@homepc"
      ];
    };
}
