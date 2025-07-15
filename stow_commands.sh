#!/bin/bash

stow dot_bashrc
stow dot_icons
stow dot_themes
stow alacritty
# stow eww
stow helix
stow hypr
stow waybar
stow swaybg
stow rebos
stow qutebrowser
stow util_scripts

# sudo stow -nv --target=/ {some_folder}
sudo stow --target=/ systemd_services 
sudo stow --target=/ tlp
