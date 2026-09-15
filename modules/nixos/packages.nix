{ ... }:
{
  flake.modules.nixos.packages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        pavucontrol

        unzip

        stow
        git
        wl-clipboard

        google-chrome
        obsidian
        rustdesk
        slack
        nautilus
        nautilus-open-any-terminal
        file-roller
        sushi
        brightnessctl
        wev
        openssl
        dnsutils
        tree-sitter
        pam_u2f
        jdk21
        maven
        python3
        psmisc
        parted
        lshw

        ansible
        qemu
        mosquitto
      ];
    };
}
