#!/bin/bash
#
# +--------------------------------------------+
# |                                            |
# |         Neovim Installation Script         |
# |                                            |
# +--------------------------------------------+
#
# 1. This script installs nvim with an AstroNvim configuration.
# 2. This script is for LINUX ONLY with x86-based architecture.
# 3. Make sure your terminal emulator has a font with Nerd Fonts. I recommend this one: https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.0/FiraCode.zip
# 4. Installation instructions:
#      - Right-click and select "Save as..." to download this script.
#      - Rename this file to `install-nvim.sh` and run `chmod +x install-nvim.sh` to make it executable.
#      - Run `./install-nvim.sh` to install nvim with an AstroNvim configuration.
#
#
#
#
#
#
#
#
#
#
#
#
#
# You can look at the script below, but you don't need to.
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#


# Function to print an error message in red
print_error() {
  echo -e "\e[31m[FAIL] $1\e[0m"
}

# Function to print a success message in green
print_success() {
  echo -e "\e[32m[OK] $1\e[0m"
}

# Function to print a skipped step in green
print_skip() {
  echo -e "\e[32m[SKIP] $1\e[0m"
}

print_info() {
  echo -e "\e[33m[INFO] $1\e[0m"
}

# Function to print installation instructions
print_install_instructions() {
  local program=$1
  local instruction=$2
  echo -e "To install $program, run: \e[33msudo $instruction\e[0m"
}

# To install everything: sudo apt install ranger rsync git fd-find xz-utils unzip wget ripgrep curl gcc python3-venv python3-pip
# Check if the required programs are installed
declare -A required_programs=(
  [git]="apt install git"
  [tar]="apt install tar"
  [wget]="apt install wget"
  [xz]="apt install xz-utils"
  [gcc]="apt install gcc"
  [unzip]="apt install unzip"
  [rsync]="apt install rsync"
  [rg]="apt install ripgrep"
  [curl]="apt install curl"
  [ranger]="apt install ranger"
  [fdfind]="apt install fd-find"
)

error_count=0

for program in "${!required_programs[@]}"; do
  if ! command -v "$program" &> /dev/null; then
    print_error "$program is not installed."
    print_install_instructions "$program" "${required_programs[$program]}"
    ((error_count++))
  else
    print_success "$program is installed."
  fi
done

# Special check for Python3 venv
if ! dpkg -l | grep 'python3.*-venv' &> /dev/null; then
  print_error "Python3 venv is not installed."
  print_install_instructions "Python3 venv" "apt install python3-venv"
  ((error_count++))
else
  print_success "Python3 venv is installed."
fi

# Special check for Python3-pip
if ! dpkg -l | grep 'python3-pip' &> /dev/null; then
  print_error "python3-pip is not installed."
  print_install_instructions "python3-pip" "apt install python3-pip"
  ((error_count++))
else
  print_success "python3-pip is installed."
fi

# If there were any errors, exit
if ((error_count > 0)); then
  print_info "Install everything using: sudo apt install ranger rsync git xz-utils fd-find wget ripgrep curl gcc python3-venv python3-pip unzip tar"
  exit 1
fi

# Create ~/.local if it doesn't exist
if [ ! -d "$HOME/.local" ]; then
  mkdir -p "$HOME/.local" || print_error "Failed to create $HOME/.local"
  print_success "Created $HOME/.local directory"
else
  print_skip "$HOME/.local already exists"
fi

# Download and extract nvim if it doesn't already exist
nvim_dir="$HOME/.local/nvim-linux64"
if [ ! -d "$nvim_dir" ]; then
  wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz -O /tmp/nvim-linux64.tar.gz || print_error "Failed to download nvim"
  tar -xzf /tmp/nvim-linux64.tar.gz -C /tmp || print_error "Failed to extract nvim"
  rsync -a /tmp/nvim-linux64/ "$HOME/.local/" || print_error "Failed to merge nvim into $HOME/.local"
  rm -rf "$HOME/.local/lib/nvim/parser" || print_error "Failed to remove nvim parser directory"
  rm -rf /tmp/nvim-linux64* || print_error "Failed to remove extracted nvim files"
  print_success "nvim installed and merged"
else
  print_skip "nvim already exists in $HOME/.local"
fi

# Clone astronvim if it doesn't already exist
astronvim_dir="$HOME/.config/nvim"
if [ ! -d "$astronvim_dir" ]; then
  git clone https://github.com/AstroNvim/AstroNvim "$astronvim_dir" || print_error "Failed to clone AstroNvim"
  print_success "AstroNvim installed"
else
  print_skip "AstroNvim already exists in $HOME/.config"
fi

# Download and extract node if it doesn't already exist
node_dir="$HOME/.local/node-v20.9.0-linux-x64"
if [ ! -d "$node_dir" ]; then
  wget https://nodejs.org/dist/v20.9.0/node-v20.9.0-linux-x64.tar.xz -O /tmp/node-v20.9.0-linux-x64.tar.xz || print_error "Failed to download node"
  tar -xf /tmp/node-v20.9.0-linux-x64.tar.xz -C /tmp || print_error "Failed to extract node"
  rsync -a /tmp/node-v20.9.0-linux-x64/ "$HOME/.local/" || print_error "Failed to merge node into $HOME/.local"
  rm -rf /tmp/node-v20.9.0-linux-x64* || print_error "Failed to remove extracted node files"
  print_success "node installed and merged"
else
  print_skip "node already exists in $HOME/.local"
fi

# Update shell PATH
bashrc_path="$HOME/.bashrc"
new_path="$HOME/.local/bin"

# Check if the new path is in the PATH environment variable
if ! echo ":$PATH:" | grep -q ":$new_path:"; then
  # Append new path to .bashrc if it's not already present in the file
  if ! grep -q "export PATH=.*$new_path" "$bashrc_path"; then
    echo "export PATH=\"$new_path:\$PATH\"" >> "$bashrc_path"
    print_success "Updated shell PATH and .bashrc."
    print_info "You must re-login or type 'source ~/.bashrc' to apply the changes."
  else
    print_skip "PATH is already set in .bashrc but not in current session. Please re-login or source your .bashrc."
  fi
else
  print_skip "PATH already contains $new_path"
fi

print_info "Sometimes, this script fails silently to update the PATH environment variable. If you are unable to run nvim, please add $HOME/.local/bin to your PATH manually."
print_info "Make sure your terminal emulator is using a font with Nerd Fonts. I recommend this one: https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.0/FiraCode.zip"
