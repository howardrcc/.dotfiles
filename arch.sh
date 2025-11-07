#!/bin/bash
#pacman -S neovim unzip git
# get neovim from git/omakub
#
# yay and base-devel
# pacman -S blueman
# pacman -S bluez bluez-utils
sudo pacman -S fzf wl-clipboard
sudo pacman -S zsh-syntax-highlighting
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
sudo pacman -Syu
sudo pacman -S pipewire wireplumber pipewire-pulse easyeffects --needed
#activate
#as user
#exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOPservice
#systemctl --user enable pipewire.service
#systemctl --user start pipewire.service

#systemctl --user enable pipewire-pulse.service
#systemctl --user start pipewire-pulse.service
#iwd backend config
#iwd or nm?

#pacman -S network-manager-applet

#deps for sddm
#pacman -Syu qt6-svg qt6-declarative:w

#regdomain for wifi speed (see framework arch)
sudo pacman -S wireless-regdb
#reboot then edit /etc/conf.d/wireless-regdom

sudo pacman -S xdg-desktop-portal-hyprland
sudo pacman -S mako
sudo pacman -S waybar
#check /etc/login.d for lid and power button handling
sudo pacman -S zsh stow alacritty 
sudo pacman -S nautilus
sudo pacman -S eza #see below for zsh-autosuggestions zsh-syntax-highlighting 
sudo pacman -S fastfetch
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sudo pacman -S bluez bluez-utils blueman

sudo pacman -S ntfs-3g
#sudo pacman -S greetd-regreet
sudo pacman -S hyprlock
#
#
#<LeftMouse>var/lib/bluetooth/A8:3B:76:72:EA:0C
#attributes  cache  D2:5C:BF:8C:53:7B  settings
