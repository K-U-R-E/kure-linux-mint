#!/bin/bash

# Vinay's little setup tool for Linux and MacOS
# I move computers or crash them too often and
# I am lazy

# Check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Installs fish
install_fish() {
    sudo apt-get update
    sudo apt-get install -y fish
}

# Installs Neovim
install_neovim() {
    if command_exists nvim; then
        echo "Neovim is already installed."
    else
        echo "Installing Neovim via apt-get..."
        sudo apt-get update
        sudo apt-get install -y neovim

        # Install latest Neovim from GitHub
        # Can remove if apt-get starts having the latest version...
        echo "Installing the latest Neovim from GitHub..."
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
        tar -xvf nvim-linux64.tar.gz
        sudo mv nvim-linux64/bin/nvim /usr/local/bin
        rm -rf nvim-linux64 nvim-linux64.tar.gz
    fi
}

# Installs GCC
install_gcc() {
    if ! command_exists gcc; then
        sudo apt-get install -y build-essential
    else
        echo "GCC is already installed."
    fi
}

# Installs tmux
install_tmux() {
    if ! command_exists tmux; then
        sudo apt-get install -y tmux
    else
        echo "tmux is already installed."
    fi
}

# Installs rclone
install_rclone() {
    if ! command_exists rclone; then
        curl https://rclone.org/install.sh | sudo bash
    else
        echo "rclone is already installed."
    fi
}

# Installs Miniconda3
install_miniconda() {
    if command_exists conda; then
        echo "Miniconda is already installed."
    else
        echo "Downloading and installing Miniconda for Linux..."
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda3.sh
        chmod +x /tmp/miniconda3.sh
        sudo bash /tmp/miniconda3.sh -b -p /opt/miniconda3
    fi
}

# Installs pipx
install_pipx() {
    if command_exists pipx; then
        echo "pipx already installed"
    else
        echo "Installing pipx"
        sudo apt-get install -y pipx
        pipx ensurepath
        export PIPX_BIN_DIR=/usr/local/bin  # Fix the export command
    fi
}

# Installs AEL (custom tool setup)
install_AEL() {
    sudo apt-get install -y libgtk-3-dev libyaml-dev liburiparser-dev libjansson-dev libhdf5-dev libvte-2.91-dev libxcb-cursor0

    if command_exists daqd; then
        echo "Daqd is already installed"
    else
        cp AEL/daqd /usr/local/bin/
    fi

    if command_exists daqng; then
        echo "Daqng is already installed"
    else
        cp AEL/daqng /usr/local/bin/
    fi

    if command_exists daqng_gui; then
        echo "daqng_gui exists"
    else
        cp AEL/daqng_gui /usr/local/bin
    fi

    cp AEL/*svg /usr/share/pixmaps/
    cp AEL/*.desktop /usr/share/applications/
    cp AEL/*.service /usr/share/dbus-1/services/

    if command_exists daqview; then
        echo "DAQ View already installed"
    else
        pipx install daqview
    fi
}

# Installs user settings
install_user_settings() {
    echo "Installing Neovim user settings..."
    mkdir -p ~/.config/nvim
    cp ./nvim/* ~/.config/nvim/
    cp ./nvim/* /etc/skel/.config/nvim/

    echo "Copying Miniconda setup to profile.d..."
    sudo cp miniconda.sh /etc/profile.d/

    echo "Installing Fish settings..."
    mkdir -p ~/.config/fish
    cp ./fish/* ~/.config/fish/
    cp ./fish/* /etc/skel/.config/fish/

    if ! grep -q "$(which fish)" /etc/shells; then
        echo "Adding Fish to /etc/shells..."
        echo "$(which fish)" | sudo tee -a /etc/shells > /dev/null
    else
        echo "Fish shell is already in /etc/shells."
    fi

    echo "Changing default shell to Fish..."
    chsh -s "$(which fish)"
}

# Install all required packages and configurations
install() {
    echo "Installing Fish shell..."
    install_fish

    echo "Installing Neovim..."
    install_neovim

    echo "Installing Miniconda..."
    install_miniconda

    echo "Installing tmux..."
    install_tmux

    echo "Installing rclone..."
    install_rclone

    echo "Installing GCC..."
    install_gcc

    echo "Installing pipx..."
    install_pipx

    echo "Installing AEL..."
    install_AEL

    echo "Installing user settings..."
    install_user_settings

		echo "Creating users..."
		create_users
}

create_users(){
				if id "kureadmin" $> /dev/null; then
								echo "kureadmin already exists"
				else
								sudo useradd -m -s /usr/local/bin/fish kureadmin
								echo kureadmin:Kingston01 | sudo chpasswd
								sudo usermod -aG sudo kureadmin
								sudo usermod -aG dialout kureadmin
				fi
				if id "kureuser" $> /dev/null; then
								echo "kureuser already exists"
				else
								sudo useradd -m -s /usr/local/bin/fish kureadmin
								echo kureuser:kure | sudo chpasswd
								sudo chage -d 0 kureuser
								sudo usermod -aG dialout kureuser
				fi



# Main script logic
install

