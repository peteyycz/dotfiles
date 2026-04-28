{ ... }:
{
  flake.modules.homeManager.packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        networkmanagerapplet

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
        mpv
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
        watchman
      ];
    };
}
