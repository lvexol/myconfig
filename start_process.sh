#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting i3 setup process...${NC}"

# Create necessary directories
mkdir -p ~/.config/{i3,picom}
mkdir -p ~/Pictures

# Install required packages
echo -e "${BLUE}Installing required packages...${NC}"
if command -v pacman &> /dev/null; then
    # For Arch-based systems
    sudo pacman -S --noconfirm i3-gaps i3lock i3status \
        picom rofi feh kitty flameshot \
        network-manager-applet xss-lock \
        pulseaudio-utils pango ttf-inconsolata \
        git python python-pip
elif command -v apt-get &> /dev/null; then
    # For Debian-based systems
    sudo apt-get update
    sudo apt-get install -y i3-gaps i3lock i3status \
        picom rofi feh kitty flameshot \
        network-manager-gnome xss-lock \
        pulseaudio fonts-inconsolata \
        git python3 python3-pip
fi

# Clone and setup bumblebee-status
echo -e "${BLUE}Setting up bumblebee-status...${NC}"
git clone https://github.com/tobi-wan-kenobi/bumblebee-status.git ~/.config/bumblebee-status-main
pip install --user bumblebee-status

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

# Set correct permissions
chmod +x ~/.config/i3/config

echo -e "${GREEN}Setup completed! Please log out and log back in with i3 to see the changes.${NC}"
echo -e "${GREEN}Note: You might need to manually configure some aspects of your system.${NC}"
echo -e "${GREEN}Additional steps you might want to take:${NC}"
echo "1. Customize your wallpaper by replacing ~/Pictures/main.jpg"
echo "2. Adjust picom configuration in ~/.config/picom/picom.conf"
echo "3. Modify i3 config to your liking in ~/.config/i3/config" 