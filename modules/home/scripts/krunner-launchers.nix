{ ... }:
{
  flake.modules.homeManager.krunner-launchers =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.peteyycz) terminal codeRoot scriptsDir;

      pyEnv = pkgs.python3.withPackages (ps: [
        ps.dbus-python
        ps.pygobject3
      ]);

      # KRunner D-Bus runner: lists *.sh files in scriptsDir and runs the
      # picked one detached. Invoked via Meta+R (see plasma.nix). Registered
      # via the xdg.dataFile entries below.
      scriptsKrunner = pkgs.writeScriptBin "scripts-krunner" ''
        #!${pyEnv}/bin/python3
        import glob
        import os
        import subprocess

        import dbus
        import dbus.service
        from dbus.mainloop.glib import DBusGMainLoop
        from gi.repository import GLib

        os.environ["PATH"] = (
            os.path.expanduser("~/.nix-profile/bin")
            + ":/run/current-system/sw/bin:"
            + os.environ.get("PATH", "")
        )

        SERVICE = "org.peteyycz.scriptsrunner"
        OBJPATH = "/scriptsrunner"
        IFACE = "org.kde.krunner1"
        SCRIPTS = os.path.expandvars("${scriptsDir}")


        def scripts():
            out = []
            for p in sorted(glob.glob(os.path.join(SCRIPTS, "*.sh"))):
                out.append((os.path.basename(p)[:-3], p))
            return out


        class Runner(dbus.service.Object):
            def __init__(self):
                bus = dbus.service.BusName(SERVICE, dbus.SessionBus())
                dbus.service.Object.__init__(self, bus, OBJPATH)

            @dbus.service.method(IFACE, in_signature="s",
                                 out_signature="a(sssida{sv})")
            def Match(self, query):
                q = query.strip().lower()
                trigger = q.startswith("run")
                if trigger:
                    q = q[3:].strip()
                # Empty query = list everything (single-runner-mode entry point).
                show_all = not q
                out = []
                for name, path in scripts():
                    nl = name.lower()
                    if show_all:
                        exact = False
                    elif trigger:
                        if q not in nl:
                            continue
                        exact = q == nl
                    else:
                        # Only fire in regular KRunner with "run" prefix,
                        # to avoid spamming results with script names.
                        continue
                    out.append((path, name, "utilities-terminal",
                                100,
                                1.0 if exact else 0.9,
                                {"subtext": "script"}))
                return out

            @dbus.service.method(IFACE, in_signature="ss", out_signature="")
            def Run(self, match_id, action_id):
                # match_id is the absolute path to the .sh file.
                subprocess.Popen(
                    ["sh", match_id],
                    start_new_session=True,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )

            @dbus.service.method(IFACE, out_signature="a(sss)")
            def Actions(self):
                return []


        DBusGMainLoop(set_as_default=True)
        Runner()
        GLib.MainLoop().run()
      '';

      # KRunner D-Bus runner: lists git repos under codeRoot and starts a
      # tmuxw session in the picked one, then focuses a terminal attached to
      # that session. Invoked via Meta+Shift+W (see plasma.nix).
      projectsKrunner = pkgs.writeScriptBin "projects-krunner" ''
        #!${pyEnv}/bin/python3
        import os
        import subprocess

        import dbus
        import dbus.service
        from dbus.mainloop.glib import DBusGMainLoop
        from gi.repository import GLib

        os.environ["PATH"] = (
            os.path.expanduser("~/.nix-profile/bin")
            + ":/run/current-system/sw/bin:"
            + os.environ.get("PATH", "")
        )

        SERVICE = "org.peteyycz.projectsrunner"
        OBJPATH = "/projectsrunner"
        IFACE = "org.kde.krunner1"
        TERMINAL = "${terminal}"
        SRC = os.path.expandvars("${codeRoot}")


        def projects():
            # Every directory that directly contains a .git entry, mindepth 2 to
            # skip codeRoot/.git itself, path returned as "org/repo" relative.
            try:
                out = subprocess.run(
                    ["find", SRC, "-mindepth", "2", "-type", "d",
                     "-name", ".git", "-prune", "-printf", "%h\\n"],
                    capture_output=True, text=True, timeout=5,
                ).stdout
            except (FileNotFoundError, subprocess.TimeoutExpired):
                return []
            items = []
            for line in out.splitlines():
                if not line.strip():
                    continue
                rel = line[len(SRC) + 1:] if line.startswith(SRC + "/") else line
                items.append((rel, line))
            return sorted(items, key=lambda x: x[0].lower())


        def subtext(path):
            if not os.path.isdir(os.path.join(path, ".git")):
                return "project"

            def git(*a):
                return subprocess.run(
                    ["git", "-C", path, *a],
                    capture_output=True, text=True,
                ).stdout.strip()

            branch = git("branch", "--show-current")
            if not branch:
                return "project"
            dirty = " *" if git("status", "--porcelain") else ""
            return "#" + branch + dirty


        class Runner(dbus.service.Object):
            def __init__(self):
                bus = dbus.service.BusName(SERVICE, dbus.SessionBus())
                dbus.service.Object.__init__(self, bus, OBJPATH)

            @dbus.service.method(IFACE, in_signature="s",
                                 out_signature="a(sssida{sv})")
            def Match(self, query):
                q = query.strip().lower()
                trigger = q.startswith("cd")
                if trigger:
                    q = q[2:].strip()
                show_all = not q
                out = []
                for rel, path in projects():
                    base = os.path.basename(rel).lower()
                    rl = rel.lower()
                    if show_all:
                        exact = False
                    elif trigger:
                        if q not in rl and q not in base:
                            continue
                        exact = q == base
                    else:
                        continue
                    out.append((path, rel, "folder-symbolic",
                                100,
                                1.0 if exact else 0.9,
                                {"subtext": subtext(path)}))
                return out

            @dbus.service.method(IFACE, in_signature="ss", out_signature="")
            def Run(self, match_id, action_id):
                # match_id is the absolute project path.
                if not os.path.isdir(os.path.join(match_id, ".git")):
                    return
                session = os.path.basename(match_id)
                if subprocess.run(
                    ["tmux", "has-session", "-t", session]
                ).returncode != 0:
                    subprocess.run(
                        ["tmuxw", "--detach"], cwd=match_id
                    )
                if subprocess.run(["tmux-focus", session]).returncode != 0:
                    subprocess.Popen([TERMINAL, "tmux", "attach", "-t", session])

            @dbus.service.method(IFACE, out_signature="a(sss)")
            def Actions(self):
                return []


        DBusGMainLoop(set_as_default=True)
        Runner()
        GLib.MainLoop().run()
      '';
    in
    {
      home.packages = [
        scriptsKrunner
        projectsKrunner
      ];

      # Register both runners with KRunner.
      xdg.dataFile."krunner/dbusplugins/scriptsrunner.desktop".text = ''
        [Desktop Entry]
        Type=Service
        Name=Scripts
        Comment=Run scripts from ${scriptsDir}
        Icon=utilities-terminal
        X-KDE-ServiceTypes=Plasma/Runner
        X-KDE-PluginInfo-Name=scriptsrunner
        X-KDE-PluginInfo-Version=1.0
        X-KDE-PluginInfo-EnabledByDefault=true
        X-Plasma-API=DBus
        X-Plasma-DBusRunner-Service=org.peteyycz.scriptsrunner
        X-Plasma-DBusRunner-Path=/scriptsrunner
      '';

      xdg.dataFile."krunner/dbusplugins/projectsrunner.desktop".text = ''
        [Desktop Entry]
        Type=Service
        Name=Projects
        Comment=Open a project under ${codeRoot} in tmuxw
        Icon=folder-symbolic
        X-KDE-ServiceTypes=Plasma/Runner
        X-KDE-PluginInfo-Name=projectsrunner
        X-KDE-PluginInfo-Version=1.0
        X-KDE-PluginInfo-EnabledByDefault=true
        X-Plasma-API=DBus
        X-Plasma-DBusRunner-Service=org.peteyycz.projectsrunner
        X-Plasma-DBusRunner-Path=/projectsrunner
      '';

      # Plasma 6 requires D-Bus activation files so the runners spawn on demand.
      xdg.dataFile."dbus-1/services/org.peteyycz.scriptsrunner.service".text = ''
        [D-BUS Service]
        Name=org.peteyycz.scriptsrunner
        Exec=${scriptsKrunner}/bin/scripts-krunner
      '';

      xdg.dataFile."dbus-1/services/org.peteyycz.projectsrunner.service".text = ''
        [D-BUS Service]
        Name=org.peteyycz.projectsrunner
        Exec=${projectsKrunner}/bin/projects-krunner
      '';
    };
}
