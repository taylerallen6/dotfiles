### Get infomation from user ###
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
loadkeys us

# connect to internet through ethernet.
connected_or_not=$(ping -c 1 -q archlinux.org >&/dev/null; echo $?)
[[ "$connected_or_not" == 0 ]] || { echo "ERROR: not connected to the internet"; exit 1; }
echo "Internet connection works."

lsblk
echo

# create partitions.
read disk
boot_size=1GB
parted --script "${disk}" -- mklabel gpt \
  mkpart ESP fat32 1Mib $boot_size \
  set 1 boot on \
  mkpart primary ext4 $boot_size 100%

lsblk
echo

# format boot partition.
read boot_partition # /dev/nvme0n1p1
mkfs.fat -F32 $boot_partition

# format encrypted root partition.
read encrypted_root_partition # /dev/nvme0n1p2
cryptsetup luksFormat $encrypted_root_partition
# enter passphrase.
cryptsetup open $encrypted_root_partition cryptroot
mkfs.ext4 /dev/mapper/cryptroot

lsblk
echo

# mount partitions
mount /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount $boot_partition /mnt/boot

lsblk
echo

# set parallel downloading for pacman (use number of threads for your machine).
old_val=".*ParallelDownloads.*"
new_val="ParallelDownloads = 4"
sed -i "s/$old_val/$new_val/g" /mnt/etc/pacman.conf

# install Arch Linux!
pacstrap /mnt base base-devel nano vim networkmanager lvm2 cryptsetup grub efibootmgr linux linux-firmware sof-firmware

genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

# arch-chroot /mnt

# set datetime.
arch-chroot /mnt ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt date
echo

old_val=".*en_US.UTF-8 UTF-8"
new_val="en_US.UTF-8 UTF-8"
sed -i "s/$old_val/$new_val/g" /mnt/etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /mnt/etc/locale.conf

# create hostname.
echo ${hostname} >> /mnt/etc/hostname

# allow sudo privilages.
arch-chroot /mnt echo "%wheel ALL=(ALL:ALL) ALL" | (EDITOR='tee -a' visudo)

# create user.
arch-chroot /mnt useradd -m -s /usr/bin/bash -G wheel "$username"
arch-chroot /mnt chsh -s /usr/bin/bash

# change passwords.
echo "root:$root_password" | chpasswd --root /mnt
echo "$user:$user_password" | chpasswd --root /mnt


old_val="HOOKS=(.*"
new_val="HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt lvm2 filesystems fsck)"
sed -i "s/$old_val/$new_val/g" /mnt/etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -P

arch-chroot /mnt grub-install --efi-directory=/boot --bootloader-id=${hostname}_bootloader1 $disk

encrypted_uuid=$(blkid -o value -s UUID $encrypted_root_partition)
decrypted_uuid=$(blkid -o value -s UUID /dev/mapper/cryptroot)

old_val="GRUB_CMDLINE_LINUX_DEFAULT=\".*"
new_val="GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet cryptdevice=UUID=${encrypted_uuid}:cryptroot root=UUID=${decrypted_uuid}\""
sed -i "s/$old_val/$new_val/g" /mnt/etc/default/grub

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# enable internet on startup.
arch-chroot /mnt systemctl enable NetworkManager
