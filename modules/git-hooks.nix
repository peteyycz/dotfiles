{ inputs, ... }:
{
  imports = [ inputs.git-hooks.flakeModule ];

  perSystem =
    { config, pkgs, ... }:
    {
      pre-commit.settings.hooks.nixfmt-rfc-style.enable = true;

      devShells.default = pkgs.mkShell {
        inherit (config.pre-commit.devShell) shellHook;
      };
    };
}
