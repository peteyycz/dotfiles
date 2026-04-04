# My dotfiles

Dotfiles and system configuration for my workstation, managed with `stow`, `nix` (home-manager), and `rpm-ostree`.

## Base System

Fedora Sericea 43 (Sway atomic spin).

## Nix (home-manager)

Most dev tools (fish, neovim, tmux, fzf, ripgrep, starship, mise, direnv, etc.) are managed declaratively via home-manager. See [`home.nix`](linux/.config/home-manager/home.nix) for the full list.

Installed with the [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer).

## rpm-ostree layered packages

```
1password
1password-cli
containerd.io
docker-ce
docker-ce-cli
dkms
kernel-devel
stow
wf-recorder
```

> Current deployment also has `dkms` and `kernel-devel` layered.

## Extra repos

Repos added for layered packages and drivers:

| Repo | Purpose |
|------|---------|
| `1password.repo` | 1Password & 1Password CLI |
| `docker-ce.repo` | Docker CE |
| `google-chrome.repo` | Google Chrome (Flatpak/system) |
| `rpmfusion-nonfree-nvidia-driver.repo` | Nvidia driver |
| `rpmfusion-nonfree-steam.repo` | Steam |
| COPR `phracek:PyCharm` | PyCharm |

## Flatpak apps (Flathub)

| App ID | Name |
|--------|------|
| `com.github.finefindus.eyedropper` | Eyedropper |
| `com.google.Chrome` | Google Chrome |
| `com.mongodb.Compass` | MongoDB Compass |
| `com.rustdesk.RustDesk` | RustDesk |
| `com.slack.Slack` | Slack |
| `com.valvesoftware.Steam` | Steam |
| `org.kde.kdenlive` | Kdenlive |
| `org.videolan.VLC` | VLC |


## Other installs

- **Peon-ping** (Claude Code hook) — `curl` install from [peon-ping repo](https://github.com/masonjames/peon-ping)

## Stow usage

Install dotfiles:

```sh
stow -t ~ linux
```

Remove dotfiles:

```sh
stow -D -t ~ linux
```
