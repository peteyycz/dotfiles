{ ... }:
{
  flake.modules.homeManager.packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gcc
        gnumake

        nodejs_24
        go

        rustc
        cargo
        rustfmt
        clippy
        rust-analyzer

        nixd
        nixfmt
        coturn

        pandoc

        kubectl
        kubernetes-helm

        awscli2
        opentofu
        terraform
        terragrunt
        pomerium-cli
        vault
        mongosh
        mongodb-tools

        mediainfo
        imv
        vlc
        spotify

        gh
        ghq
        piper-tts

        libwebp
        btop
        fd
        eza

        postgresql

        ruby
        kamal

        beam.packages.erlang_27.erlang
        beam.packages.erlang_27.elixir_1_18
        inotify-tools

        # nixpkgs ships 2025.9-b175 (404'd upstream, eval license refused) on jdk21.
        # YourKit 2026.3 launcher passes --sun-misc-unsafe-memory-access=allow which needs JDK 23+.
        # Pin to current build and bump the JRE.
        ((yourkit-java.override { jdk21 = pkgs.jdk25; }).overrideAttrs (_: rec {
          version = "2026.3.157";
          src = pkgs.fetchzip {
            url = "https://download.yourkit.com/yjp/${version}/YourKit-Java-Profiler-${version}-x64.zip";
            hash = "sha256-pc+Z7dMEhinNtqssTTumn3IKZEolbKlKtckMp4KkX+g=";
          };
        }))
      ];
    };
}
