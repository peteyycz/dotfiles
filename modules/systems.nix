{
  # aarch64-darwin so the Mac gets the perSystem outputs too: `nix fmt`, the
  # pre-commit devShell that .envrc loads, and `nix flake check`.
  systems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];
}
