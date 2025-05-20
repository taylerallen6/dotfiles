### Get infomation from user ###
echo "STEP: Enter information."

echo -n "Hostname: "
read hostname
: "${hostname:?"Missing hostname"}"

echo -n "Root Password: "
read -s root_password
echo
echo -n "Repeat Root Password: "
read -s root_password2
echo
[[ "$root_password" == "$root_password2" ]] || { echo "ERROR: Passwords did not match"; exit 1; }

echo -n "Username: "
read username
: "${username:?"Missing username"}"

echo -n "User Password: "
read -s user_password
echo
echo -n "Repeat User Password: "
read -s user_password2
echo
[[ "$user_password" == "$user_password2" ]] || { echo "ERROR: Passwords did not match"; exit 1; }

# set keyboard layout.
echo "STEP: Set keyboard layout."
loadkeys us

# connect to internet through ethernet.
echo "STEP: Check internet connection."
connected_or_not=$(ping -c 1 -q archlinux.org >&/dev/null; echo $?)
[[ "$connected_or_not" == 0 ]] || { echo "ERROR: not connected to the internet"; exit 1; }
echo "Internet connection works."

echo
lsblk
echo

# create partitions.
echo "STEP: Create partitions."
echo -n "Enter disk to partition (/dev/nvme0n1) : "
read disk
boot_size=1GB
parted --script "${disk}" -- mklabel gpt \
  mkpart ESP fat32 1Mib $boot_size \
  set 1 boot on \
  mkpart primary ext4 $boot_size 100%

echo
lsblk
echo

# format boot partition.
echo "STEP: Format boot partition."
echo -n "Enter boot partition (/dev/nvme0n1p1) : "
read boot_partition # /dev/nvme0n1p1
mkfs.fat -F32 $boot_partition

# format encrypted root partition.
echo "STEP: Format encrypted root partition."
echo -n "Enter encrypted root partition (/dev/nvme0n1p2) : "
read encrypted_root_partition # /dev/nvme0n1p2
cryptsetup luksFormat $encrypted_root_partition
# enter passphrase.
cryptsetup open $encrypted_root_partition cryptroot
mkfs.ext4 /dev/mapper/cryptroot

echo
lsblk
echo

# mount partitions
echo "STEP: Mount partitions."
mount /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount $boot_partition /mnt/boot

lsblk
echo

# set parallel downloading for pacman (use number of threads for your machine).
echo "STEP: Set parallel downloading."
old_val=".*ParallelDownloads.*"
new_val="ParallelDownloads = 4"
sed -i "s/$old_val/$new_val/g" /etc/pacman.conf

echo
echo -n "Press ENTER to continue with install: "
read unused_var
echo

# install Arch Linux!
echo "STEP: Use pacstrap install arch linux."
pacstrap /mnt base base-devel nano vim networkmanager lvm2 cryptsetup grub efibootmgr linux linux-firmware sof-firmware
echo

echo "STEP: genfstab."
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

# arch-chroot /mnt

# set datetime.
echo "STEP: Set datetime."
arch-chroot /mnt ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt date
echo

echo "STEP: Set locale."
old_val=".*en_US.UTF-8 UTF-8"
new_val="en_US.UTF-8 UTF-8"
sed -i "s/$old_val/$new_val/g" /mnt/etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /mnt/etc/locale.conf

# create hostname.
echo "STEP: Set hostname."
echo ${hostname} >> /mnt/etc/hostname

# allow sudo privileges.
# THIS STEP STILL DOES NOT WORK! (ANGER)
echo "STEP: Allow sudo privileges."
# arch-chroot /mnt echo "%wheel ALL=(ALL:ALL) ALL" | EDITOR='tee -a' visudo
# arch-chroot /mnt echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

echo
echo -n "Press ENTER to continue: "
read unused_var
echo

# create user.
echo "STEP: Create user."
arch-chroot /mnt useradd -m -s /usr/bin/bash -G wheel "$username"
arch-chroot /mnt chsh -s /usr/bin/bash

# change passwords.
echo "STEP: Set root and user passwords."
echo "root:$root_password" | chpasswd --root /mnt
echo "$username:$user_password" | chpasswd --root /mnt

echo "STEP: Add hooks."
old_val="HOOKS=(.*"
new_val="HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt lvm2 filesystems fsck)"
sed -i "s/$old_val/$new_val/g" /mnt/etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -P

echo "STEP: Install grub."
arch-chroot /mnt grub-install --efi-directory=/boot --bootloader-id=${hostname}_bootloader1 $disk

echo "STEP: Add UUIDs to grub."
encrypted_uuid=$(blkid -o value -s UUID $encrypted_root_partition)
decrypted_uuid=$(blkid -o value -s UUID /dev/mapper/cryptroot)

old_val="GRUB_CMDLINE_LINUX_DEFAULT=\".*"
new_val="GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet cryptdevice=UUID=${encrypted_uuid}:cryptroot root=UUID=${decrypted_uuid}\""
sed -i "s/$old_val/$new_val/g" /mnt/etc/default/grub

echo "STEP: Configure grub."
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# enable internet on startup.
echo "STEP: Enable network manager."
arch-chroot /mnt systemctl enable NetworkManager

### USEFUL FIRST INSTALLS
echo "STEP: Install xdg-user-dirs."
arch-chroot /mnt sudo pacman -S xdg-user-dirs

### ADD USER DIRECTORIES
echo "STEP: Create user directories."
arch-chroot /mnt xdg-user-dirs-update

echo "STEP: DONE: Please reboot and remove usb if successful."
echo
