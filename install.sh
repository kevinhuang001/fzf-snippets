#!/bin/bash

# Repository configuration
REPO_URL="https://raw.githubusercontent.com/kevinhuang001/fzf-snippets/master"
SCRIPT_NAME="sh-snippet.sh"
INSTALL_PATH="$HOME/.$SCRIPT_NAME"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}--- fzf-snippets Installer (Bash/Zsh) ---${NC}"

# 1. Check fzf
if ! command -v fzf &> /dev/null; then
    echo -e "${YELLOW}Warning: fzf is not installed.${NC}"
    echo -e "Please install it via your package manager:"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "  - macOS: ${GREEN}brew install fzf${NC}"
    elif command -v apt-get &> /dev/null; then
        echo -e "  - Debian/Ubuntu: ${GREEN}sudo apt install fzf${NC}"
    elif command -v pacman &> /dev/null; then
        echo -e "  - Arch Linux: ${GREEN}sudo pacman -S fzf${NC}"
    elif command -v dnf &> /dev/null; then
        echo -e "  - Fedora/CentOS: ${GREEN}sudo dnf install fzf${NC}"
    fi
    echo -e "After installing fzf, please run this installer again."
    exit 1
fi

# 2. Download the script
echo -e "${CYAN}Downloading $SCRIPT_NAME...${NC}"
if curl -fsSL "$REPO_URL/$SCRIPT_NAME" -o "$INSTALL_PATH"; then
    echo -e "${GREEN}Successfully downloaded to $INSTALL_PATH${NC}"
else
    echo -e "${RED}Failed to download $SCRIPT_NAME. Please check your network.${NC}"
    exit 1
fi

# 3. Add to shell config
SHELL_CONFIG=""
case "$SHELL" in
    */zsh) SHELL_CONFIG="$HOME/.zshrc" ;;
    */bash) SHELL_CONFIG="$HOME/.bashrc" ;;
    *) 
        echo -e "${YELLOW}Unknown shell. Please manually add 'source $INSTALL_PATH' to your shell config.${NC}"
        exit 0
        ;;
esac

if grep -q "source $INSTALL_PATH" "$SHELL_CONFIG" 2>/dev/null; then
    echo -e "${GREEN}Already configured in $SHELL_CONFIG${NC}"
else
    echo -e "\n# fzf-snippets\nsource $INSTALL_PATH" >> "$SHELL_CONFIG"
    echo -e "${GREEN}Added 'source $INSTALL_PATH' to $SHELL_CONFIG${NC}"
fi

echo -e "${CYAN}Installation complete! Please restart your terminal or run: source $SHELL_CONFIG${NC}"
