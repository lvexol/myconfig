#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting i3 setup process...${NC}"

# Function to handle errors
handle_error() {
    echo -e "\033[0;31mError: $1\033[0m"
    echo -e "\033[0;33mPlease check the error message above and try to resolve the issue.\033[0m"
}

# Function to install packages
install_package() {
    local package=$1
    echo -e "${BLUE}Installing $package...${NC}"
    
    if command -v apt-get &> /dev/null; then
        if ! sudo apt-get install -y "$package"; then
            handle_error "Failed to install $package"
            return 1
        fi
    elif command -v pacman &> /dev/null; then
        if ! sudo pacman -S --noconfirm "$package"; then
            handle_error "Failed to install $package"
            return 1
        fi
    else
        handle_error "No supported package manager found (apt-get or pacman)"
        exit 1
    fi
    return 0
}

# Update package lists first
echo -e "${BLUE}Updating package lists...${NC}"
if command -v apt-get &> /dev/null; then
    sudo apt-get update || handle_error "Failed to update package lists"
elif command -v pacman &> /dev/null; then
    sudo pacman -Sy || handle_error "Failed to update package lists"
fi

# Required packages arrays - adjusted for apt names
PACKAGES=(
    "i3"  # Changed from i3-gaps as it's typically included in i3 on Ubuntu/Debian
    "i3lock"
    "i3status"
    "picom"
    "rofi"
    "feh"
    "kitty"
    "flameshot"
    "git"
    "python3"
    "python3-pip"
    "imagemagick"
)

# Install packages one by one with error handling
echo -e "${BLUE}Installing required packages...${NC}"
FAILED_PACKAGES=()
for package in "${PACKAGES[@]}"; do
    if ! install_package "$package"; then
        FAILED_PACKAGES+=("$package")
    fi
done

# Report failed installations if any
if [ ${#FAILED_PACKAGES[@]} -ne 0 ]; then
    echo -e "\033[0;31mThe following packages failed to install:\033[0m"
    printf '%s\n' "${FAILED_PACKAGES[@]}"
    echo -e "\033[0;33mYou may need to install them manually or resolve any conflicts.\033[0m"
fi

# Additional system-specific packages
if command -v apt-get &> /dev/null; then
    ADDITIONAL_PACKAGES=(
        "network-manager-gnome"
        "xss-lock"
        "pulseaudio"
        "fonts-inconsolata"
    )
else
    ADDITIONAL_PACKAGES=(
        "network-manager-applet"
        "xss-lock"
        "pulseaudio-utils"
        "pango"
        "ttf-inconsolata"
    )
fi

# Install additional packages
for package in "${ADDITIONAL_PACKAGES[@]}"; do
    if ! install_package "$package"; then
        FAILED_PACKAGES+=("$package")
    fi
done

# Clone and setup bumblebee-status
echo -e "${BLUE}Setting up bumblebee-status...${NC}"
git clone https://github.com/tobi-wan-kenobi/bumblebee-status.git ~/.config/bumblebee-status-main

# Copy i3 config
echo -e "${BLUE}Copying i3 config...${NC}"
cp i3/config ~/.config/i3/config

# Create default picom config if it doesn't exist
echo -e "${BLUE}Setting up picom config...${NC}"
if [ ! -f ~/.config/picom/picom.conf ]; then
    cat > ~/.config/picom/picom.conf << EOF
backend = "glx";
vsync = true;
shadow = true;
shadow-radius = 7;
shadow-offset-x = -7;
shadow-offset-y = -7;
shadow-opacity = 0.7;
fading = true;
fade-delta = 5;
fade-in-step = 0.03;
fade-out-step = 0.03;
EOF
fi

# Download sample wallpaper if not exists
echo -e "${BLUE}Setting up wallpaper...${NC}"
if [ ! -f ~/Pictures/main.jpg ]; then
    wget -O ~/Pictures/main.jpg https://raw.githubusercontent.com/i3/i3/next/docs/logo-30.png
fi

# Create lock screen image
echo -e "${BLUE}Setting up lock screen...${NC}"
if [ ! -f ~/Pictures/output.png ]; then
    convert ~/Pictures/main.jpg -blur 0x8 ~/Pictures/output.png
fi

# Copy wallpaper and lock screen images
echo -e "${BLUE}Setting up wallpaper and lock screen...${NC}"
if [ -f ./main.jpg ]; then
    cp ./main.jpg ~/Pictures/main.jpg || handle_error "Failed to copy wallpaper"
fi
if [ -f ./output.png ]; then
    cp ./output.png ~/Pictures/output.png || handle_error "Failed to copy lock screen image"
fi

# Set correct permissions
chmod +x ~/.config/i3/config

echo -e "${GREEN}Setup completed! Please log out and log back in with i3 to see the changes.${NC}"
echo -e "${GREEN}Note: You might need to manually configure some aspects of your system.${NC}"
echo -e "${GREEN}Additional steps you might want to take:${NC}"
echo "1. Customize your wallpaper by replacing ~/Pictures/main.jpg"
echo "2. Adjust picom configuration in ~/.config/picom/picom.conf"
echo "3. Modify i3 config to your liking in ~/.config/i3/config" 