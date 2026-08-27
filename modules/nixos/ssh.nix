{ config, ... }:
{
  flake.modules.nixos.ssh =
    { ... }:
    {
      services.openssh = {
        enable = true;
        openFirewall = true;
        settings = {
          # "Both" key and password auth selected.
          PasswordAuthentication = true;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
        };
      };

      users.users.${config.username}.openssh.authorizedKeys.keys = [
        # Public keys allowed to log in as ${config.username}.
        # Add the key of each machine you'll connect FROM. On that machine run:
        #   cat ~/.ssh/id_ed25519.pub
        # and paste the line below, e.g.:
        #   "ssh-ed25519 AAAA... you@laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMgu1itELlCptDaMosOTnHbMW1NTRQNLErX10Bejpy2r peteyycz@homepc"
      ];
    };
}
