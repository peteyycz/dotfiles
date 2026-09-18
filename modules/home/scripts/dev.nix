{ ... }:
{
  flake.modules.homeManager.dev-scripts =
    { pkgs, ... }:
    {
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
            # Foreground: tmuxw gives this its own pane, so the compose logs
            # are the point. Ctrl-C there stops the stack.
            exec docker compose up
          fi
        '')
      ];
    };
}
