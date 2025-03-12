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
    pacman -S xorg lightdm lxqt
    systemctl enable lightdm
    echo "LXQt environment installed."
}

# Function to install i3 window manager
install_i3() {
    echo "Installing i3 window manager..."
    pacman -S xorg i3-wm i3status i3lock dmenu
    systemctl enable i3
    echo "i3 window manager installed."
}

# Function to create a new user and add to sudoers
create_user() {
    echo "Enter the username for the new user:"
    read -p "Username: " username
    echo "Enter password for the new user:"
    read -s -p "Password: " password
    echo
    echo "Creating user $username..."

    # Create the user
    useradd -m -G wheel -s /bin/bash $username

    # Set the user's password
    echo "$username:$password" | chpasswd
    echo "User $username created."

    # Add the user to the sudoers file (enable wheel group for sudo)
    echo "%wheel ALL=(ALL) ALL" >> /mnt/etc/sudoers
    echo "User $username added to sudoers."

    # Enable sudo group permissions
    pacman -S sudo
}

# Function to install important packages
install_important_packages() {
    echo "Installing important system packages..."
    pacman -S vim git base-devel netctl networkmanager ufw iptables
    echo "Important system packages installed."
}

# Function to install multimedia packages
install_multimedia_packages() {
    echo "Installing multimedia packages..."
    pacman -S vlc ffmpeg gimp
    echo "Multimedia packages installed."
}

# Function to install development tools
install_dev_packages() {
    echo "Installing development tools..."
    pacman -S git vim make gcc
    echo "Development tools installed."
}

# Function to install an AUR helper (yay)
install_aur_helper() {
    echo "Installing AUR helper (yay)..."
    pacman -S yay
    echo "AUR helper (yay) installed."
}

# Function to install recommended packages
install_recommended_packages() {
    echo "Do you want to install additional packages?"
    echo "1. Important System Packages (vim, git, base-devel, etc.)"
    echo "2. Multimedia Packages (vlc, ffmpeg, gimp)"
    echo "3. Development Tools (git, vim, make, gcc)"
    echo "4. Install AUR Helper (yay)"
    echo "5. No additional packages"
    
    read -p "Select options (e.g., 1 2 3): " options
    for option in $options; do
        case $option in
            1)
                install_important_packages
                ;;
            2)
                install_multimedia_packages
                ;;
            3)
                install_dev_packages
                ;;
            4)
                install_aur_helper
                ;;
            5)
                echo "No additional packages will be installed."
                ;;
            *)
                echo "Invalid option $option. Skipping."
                ;;
        esac
    done
}

# Main Menu function to display the options again
main_menu() {
    echo "Arch Linux Installation Script"
    echo "1. Partition the disk"
    echo "2. Install the base system"
    echo "3. Install a desktop environment"
    echo "4. Create a new user and add to sudoers"
    echo "5. Install recommended packages"
    echo "6. Install bootloader"
    echo "7. Exit"

    while true; do
        echo "Please select an option:"
        read -p "Enter choice (1-7): " choice
        case $choice in
            1)
                partition_disk
                format_partitions
                mount_partitions
                ;;
            2)
                install_base_system
                generate_fstab
                chroot_system
                ;;
            3)
                echo "Select a desktop environment to install:"
                echo "1. KDE Plasma"
                echo "2. GNOME"
                echo "3. XFCE"
                echo "4. LXQt"
                echo "5. i3"
                read -p "Enter your choice (1-5): " de_choice
                case $de_choice in
                    1)
                        install_kde
                        ;;
                    2)
                        install_gnome
                        ;;
                    3)
                        install_xfce
                        ;;
                    4)
                        install_lxqt
                        ;;
                    5)
                        install_i3
                        ;;
                    *)
                        echo "Invalid choice. Please select a valid desktop environment."
                        ;;
                esac
                ;;
            4)
                create_user
                ;;
            5)
                install_recommended_packages
                ;;
            6)
                install_bootloader
                ;;
            7)
                echo "Exiting script."
                exit 0
                ;;
            *)
                echo "Invalid option. Please try again."
                ;;
        esac
    done
}

# Initial call to the main menu
main_menu
