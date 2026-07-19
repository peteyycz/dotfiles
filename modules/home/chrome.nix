{ ... }:
{
  flake.modules.homeManager.chrome = {
    home.file.".config/chrome-flags.conf".text = ''
      --force-dark-mode
      --enable-features=WebUIDarkMode
      --password-store=gnome-libsecret
    '';

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "com.google.Chrome.desktop";
        "x-scheme-handler/http" = "com.google.Chrome.desktop";
        "x-scheme-handler/https" = "com.google.Chrome.desktop";
        "x-scheme-handler/about" = "com.google.Chrome.desktop";
        "application/xhtml+xml" = "com.google.Chrome.desktop";
      };
    };
  };
}
