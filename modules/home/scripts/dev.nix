{ ... }:
{
  flake.modules.homeManager.dev-scripts = { pkgs, ... }: {
    home.packages = with pkgs; [
      (writeShellScriptBin "run-server" ''
        if [ -f package.json ]; then
          if grep -q '"dev"' package.json; then
            exec npm run dev
          elif grep -q '"start"' package.json; then
            exec npm start
          fi
        elif [ -f mix.exs ]; then
          exec mix phx.server
        fi
      '')
      (writeShellScriptBin "start-accessories" ''
        if [ -f docker-compose.yml ] || [ -f docker-compose.yaml ]; then
          docker compose up -d
        fi
      '')
    ];
  };
}
