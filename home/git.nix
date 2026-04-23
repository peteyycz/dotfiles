{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Peter Czibik";
        email = "dev@peterczibik.com";
      };
      core.editor = "nvim";
      push.default = "current";
      merge.tool = "vimdiff";
      diff = {
        tool = "difftastic";
        external = "difft";
      };
      "difftool \"difftastic\"".cmd = ''difft "$LOCAL" "$REMOTE"'';
      pager.difftool = true;
      pull.rebase = true;
      include.path = "~/.gitconfig-local";
    };

    ignores = [
      # OS related files
      ".DS_Store"

      # IDE
      ".idea"
      "irony"

      # Javascript
      "jsconfig.json"
      "typings"
      "npm-debug.log"
      ".flowconfig"
      "nodemon*"
      "ecosystem.json"

      # Tag files
      "TAGS"
      "GTAGS"
      "GPATH"
      "GRTAGS"
      ".tern-port"
      ".tern-project"

      ".env"

      "*.cert"
      ".phpactor.json"

      "settings.local.json"

      # Fish shell local configuration
      "config.local.fish"

      ".aider*"
    ];

    attributes = [
      "package-lock.json binary"
      "yarn.lock binary"
    ];
  };
}
