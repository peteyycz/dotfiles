{ ... }:
{
  # Imported by every host, macOS included, so the split below is what keeps
  # the Mac usable: `common` is everything that builds and makes sense on
  # aarch64-darwin, `linuxOnly` is the rest (Linux-only packages, and GUI bits
  # that come from elsewhere on a Mac).
  flake.modules.homeManager.packages =
    { lib, pkgs, ... }:
    let
      common = with pkgs; [
        gnumake

        nodejs_24
        go

        rustc
        cargo
        rustfmt
        clippy
        rust-analyzer

        ruby
        beam.packages.erlang_27.erlang
        beam.packages.erlang_27.elixir_1_18

        claude-code

        nixd
        nixfmt

        pandoc

        kubectl
        kubectx
        kubernetes-helm

        awscli2
        opentofu
        terraform
        terragrunt
        pomerium-cli
        vault-bin
        kamal

        mongosh
        mongodb-tools
        redis
        postgresql

        gh
        ghq
        eternal-terminal # `et` client for reconnecting shells to homepc

        jq
        htop
        btop
        fd
        eza
        xxd
        uv
        ffmpeg
        libwebp
      ];

      linuxOnly = with pkgs; [
        # A real GCC; on darwin the toolchain is clang and nixpkgs would build
        # gcc from source for it.
        gcc
        coturn
        inotify-tools

        mediainfo
        imv
        vlc
        piper-tts
      ];
    in
    {
      home.packages = common ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux linuxOnly;
    };
}
