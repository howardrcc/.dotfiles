#!/bin/sh
pushd ~/.dotfiles
home-manager switch -f ./users/howie/home.nix
popd
