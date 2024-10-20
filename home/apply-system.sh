#!/bin/sh
echo $HOSTNAME
pushd ~/.dotfiles/$HOSTNAME
sudo nixos-rebuild switch -I nixos-config=./configuration.nix
popd
