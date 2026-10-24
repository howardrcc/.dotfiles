# Dotfiles

**English** · [Nederlands](README.nl.md)

Personal dotfiles and machine configuration for two setups:

- **NixOS**: the main desktop / gaming machine, fully declarative as a flake in [`nixos/`](nixos/). Hyprland with [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell), Sunshine/Moonlight game streaming, Home Manager for the user environment.
- **Arch / Fedora**: Framework 16 laptop. Config files are symlinked into `$HOME` with [GNU stow](https://www.gnu.org/software/stow/); the rest is a set of setup scripts and notes.

There is no test suite or CI. A change is verified by building the flake (see below).

## Repository layout

| Path | Contents |
| --- | --- |
| [`nixos/`](nixos/) | **Current NixOS flake** (host `nixos`, NixOS 25.11): `configuration.nix` (system), `home.nix` (Home Manager), `pkgs/` (custom packages), `sunshine/` (streaming helper), `docs/` |
| [`nixos_old/`](nixos_old/) | Earlier per-host configs (`biacws01`, `homelab`, `hp`, `system`, `users`) that use channels instead of flakes. Kept for reference while being migrated into `nixos/` |
| `.config/` | Hyprland / Wayland config for the Arch / Fedora laptop (forked from [JaKooLit](https://github.com/JaKooLit)), plus a minimal `nvim/init.vim` |
| `nvim/` | Neovim extras for a [LazyVim](https://www.lazyvim.org/) setup (transparent background, from [omakub](https://github.com/basecamp/omakub)); stow package |
| `rc/` | `.zshrc`, `.bashrc` and fzf bindings (omakub-derived); stow package |
| `stowrc.sh` | Moves existing rc files to `*.bak`, then runs `stow -S rc` |
| `arch.sh`, `arch-bt.sh`, `fedora.sh`, `fedora-terminal.sh`, `app-neovim.sh`, `proxmox.sh` | Setup notes for the non-NixOS machines. Mostly commented-out checklists rather than idempotent installers, so read them before running |
| `bluetooth-dualboot.py` | Pair a Bluetooth device once and use it on both Windows and Linux (see [`BLUETOOTH.md`](BLUETOOTH.md)) |
| `keyboard-shortcuts.md` | Cheat sheet: vim, fzf, tmux, shell |
| `CLAUDE.md` | Guidance for Claude Code when working in this repo |

## NixOS

The flake lives in `nixos/`, not at the repo root. The repo is expected at `~/.dotfiles`.

```bash
# Apply the configuration (zsh alias: rebuild)
sudo nixos-rebuild switch --flake ~/.dotfiles/nixos

# Bump all flake inputs, then apply (zsh alias: update)
nix flake update --flake ~/.dotfiles/nixos && sudo nixos-rebuild switch --flake ~/.dotfiles/nixos

# Build without activating: the check to run before committing
nix build --no-link ~/.dotfiles/nixos#nixosConfigurations.nixos.config.system.build.toplevel

# Lint
statix check ~/.dotfiles/nixos
```

> **Flakes only see git-tracked files.** `git add` new or renamed files (including binaries such as `nixos/1920x1080.bin`) before rebuilding, or Nix will not find them.

### What it sets up

- **Desktop**: SDDM autologin into Hyprland, DankMaterialShell for the launcher, lock screen, notifications and audio controls, Bibata cursor theme, Ghostty.
- **Game streaming**: Sunshine (from nixpkgs-unstable) with declared apps, Steam Remote Play, a forced virtual display on DP-1 via an injected EDID, and a helper that resizes the monitor to the Moonlight client's resolution and restores it afterwards. See [`nixos/docs/remote-gaming.md`](nixos/docs/remote-gaming.md).
- **Hardware fixes**: automatic unmute for a Focusrite Scarlett interface on plug-in, and a network reset of `enp5s0` after resume.
- **Networking**: NetworkManager, Tailscale, OpenSSH (key-only), Syncthing. The firewall is deliberately disabled on this host.
- **Development**: zsh with oh-my-zsh, direnv, git/gh, Neovim with the tooling LazyVim expects, Claude Code and Codex CLI, and the T3 Code desktop app.
- **Agent skills**: skills from the `mattpocock-skills` and `poteto-plugins` flake inputs are linked into both `~/.claude/skills` and `~/.codex/skills`.

### Updating T3 Code

T3 Code is packaged from the upstream AppImage in `nixos/pkgs/t3code.nix`:

```bash
./nixos/pkgs/update-t3code.sh --check     # is there a newer release?
./nixos/pkgs/update-t3code.sh             # bump version + hash (stable channel)
./nixos/pkgs/update-t3code.sh preview     # or follow preview / nightly
```

## Arch / Fedora

```bash
cd ~/.dotfiles && ./stowrc.sh      # backs up existing rc files, then symlinks rc/ into $HOME
stow -S nvim                       # other packages are stowed the same way
```

The Hyprland setup in `.config/hypr/` is a fork of JaKooLit's dotfiles and is **not** used on the NixOS machine, where Hyprland is configured from `nixos/home.nix`.

## To do

- Finish migrating the NixOS configs from `nixos_old/` into `nixos/`
- Framework: PAM files
- Framework: power settings (hibernate-then-suspend)
- Remaining omakub elements (fzf, alacritty, zellij)
- Read the ArchWiki Framework notes; set the regulatory domain
- Remote gaming: Wake-on-LAN through Proxmox, headless streaming, lock after autologin (see `nixos/docs/remote-gaming.md`)

## Credits

[JaKooLit](https://github.com/JaKooLit) (Hyprland dotfiles), [omakub](https://github.com/basecamp/omakub), [LazyVim](https://www.lazyvim.org/), [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell), [Matt Pocock's skills](https://github.com/mattpocock/skills), [poteto/plugins](https://github.com/poteto/plugins), [T3 Code](https://t3.codes).

## License

[MIT](LICENSE)
