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

        claude-code

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
        vault-bin
        mongosh
        mongodb-tools
        redis

        mediainfo
        imv
        vlc

        gh
        ghq
        piper-tts

        libwebp
        btop
        fd
        eza
        xxd

        postgresql

        ruby
        kamal

        beam.packages.erlang_27.erlang
        beam.packages.erlang_27.elixir_1_18
        inotify-tools
      ];
    };
}
