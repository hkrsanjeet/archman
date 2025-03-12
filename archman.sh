#!/bin/bash

# Function to auto-partition the disk
auto_partition_disk() {
    echo "Auto partitioning the disk $disk..."
    # Example: One root partition and one swap partition
    parted $disk mklabel gpt
    parted $disk mkpart primary ext4 1MiB 100%
    parted $disk mkpart primary linux-swap 100% 100%
    
    # Format root partition
    root_part="${disk}1"
    mkfs.ext4 $root_part
    # Format swap partition
    swap_part="${disk}2"
    mkswap $swap_part
    swapon $swap_part
    
    echo "Auto partitioning completed."
}

# Function to partition the disk
partition_disk() {
    echo "Please select the disk to partition (e.g., /dev/sda):"
    read -p "Enter disk: " disk
    echo "Partitioning disk $disk..."
    
    # Ask user to choose between auto or manual partitioning
    echo "Select partitioning option:"
    echo "1. Auto partition"
    echo "2. Manual partition with cfdisk"
    read -p "Enter choice (1 or 2): " partition_choice
    
    case $partition_choice in
        1)
            auto_partition_disk
            ;;
        2)
            cfdisk $disk
            ;;
        *)
            echo "Invalid choice. Exiting partitioning step."
            exit 1
            ;;
    esac
}

# Function to format the partitions
format_partitions() {
    echo "Please select the root partition (e.g., /dev/sda1):"
    read -p "Enter root partition: " root_part
    echo "Formatting root partition..."
    mkfs.ext4 $root_part
    echo "Partition formatted."
}

# Function to mount the partitions
mount_partitions() {
    echo "Mounting the root partition to /mnt..."
    mount $root_part /mnt
}

# Function to install the base system
install_base_system() {
    echo "Installing the base system..."
    pacstrap /mnt base linux linux-firmware vim
    echo "Base system installed."
}

# Function to generate fstab
generate_fstab() {
    echo "Generating fstab..."
    genfstab -U /mnt >> /mnt/etc/fstab
    echo "fstab generated."
}

# Function to chroot into the new system
chroot_system() {
    echo "Chrooting into the new system..."
    arch-chroot /mnt
}

# Function to install bootloader (GRUB)
install_bootloader() {
    echo "Installing bootloader (GRUB)..."
    pacman -S grub
    echo "Please enter the disk for bootloader installation (e.g., /dev/sda):"
    read -p "Enter disk: " disk
    grub-install $disk
    grub-mkconfig -o /boot/grub/grub.cfg
    echo "Bootloader installed."
}

# Function to install KDE Plasma desktop
install_kde() {
    echo "Installing KDE Plasma desktop environment..."
    pacman -S xorg sddm plasma kde-applications
    systemctl enable sddm
    echo "KDE Plasma environment installed."
}

# Function to install GNOME desktop environment
install_gnome() {
    echo "Installing GNOME desktop environment..."
    pacman -S xorg gdm gnome gnome-extra
    systemctl enable gdm
    echo "GNOME environment installed."
}

# Function to install XFCE desktop environment
install_xfce() {
    echo "Installing XFCE desktop environment..."
    pacman -S xorg lightdm xfce4 xfce4-goodies
    systemctl enable lightdm
    echo "XFCE environment installed."
}

# Function to install LXQt desktop environment
install_lxqt() {
    echo "Installing LXQt desktop environment..."
    pacman -
