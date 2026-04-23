{ config, lib, pkgs, isLaptop, ... }:

let
  wallpaper = pkgs.fetchurl (import ../wallpaper.nix);

  pixie-sddm-theme = pkgs.stdenvNoCC.mkDerivation {
    pname = "pixie-sddm";
    version = "3.0";
    src = pkgs.fetchFromGitHub {
      owner = "xCaptaiN09";
      repo = "pixie-sddm";
      rev = "6f2e77c269c43a455bd81c3ecac1fff796c0253c";
      hash = "sha256-NkjWP/y3kLRjYM0Wr3l7ndbMx3XYxQFXy07C28vrUSU=";
    };
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/sddm/themes/pixie
      cp -r assets components Main.qml metadata.desktop theme.conf LICENSE \
        $out/share/sddm/themes/pixie/
      cp ${wallpaper} $out/share/sddm/themes/pixie/assets/background.jpg
      runHook postInstall
    '';
  };
in
{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "rd.systemd.show_status=auto"
    "rd.udev.log_level=3"
  ];
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.plymouth.enable = true;

  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [ networkmanager-openvpn ];
  };

  networking.extraHosts = ''
    127.0.0.1 local.dev.loveherfilms.com local-api.dev.loveherfilms.com local-admin.dev.loveherfilms.com
    127.0.0.1 local.dev.loveherfeet.com local-api.dev.loveherfeet.com local-admin.dev.loveherfeet.com
    127.0.0.1 local.dev.loveherboobs.com local-api.dev.loveherboobs.com local-admin.dev.loveherboobs.com
    127.0.0.1 local.dev.loveherbutt.com local-api.dev.loveherbutt.com local-admin.dev.loveherbutt.com
    127.0.0.1 local.dev.shelovesblack.com local-api.dev.shelovesblack.com local-admin.dev.shelovesblack.com
    127.0.0.1 admin.local.oktogonmedia.com
  '';

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common = {
        default = "gtk";
        "org.freedesktop.impl.portal.Screenshot" = "wlr";
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
      };
      hyprland = {
        default = lib.mkForce [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
      };
    };
  };

  time.timeZone = "Europe/Budapest";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    wireplumber.extraConfig = lib.mkIf isLaptop {
      "51-hide-hdmi-audio" = {
        "monitor.alsa.rules" = [{
          matches = [{ "node.name" = "~alsa_output\\..*HDMI.*"; }];
          actions.update-props."node.disabled" = true;
        }];
      };
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.tumbler.enable = true;
  services.upower.enable = true;

  services.libinput.enable = true;

  programs.nix-ld.enable = true;
  programs.fish.enable = true;

  systemd.tmpfiles.rules = [
    "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
  ];
  users.users.peteyycz = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
    shell = pkgs.fish;
  };

  virtualisation.docker.enable = true;

  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = [ pixie-sddm-theme ] ++ (with pkgs; [

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
  ]);

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "peteyycz" ];
  };
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
  };

  fonts.packages = with pkgs.nerd-fonts; [ symbols-only jetbrains-mono ];

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "pixie";
      extraPackages = with pkgs.kdePackages; [
        qt5compat
        qtdeclarative
        qtsvg
      ];
    };
  };
}
