#!/bin/bash
#pacman -S neovim unzip git
# get neovim from git/omakub
#
# yay and base-devel
# pacman -S blueman
# pacman -S bluez bluez-utils
# pacman -S fzf wl-clipboard
# pacman -S zsh-syntax-highlighting
#
# hyprland picked during arch install
#
# blueman/bluez-utils
# Enable bluetooth. Are both needed?
#
# systemctl start bluetooth.service
# systemctl enable bluetooth.service
# pacman -S glib2 colord libxrandr

#icc see arch wiki

#sudo pacman -S pipewire pipewire-pulse easyeffects --needed
#activate
#systemctl --user enable pipewire.service
#systemctl --user start pipewire.service

#systemctl --user enable pipewire-pulse.service
#systemctl --user start pipewire-pulse.service
#iwd backend config
#iwd or nm?

pacman -S network-manager-applet

#deps for sddm
pacman -Syu qt6-svg qt6-declarative:w

#check /etc/login.d for lid and power button handling
