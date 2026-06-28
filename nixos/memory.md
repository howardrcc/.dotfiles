# Remote Gaming on NixOS — Project Memory / Spec

> Handoff doc for continuing in Claude Code. Captures current working state,
> exact config that got us here, the dead-ends (do NOT repeat), and open work.

---

## Goal

Wake the NixOS gaming box remotely (Wake-on-LAN) and play games over the network
via **Moonlight + Sunshine**, ideally *headless* (no physical monitor required),
without permanently sacrificing security (no naive autologin).

End-state flow:
`remote PC → Tailscale → Proxmox relays WoL → box boots → autologin → Hyprland +
Sunshine come up → Moonlight connects → play → teardown`.

---

## Status

| Piece | State |
|-------|-------|
| EDID injection on DP-1 (forced virtual display) | ✅ working |
| Locked-autologin (SDDM → Hyprland on seat0) | ✅ working |
| Hyprland on DP-3, DP-1 left free | ✅ working |
| Steam streaming (monitor-on path) | ✅ working |
| Sunshine streaming the DP-3 Hyprland session | ⏳ next step (should work now) |
| Headless streaming on DP-1 (no monitor) | 🔜 deferred — see "Pending" |
| WoL end-to-end via Proxmox relay | 🔜 not wired yet |

---

## System facts

- **OS**: NixOS 25.11, **flake-based** config in a git repo (NOT `/etc/nixos`;
  likely `~/nixos`). Flake implication: new/changed files must be `git add`-ed or
  the flake won't see them.
- **GPU**: NVIDIA RTX 2080 Ti (proprietary driver).
- **Compositor**: Hyprland (Wayland).
- **User**: `howie`, uid `1000`, runtime dir `/run/user/1000`.
- **Monitor**: Samsung C49RG9x ultrawide on **DP-3** @ `5120x1440@120`.
- **Display manager**: SDDM, with `autoLogin` enabled.
- **Network**: Tailscale (MagicDNS). Always-on LAN box = Proxmox (the WoL relay).
- **Connectors on card1**: DP-1, DP-2, DP-3 (monitor), HDMI-A-1. DP-1 is the
  forced virtual output.

---

## Working configuration

### 1. EDID injection on DP-1 (the forced virtual display)

The blob is a **dump of the DP-3 monitor's EDID** (so DP-1 reports as a C49RG9x
clone — that's why `modes` shows 1440p/1080p@120). Provided via `hardware.firmware`
and pointed to by kernel params.

```nix
# Provide the EDID blob under lib/firmware/edid/
hardware.firmware = [
  (pkgs.runCommandNoCC "custom-edid" {} ''
    mkdir -p $out/lib/firmware/edid
    cp ${./1920x1080.bin} $out/lib/firmware/edid/1920x1080.bin
  '')
];

# CRITICAL: without this, NixOS compresses firmware to .zst and the kernel
# requests "edid/1920x1080.bin" (no .zst) → ENOENT (error -2). This was THE bug.
hardware.firmwareCompression = "none";

boot.kernelParams = [
  "video=DP-1:e"                                # force connector on (works on NVIDIA)
  "drm.edid_firmware=DP-1:edid/1920x1080.bin"   # inject EDID (honored once .zst fixed)
];
# nvidia-drm.modeset=1 is already set by the NVIDIA NixOS path — don't duplicate.
```

The EDID blob came from: `cp /sys/class/drm/card1-DP-3/edid ./1920x1080.bin`
(dumped while the monitor was awake; must be `git add`-ed for the flake).

**Verify**: `cat /sys/class/drm/card1-DP-1/modes` shows real modes (1920x1080@120,
2560x1440, …) and `/sys/class/drm/card1-DP-1/status` = `connected`.

### 2. Locked-autologin (SDDM)

Keeping SDDM (already in use) and adding autologin — NOT switching to greetd.

```nix
services.displayManager.autoLogin = {   # NOTE: camelCase "autoLogin"
  enable = true;
  user = "howie";
};
services.displayManager.defaultSession = "hyprland";  # must match a session in
                                                      # /run/current-system/sw/share/wayland-sessions/
# SDDM stays enabled (services.displayManager.sddm.enable = true)
```

Result (confirmed): `loginctl list-sessions` shows `howie  seat0  user  tty1`,
`pgrep -a Hyprland` returns a process. This was the missing piece — there was no
graphical session before (box sat at the SDDM greeter), which is the real root of
all the XDG_RUNTIME_DIR failures.

### 3. Hyprland monitor layout (keep DP-1 free for streaming)

In Home Manager, `monitor` is a **list of strings** (can't be an attrset — needs
duplicate keys). Be explicit per connector; do NOT use the `,` wildcard.

```nix
wayland.windowManager.hyprland.settings.monitor = [
  "DP-3, 5120x1440@120, 0x0, 1"   # real ultrawide, primary
  "DP-1, disable"                  # forced virtual connector: keep Hyprland off it
];
```

