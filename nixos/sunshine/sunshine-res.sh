#!/usr/bin/env bash
# Sunshine monitor-resolution helper for Hyprland.
# Usage: sunshine-res.sh do [WxH@FPS] -> switch the ultrawide to the streaming client's
#                                       resolution (or the given mode)
#        sunshine-res.sh undo           -> restore native config (hyprctl reload)
# Sunshine sets SUNSHINE_CLIENT_WIDTH/HEIGHT/FPS in the environment for prep cmds.
#
# Sunshine only runs "undo" when the app is quit, not when Moonlight just
# disconnects. So "do" also starts a watcher on the Sunshine log that restores
# native resolution on CLIENT DISCONNECTED and re-applies the stream
# resolution on CLIENT CONNECTED (resume). "undo" stops the watcher.

set -u

UID_NUM=1000
MON="desc:Samsung Electric Company C49RG9x H1AK500000"
HYPRCTL=/etc/profiles/per-user/howie/bin/hyprctl
LOG=/tmp/sunshine-hypr.log
SUNSHINE_LOG="$HOME/.config/sunshine/sunshine.log"
STATE="/run/user/${UID_NUM}/sunshine-res.mode"
WATCH_PID="/run/user/${UID_NUM}/sunshine-res.watch.pid"

export XDG_RUNTIME_DIR="/run/user/${UID_NUM}"
# Newest entry in the hypr runtime dir = the live instance signature.
export HYPRLAND_INSTANCE_SIGNATURE="$(ls -t "/run/user/${UID_NUM}/hypr" 2>/dev/null | head -1)"

log() { echo "[$(date '+%F %T')] $*"; }

apply_stream() { "$HYPRCTL" keyword monitor "${MON},$(cat "$STATE"),0x0,1"; }
restore_native() { "$HYPRCTL" reload; }

stop_watcher() {
  if [ -f "$WATCH_PID" ]; then
    kill -- "-$(cat "$WATCH_PID")" 2>/dev/null
    rm -f "$WATCH_PID"
  fi
}

{
  log "action=${1:-?} sig=${HYPRLAND_INSTANCE_SIGNATURE} \
client=${SUNSHINE_CLIENT_WIDTH:-?}x${SUNSHINE_CLIENT_HEIGHT:-?}@${SUNSHINE_CLIENT_FPS:-?}"

  case "${1:-}" in
    do)
      echo "${2:-${SUNSHINE_CLIENT_WIDTH}x${SUNSHINE_CLIENT_HEIGHT}@${SUNSHINE_CLIENT_FPS}}" >"$STATE"
      apply_stream
      stop_watcher
      # New session (own process group) so undo can kill tail + loop together.
      setsid "$0" watch </dev/null >>"$LOG" 2>&1 &
      echo $! >"$WATCH_PID"
      ;;
    watch)
      tail -n0 -F "$SUNSHINE_LOG" 2>/dev/null | while read -r line; do
        case "$line" in
          *"CLIENT DISCONNECTED"*) log "disconnect -> native"; restore_native ;;
          *"CLIENT CONNECTED"*)    log "reconnect -> stream"; apply_stream ;;
        esac
      done
      ;;
    undo)
      stop_watcher
      rm -f "$STATE"
      restore_native
      ;;
    *)
      echo "usage: $0 do [WxH@FPS]|undo" >&2
      exit 64
      ;;
  esac
} >>"$LOG" 2>&1
