{ inputs, config, ... }:
let
  fonts = config.fontFamilies;
  p = inputs.hare.lib.glass;

  # libadwaita honors @define-color overrides from gtk.css; non-Adwaita widgets
  # still need direct selectors. Alphas (hex byte suffix): 0x4d ≈ 0.30 matches
  # the hare bar / rofi, 0x66 ≈ 0.40 for headerbar, 0xcc ≈ 0.80 for the content
  # view (kept opaque-ish so file lists stay readable over busy wallpapers).
  glassCss = ''
    @define-color accent_bg_color #${p.accent};
    @define-color accent_color #${p.accent};
    @define-color accent_fg_color #${p.accentInk};

    @define-color window_bg_color alpha(#${p.bg}, 0.30);
    @define-color window_fg_color #${p.fg};

    @define-color view_bg_color alpha(#${p.surface}, 0.80);
    @define-color view_fg_color #${p.fg};

    @define-color headerbar_bg_color alpha(#${p.bg}, 0.40);
    @define-color headerbar_fg_color #${p.fg};
    @define-color headerbar_border_color alpha(#${p.fg}, 0.10);

    @define-color sidebar_bg_color alpha(#${p.bg}, 0.35);
    @define-color sidebar_fg_color #${p.fg};

    @define-color card_bg_color alpha(#${p.surface}, 0.70);
    @define-color card_fg_color #${p.fg};

    @define-color popover_bg_color alpha(#${p.surface}, 0.93);
    @define-color popover_fg_color #${p.fg};

    @define-color destructive_bg_color #${p.error};
    @define-color destructive_fg_color #${p.fg};

    @define-color dialog_bg_color alpha(#${p.bg}, 0.55);
    @define-color dialog_fg_color #${p.fg};

    /* Direct selector fallbacks — some widget trees skip the @define-color
       lookup and paint solid bg. */
    window,
    window.background,
    .background {
      background-color: alpha(#${p.bg}, 0.30);
      color: #${p.fg};
    }

    headerbar,
    .titlebar {
      background-color: alpha(#${p.bg}, 0.40);
      background-image: none;
      color: #${p.fg};
      box-shadow: none;
      border-bottom: 1px solid alpha(#${p.fg}, 0.08);
    }

    .sidebar,
    .navigation-sidebar,
    placessidebar {
      background-color: alpha(#${p.bg}, 0.35);
      color: #${p.fg};
    }
  '';
in
{
  flake.modules.homeManager.gtk =
    { ... }:
    {
      gtk = {
        enable = true;
        font = {
          name = fonts.sans;
          size = 11;
        };
        gtk3.extraCss = glassCss;
        gtk4.extraCss = glassCss;
      };
    };
}
