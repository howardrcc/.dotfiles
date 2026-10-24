# Dotfiles

[English](README.md) · **Nederlands**

Persoonlijke dotfiles en machineconfiguratie voor twee opstellingen:

- **NixOS**: de belangrijkste desktop / gamemachine, volledig declaratief als flake in [`nixos/`](nixos/). Hyprland met [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell), game streaming via Sunshine/Moonlight en Home Manager voor de gebruikersomgeving.
- **Arch / Fedora**: Framework 16 laptop. Configuratiebestanden worden met [GNU stow](https://www.gnu.org/software/stow/) naar `$HOME` gesymlinkt; de rest bestaat uit installatiescripts en notities.

Er is geen testsuite of CI. Een wijziging controleer je door de flake te bouwen (zie hieronder).

## Indeling van de repository

| Pad | Inhoud |
| --- | --- |
| [`nixos/`](nixos/) | **Huidige NixOS-flake** (host `nixos`, NixOS 25.11): `configuration.nix` (systeem), `home.nix` (Home Manager), `pkgs/` (eigen pakketten), `sunshine/` (streaminghulpscript), `docs/` |
| [`nixos_old/`](nixos_old/) | Eerdere configuraties per host (`biacws01`, `homelab`, `hp`, `system`, `users`) die channels gebruiken in plaats van flakes. Blijven staan als naslag totdat ze naar `nixos/` zijn gemigreerd |
| `.config/` | Hyprland- / Wayland-config voor de Arch- / Fedora-laptop (fork van [JaKooLit](https://github.com/JaKooLit)), plus een minimale `nvim/init.vim` |
| `nvim/` | Neovim-aanvullingen voor een [LazyVim](https://www.lazyvim.org/)-setup (transparante achtergrond, afkomstig uit [omakub](https://github.com/basecamp/omakub)); stow-pakket |
| `rc/` | `.zshrc`, `.bashrc` en fzf-bindings (afgeleid van omakub); stow-pakket |
| `stowrc.sh` | Verplaatst bestaande rc-bestanden naar `*.bak` en draait daarna `stow -S rc` |
| `arch.sh`, `arch-bt.sh`, `fedora.sh`, `fedora-terminal.sh`, `app-neovim.sh`, `proxmox.sh` | Installatienotities voor de machines zonder NixOS. Grotendeels uitgecommentarieerde checklists en geen idempotente installers, dus lees ze voordat je ze draait |
| `bluetooth-dualboot.py` | Een Bluetooth-apparaat één keer koppelen en op zowel Windows als Linux gebruiken (zie [`BLUETOOTH.md`](BLUETOOTH.md)) |
| `keyboard-shortcuts.md` | Spiekbriefje: vim, fzf, tmux, shell |
| `CLAUDE.md` | Richtlijnen voor Claude Code bij het werken in deze repo |

## NixOS

De flake staat in `nixos/`, niet in de root van de repo. De repo hoort in `~/.dotfiles` te staan.

```bash
# Configuratie toepassen (zsh-alias: rebuild)
sudo nixos-rebuild switch --flake ~/.dotfiles/nixos

# Alle flake-inputs updaten en daarna toepassen (zsh-alias: update)
nix flake update --flake ~/.dotfiles/nixos && sudo nixos-rebuild switch --flake ~/.dotfiles/nixos

# Bouwen zonder te activeren: de controle om vóór een commit te draaien
nix build --no-link ~/.dotfiles/nixos#nixosConfigurations.nixos.config.system.build.toplevel

# Linten
statix check ~/.dotfiles/nixos
```

> **Flakes zien alleen bestanden die git bijhoudt.** Doe `git add` voor nieuwe of hernoemde bestanden (ook voor binaire bestanden zoals `nixos/1920x1080.bin`) voordat je rebuild, anders vindt Nix ze niet.

### Wat er wordt ingesteld

- **Desktop**: SDDM-autologin naar Hyprland, DankMaterialShell voor de launcher, het vergrendelscherm, meldingen en audiobediening, het Bibata-cursorthema en Ghostty.
- **Game streaming**: Sunshine (uit nixpkgs-unstable) met gedeclareerde apps, Steam Remote Play, een geforceerd virtueel scherm op DP-1 via een geïnjecteerde EDID, en een hulpscript dat de monitor naar de resolutie van de Moonlight-client zet en daarna herstelt. Zie [`nixos/docs/remote-gaming.md`](nixos/docs/remote-gaming.md).
- **Hardwarefixes**: automatisch unmuten van een Focusrite Scarlett-interface bij het insteken, en een netwerkreset van `enp5s0` na resume.
- **Netwerk**: NetworkManager, Tailscale, OpenSSH (alleen sleutels) en Syncthing. De firewall staat op deze host bewust uit.
- **Ontwikkeling**: zsh met oh-my-zsh, direnv, git/gh, Neovim met de tooling die LazyVim verwacht, Claude Code en Codex CLI, en de T3 Code-desktopapp.
- **Agent-skills**: skills uit de flake-inputs `mattpocock-skills` en `poteto-plugins` worden gelinkt in zowel `~/.claude/skills` als `~/.codex/skills`.

### T3 Code updaten

T3 Code wordt verpakt vanuit de officiële AppImage in `nixos/pkgs/t3code.nix`:

```bash
./nixos/pkgs/update-t3code.sh --check     # is er een nieuwere release?
./nixos/pkgs/update-t3code.sh             # versie + hash bijwerken (stable-kanaal)
./nixos/pkgs/update-t3code.sh preview     # of preview / nightly volgen
```

## Arch / Fedora

```bash
cd ~/.dotfiles && ./stowrc.sh      # maakt een backup van bestaande rc-bestanden en symlinkt rc/ naar $HOME
stow -S nvim                       # andere pakketten stow je op dezelfde manier
```

De Hyprland-setup in `.config/hypr/` is een fork van de dotfiles van JaKooLit en wordt op de NixOS-machine **niet** gebruikt; daar wordt Hyprland ingesteld vanuit `nixos/home.nix`.

## Nog te doen

- De NixOS-configuraties uit `nixos_old/` naar `nixos/` migreren
- Framework: PAM-bestanden
- Framework: energie-instellingen (hibernate-then-suspend)
- Overige omakub-onderdelen (fzf, alacritty, zellij)
- De ArchWiki-notities over de Framework doornemen; het regulatory domain instellen
- Remote gaming: Wake-on-LAN via Proxmox, headless streaming, vergrendelen na autologin (zie `nixos/docs/remote-gaming.md`)

## Dank aan

[JaKooLit](https://github.com/JaKooLit) (Hyprland-dotfiles), [omakub](https://github.com/basecamp/omakub), [LazyVim](https://www.lazyvim.org/), [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell), [de skills van Matt Pocock](https://github.com/mattpocock/skills), [poteto/plugins](https://github.com/poteto/plugins), [T3 Code](https://t3.codes).

## Licentie

[MIT](LICENSE)
