# welcome to my dotfiles!

Personal dotfiles for two setups:

- **NixOS** — homelab / laptop / personal dev machine
- **Arch / Fedora** — Framework 16 laptop

Config files are symlinked into `$HOME` with [GNU stow](https://www.gnu.org/software/stow/) (see `stowrc.sh`). Some setup lives in shell scripts, some in ansible.

## Layout

| Path | Contents |
| --- | --- |
| `.config/` | Hyprland / Wayland config (forked from [JaKooLit](https://github.com/JaKooLit)), and more |
| `nvim/` | Neovim — transparency lua + LazyVim (forked from omakub) |
| `rc/` | shell rc files (zsh / bash, omakub) |
| `nixos_old/` | previous NixOS host configs (biacws01, homelab, hp, system, users) — being migrated to `nixos/` |
| `arch.sh` | Arch setup for Framework 16 |
| `fedora.sh` | Fedora setup |
| `bluetooth-dualboot.py` | pair Bluetooth devices once across Windows + Linux (see `BLUETOOTH.md`) |

## To do

- finish migrating NixOS configs from `nixos_old/` into `nixos/`
- Framework PAM files
- Framework power settings (hibernate-then-suspend)
- omakub elements (fzf, alacritty, zellij)
- see ArchWiki Framework notes; set regulatory domain

## Shell copy/paste

- `Ctrl-A` — jump to the beginning of the line
- `Ctrl-K` — kill (cut) the rest of the line
- `Ctrl-Y` — yank (paste) it back
