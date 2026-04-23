{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    peon-ping.url = "github:PeonPing/peon-ping";
    caldy = {
      url = "github:peteyycz/caldy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, peon-ping, caldy, ... }:
    let
      system = "x86_64-linux";
      mkHost = name: { isLaptop ? false, primaryMonitors ? [ ] }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit isLaptop primaryMonitors; };
        modules = [
          ./hosts/${name}/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit isLaptop primaryMonitors; };
            home-manager.users.peteyycz = import ./home;
            home-manager.sharedModules = [
              peon-ping.homeManagerModules.default
              caldy.homeManagerModules.default
              {
                programs.peon-ping.package = peon-ping.packages.${system}.default;
                home.packages = [ peon-ping.packages.${system}.default ];
                programs.caldy = {
                  enable = true;
                  settings = {
                    week = {
                      show_weekend = false;
                      start_day = "monday";
                    };
                    theme = {
                      bg         = "#282828";
                      surface    = "#3c3836";
                      surface_hi = "#504945";
                      fg         = "#ebdbb2";
                      fg_muted   = "#a89984";
                      accent     = "#fabd2f";
                      danger     = "#fb4934";
                    };
                  };
                };
              }
            ];
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        t440p = mkHost "t440p" {
          isLaptop = true;
          primaryMonitors = [ "HDMI-A-1" "DP-1" "DP-2" "eDP-1" ];
        };
        t14g2 = mkHost "t14g2" {
          isLaptop = true;
          primaryMonitors = [ "DP-1" "DP-2" "DP-3" "HDMI-A-1" "eDP-1" ];
        };
        homepc = mkHost "homepc" {
          primaryMonitors = [ "DP-1" "DP-2" "DP-3" "HDMI-A-1" ];
        };
      };
    };
}