### 4. Sunshine (next step — service likely already present)

```nix
services.sunshine = {
  enable = true;
  autoStart = true;
  capSysAdmin = true;    # REQUIRED for Wayland capture (also breaks tray icon — expected)
  openFirewall = true;   # 47984/47989/47990/48010 TCP, 47998-48000 UDP
};
hardware.uinput.enable = true;
users.users.howie.extraGroups = [ "input" "uinput" ];   # input only works after re-login
```

Sunshine is a `systemd --user` unit bound to `graphical-session.target`, which
**Hyprland does not start on its own**. Add to Hyprland `exec-once`:

```nix
wayland.windowManager.hyprland.settings."exec-once" = [
  "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE"
  "systemctl --user start graphical-session.target"
  # "hyprlock"   # for the locked-autologin security posture (add when desired)
];
```

---

## Hard-won gotchas (do NOT rediscover these)

1. **`.zst` firmware compression silently breaks `drm.edid_firmware`** → ENOENT
   (`Direct firmware load for edid/... failed with error -2`). Fix:
   `hardware.firmwareCompression = "none"`. This was the single biggest time sink.
2. **NVIDIA *does* honor `drm.edid_firmware`** here (once the .zst issue is fixed)
   and `video=DP-1:e` force works. The earlier worry that NVIDIA ignores it did
   NOT materialize on this card/driver.
3. **Option name casing matters**: it's `autoLogin`, not `autologin`. Nix is
   case-sensitive; wrong case = "option does not exist".
4. **Flake = files must be `git add`-ed** before rebuild, or changes are invisible.
5. **`nixos-rebuild` is required** — editing `.nix` + reboot alone does nothing.
   Verify kernel params landed with `cat /proc/cmdline`.
6. **`runuser` / `sudo -u` wipe the environment** — `XDG_RUNTIME_DIR` set before
   the user switch is lost. Irrelevant now (use the real session), but cost hours.
7. **THE ARCHITECTURAL BLOCKER (key insight):** two DRM-master compositors cannot
   coexist on one seat. With Hyprland running and holding seat0/KMS-master, a
   `gamescope --backend drm` (even on a *different* connector DP-1) fails with
   `libseat: client is not active` → `Could not open KMS device` →
   `Failed to create backend` → core dump. You cannot run gamescope-on-DRM next to
   Hyprland. Launching it from SSH makes it worse (SSH is not the active seat client).

---

## Pending work

### Immediate: Sunshine streaming on DP-3 (current Hyprland session)
No second compositor, no seat conflict → should just work. Rebuild + reboot, then:
```bash
systemctl --user status sunshine      # should be active
# Sunshine web UI: https://<host>:47990  (PIN-pair Moonlight here)
```
Connect Moonlight to the Tailscale MagicDNS name. First-run caveats: full reboot
needed for the user unit to start; `uinput` group needs a fresh login for input.

### Deferred: headless streaming on DP-1 (no monitor)
Because gamescope-on-DRM can't run beside Hyprland (see gotcha #7), the two viable
routes are:
- **Route 1 — gamescope nested in Hyprland** (`--backend wayland` instead of DRM).
  Shares Hyprland's master, no seat conflict. Loses the direct `-O DP-1` DRM pin.
  Sunshine then captures the gamescope window / Hyprland output. Per-game scaling/VRR.
- **Route 2 — Sunshine captures the existing Hyprland session directly**, rendering
  on DP-1 (e.g. Hyprland spanning/owning DP-1, or a second Hyprland instance).
  Simplest; no gamescope at all. Probably the pragmatic winner.

### Not yet wired: WoL end-to-end
- Tailscale can't send WoL (L3 vs L2) → relay the magic packet from **Proxmox**
  (`wakeonlan <MAC>`), or a small UpSnap/tailscale-wakeonlan container.
- Enable on NIC: `networking.interfaces.<iface>.wakeOnLan.enable = true` + UEFI WoL.
- If root is LUKS: boot stops at unlock → needs TPM auto-unlock or SSH-in-initrd.

---

## The `remote-gaming.nix` module
A module already exists (autologin + hyprlock + sunshine + uinput + WoL +
nvidia modeset). It originally used **greetd**; we pivoted to **SDDM autoLogin**
since SDDM was already the DM. Reconcile: either keep SDDM-autologin (current,
working) and drop the greetd block, or commit to greetd and disable SDDM.

---

## Open decisions for next session
1. Confirm Sunshine streams the DP-3 session end-to-end (Moonlight beeld).
2. Pick Route 1 vs Route 2 for the headless DP-1 variant.
3. Decide whether to re-enable `hyprlock`-on-start for the locked-autologin posture
   (and verify Sunshine can capture + you can unlock the lock screen over Moonlight).
4. Wire the WoL relay on Proxmox + NIC config.
