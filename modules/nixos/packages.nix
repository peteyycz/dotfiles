{ ... }:
{
  flake.modules.nixos.packages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      pavucontrol

      unzip

      stow
      git
      wl-clipboard

      google-chrome
      slack
      nautilus
      nautilus-open-any-terminal
      file-roller
      sushi
      brightnessctl
      wev
      openssl
      tree-sitter
      pam_u2f
      jdk21
      maven
      python3
      psmisc
    ];
  };
}
