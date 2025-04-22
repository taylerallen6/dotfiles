### USEFUL FIRST INSTALLS
sudo pacman -S git
sudo pacman -S curl
sudo pacman -S stow
sudo pacman -S xdg-user-dirs

### ADD USER DIRECTORIES
# commands after installs:
xdg-user-dirs-update

### INSTALL YAY
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

cd

### RUST
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup component add rust-analyzer

### Stow dotfiles
cd ~/dotfiles

rm -r ~/.bashrc
rm -r ~/.config/helix
rm -r ~/.config/rebos

stow dot_bashrc
stow helix
stow rebos
stow alacritty
stow hypr
stow waybar
stow swaybg
stow dot_themes
stow dot_icons

cd

### REBOS
cargo install rebos
rebos setup
rebos config init

rebos gen commit "first commit"
rebos gen current to-latest
rebos gen current build

### NVM / NPM / NODE.JS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install 20.0 # installs node v20.0

### TUIGREET
# commands after installs:
systemctl enable greetd.service
sudo cp ~/dotfiles/misc_files/tuigreet_config.toml /etc/greetd/config.toml

### INSTALL OH-MY-BASH
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

### BLUETOOTH
# commands after installs:
# start service
sudo systemctl start bluetooth
sudo systemctl enable bluetooth

# SCREEN SHARING
# https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580
# https://wiki.archlinux.org/title/PipeWire
# commands after installs:
# Add this line to your hyprland.conf file.
# exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# Do NOT install Grimblast screenshot tool! It will mess up screen sharing!
# If still not working, try:
# cp -r /usr/share/pipewire ~/.config/pipewire # copy default pipewire configs (?)

### PRINTERs
# commands after installs:
sudo systemctl start cups
sudo systemctl enable cups
sudo usermod -a -G lp user1

### EWW
# https://elkowar.github.io/eww/
git clone https://github.com/elkowar/eww
cd eww
cargo build --release --no-default-features --features=wayland

cd

### theme
### possible themes
# https://github.com/vinceliuice/Graphite-gtk-theme.git
# https://draculatheme.com/gtk
# https://github.com/dracula/gtk
cd ~/dotfiles/dot_themes/.themes
wget https://github.com/dracula/gtk/archive/master.zip -O dracula-gtk.zip
unzip dracula-gtk
mv gtk-master dracula-gtk

cd

gsettings set org.gnome.desktop.interface gtk-theme "dracula-gtk"
gsettings set org.gnome.desktop.interface icon-theme "dracula-icons"

### alacritty themes
# https://github.com/alacritty/alacritty-theme

