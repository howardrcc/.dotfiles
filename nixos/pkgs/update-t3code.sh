#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq
# Check for / apply a new T3 Code release in pkgs/t3code.nix.
#
# Usage: update-t3code.sh [--check] [stable|preview|nightly]
#   --check   only report whether a newer version exists (exit 1 if so)
#   channel   release channel to follow (default: stable)
set -euo pipefail

nixfile="$(dirname "$(realpath "$0")")/t3code.nix"
repo="pingdotgg/t3code"

check=0
channel=stable
for arg in "$@"; do
  case "$arg" in
    --check) check=1 ;;
    stable|preview|nightly) channel="$arg" ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

if [[ "$channel" == stable ]]; then
  tag=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | jq -r .tag_name)
else
  tag=$(curl -fsSL "https://api.github.com/repos/$repo/releases?per_page=30" \
    | jq -r --arg ch "-$channel." '[.[] | select(.tag_name | contains($ch))][0].tag_name')
fi
[[ -n "$tag" && "$tag" != null ]] || { echo "no $channel release found" >&2; exit 2; }

latest="${tag#v}"
current=$(sed -n 's/^  version = "\(.*\)";$/\1/p' "$nixfile")

echo "current: $current"
echo "latest ($channel): $latest"

if [[ "$current" == "$latest" ]]; then
  echo "up to date"
  exit 0
fi

if (( check )); then
  echo "update available"
  exit 1
fi

url="https://github.com/$repo/releases/download/v$latest/T3-Code-$latest-x86_64.AppImage"
echo "fetching $url"
hash=$(nix store prefetch-file --json "$url" | jq -r .hash)

sed -i \
  -e "s|^  version = \".*\";$|  version = \"$latest\";|" \
  -e "s|^    hash = \".*\";$|    hash = \"$hash\";|" \
  "$nixfile"

echo "updated $nixfile: $current -> $latest"
echo "rebuild: sudo nixos-rebuild switch --flake ~/.dotfiles/nixos#nixos"
