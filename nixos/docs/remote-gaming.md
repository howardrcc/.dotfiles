# Remote gaming on NixOS (Sunshine + Moonlight)

Wake the gaming box remotely and play over the network with Moonlight, ideally
headless (no monitor attached), without a naive always-unlocked autologin.

Target flow: `remote PC → Tailscale → Proxmox relays WoL → box boots → autologin →
Hyprland + Sunshine start → Moonlight connects → play → teardown`.

## Where each piece lives

| Piece | Where | Status |
| --- | --- | --- |
| Virtual display on DP-1 (EDID injection) | `configuration.nix` (`hardware.firmware`, `hardware.firmwareCompression`, `boot.kernelParams`), `1920x1080.bin` | working |
| SDDM autologin into Hyprland | `configuration.nix` (`services.displayManager`) | working |
| Hyprland on DP-3, DP-1 disabled | `home.nix` (`wayland.windowManager.hyprland.settings.monitor`) | working |
| Sunshine host + apps | `configuration.nix` (`services.sunshine`) | configured |
| Resize DP-3 to the client's resolution while streaming | `sunshine/sunshine-res.sh` (wrapped in `configuration.nix`) | configured |
| Steam Remote Play (monitor-on path) | `configuration.nix` (`programs.steam`, EGL env var) | working |
| Headless streaming on DP-1 (no monitor) | - | deferred, see below |
| Wake-on-LAN via Proxmox relay | - | not wired |
| Lock the session after autologin | - | not wired |

## How the pieces fit

- **EDID**: `1920x1080.bin` is a dump of the DP-3 monitor's EDID
  (`cp /sys/class/drm/card1-DP-3/edid ./1920x1080.bin`, taken while the monitor was
  awake). The kernel params force DP-1 on (`video=DP-1:e`) and feed it that EDID
  (`drm.edid_firmware=DP-1:edid/1920x1080.bin`), so DP-1 shows up as a clone of the
  monitor. Verify with `cat /sys/class/drm/card1-DP-1/modes` and
  `/sys/class/drm/card1-DP-1/status` (`connected`), and `cat /proc/cmdline` for the
  params.
- **Autologin** is what makes a graphical session exist at all after boot. Without it
  the box sits at the SDDM greeter and everything that needs `XDG_RUNTIME_DIR` or a
  Wayland session fails. `loginctl list-sessions` should show `howie seat0 tty1`.
- **Sunshine** runs as a `systemd --user` unit with `capSysAdmin` for KMS capture
  (no portal picker, NVENC is picked automatically). Its apps are declared in Nix, so
  the web UI is read-only for apps. Pair Moonlight through the web UI on port 47990
  using the Tailscale MagicDNS name.
- **Resolution switching**: each Sunshine app runs `sunshine-res do` / `undo` as a
  prep command. Sunshine only runs `undo` when the app is quit, not when Moonlight
  disconnects, so `do` also starts a watcher on the Sunshine log that restores the
  native mode on `CLIENT DISCONNECTED` and re-applies the stream mode on
  `CLIENT CONNECTED`. The connector is `streamMonitor` in `configuration.nix`.

## Gotchas (don't rediscover these)

1. **`.zst` firmware compression silently breaks `drm.edid_firmware`.** NixOS
   compresses firmware by default, the kernel asks for `edid/1920x1080.bin` (no `.zst`)
   and gets ENOENT (`Direct firmware load ... failed with error -2`). Fix:
   `hardware.firmwareCompression = "none"`. This was the biggest time sink.
2. **NVIDIA does honour `drm.edid_firmware`** here (once the `.zst` issue is fixed),
   and `video=DP-1:e` works.
3. **Option names are case-sensitive**: `services.displayManager.autoLogin`, not
   `autologin`.
4. **Flake files must be `git add`-ed** before a rebuild, including the `.bin`.
5. **`nixos-rebuild` is required.** Editing `.nix` and rebooting does nothing.
6. **`runuser` / `sudo -u` wipe the environment**, so an `XDG_RUNTIME_DIR` set before
   the switch is lost. Use the real session instead.
7. **Two DRM-master compositors cannot share one seat.** While Hyprland holds seat0,
   `gamescope --backend drm` fails (even on another connector) with `libseat: client is
   not active` → `Could not open KMS device` → core dump. Starting it from SSH is worse,
   since SSH is not the active seat client.
8. **Sunshine's user unit is bound to `graphical-session.target`**, which Hyprland does
   not start on its own. Home Manager's Hyprland module handles it: its generated
   `exec-once` imports the session environment and starts `hyprland-session.target`.
   If Sunshine isn't running after login, check `systemctl --user status
   graphical-session.target`; no manual `exec-once` is needed.

## Open work

### Headless streaming on DP-1 (no monitor)

Because of gotcha 7, the two viable routes are:

- **Nested gamescope** (`--backend wayland`) inside Hyprland. Shares Hyprland's DRM
  master, loses the direct `-O DP-1` pin; Sunshine captures the gamescope window or
  Hyprland output. Gives per-game scaling and VRR.
- **Sunshine captures the existing Hyprland session**, rendered on DP-1 (Hyprland
  owning DP-1, or a second Hyprland instance). Simplest, no gamescope. Probably the
  pragmatic choice.

### Wake-on-LAN end to end

- Tailscale is L3 and can't carry WoL; relay the magic packet from Proxmox
  (`wakeonlan <MAC>`) or run a small UpSnap / tailscale-wakeonlan container.
- Enable it on the NIC (`networking.interfaces.<iface>.wakeOnLan.enable = true`) and
  in UEFI.
- If root is LUKS, boot stops at the unlock prompt: needs TPM auto-unlock or SSH in
  initrd.

### Locked autologin

Autologin currently leaves the session unlocked. To get the intended security posture,
lock on start (`hyprlock`, or DMS: `dms ipc call lock lock`) and verify Sunshine can
still capture, and that you can unlock over Moonlight.
