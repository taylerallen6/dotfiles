### possible themes
# https://github.com/vinceliuice/Graphite-gtk-theme.git
# https://draculatheme.com/gtk
# https://github.com/dracula/gtk

### alacritty themes
# https://github.com/alacritty/alacritty-theme

### USEFUL FIRST INSTALLS
sudo pacman -S git
sudo pacman -S curl
sudo pacman -S xdg-user-dirs

### ADD USER DIRECTORIES
# commands after installs:
xdg-user-dirs-update

### INSTALL YAY
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

### RUST
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

### REBOS
cargo install rebos
rebos setup
rebos config init

### NVM / NPM / NODE.JS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install 20.0 # installs node v20.0

### TUIGREET
# commands after installs:
systemctl enable greetd.service
sudo cp tuigreet_config.toml /etc/greetd/config.toml

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
exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
# Do NOT install Grimblast screenshot tool! It will mess up screen sharing!
# If still not working, try:
cp -r /usr/share/pipewire ~/.config/pipewire # copy default pipewire configs (?)

### PRINTERs
# commands after installs:
sudo systemctl start cups
sudo systemctl enable cups
sudo usermod -a -G lp {your-username}

### EWW
# https://elkowar.github.io/eww/
git clone https://github.com/elkowar/eww
cd eww
cargo build --release --no-default-features --features=wayland

