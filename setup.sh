#!/bin/bash

# Vinay's little setup tool for Linux and MacOS
# I move computers or crash them too often and
# I am lazy

command_exists() {
				command -v "$1" &>/dev/null
}

install_fish() {
				echo "Installing fish..."

				if command_exists fish; then
								echo "Fish exists, not installed"
				else
								sudo apt-get install -y fish
								echo "Fish installed..."
				fi
}

install_neovim() {

				echo "Installing neovim.."

				if command_exists nvim; then
								echo "Neovim exists, not installed."
				else
								sudo apt-get install -y neovim
								echo "Installed neovim from apt-get"

								echo "Installing the latest Neovim from GitHub..."
								curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
								tar -xvf nvim-linux64.tar.gz
								sudo mv nvim-linux64/bin/nvim /usr/local/bin
								rm -rf nvim-linux64 nvim-linux64.tar.gz

								echo "Neovim installed.."
				fi
}

install_gcc() {
				echo "Installing GCC..."
				if command_exists gcc; then
								echo "GCC exists, not installed..."
				else
								sudo apt-get install -y build-essential
								echo "GCC installed..."
				fi
}

install_tmux() {

				echo "Installing tmux..."
				if command_exists tmux; then
								echo "tmux exists, not installed..."
				else
								sudo apt-get install -y tmux
								echo "tmux installed..."
				fi
}

install_rclone() {
				if command_exists rclone; then
								echo "rclone exists, not installed..."
				else
								sudo apt-get install -y rclone
								echo "rclone installed..."
				fi
}

install_miniconda() {

				echo "Installing miniconda3 globally..."

				if command_exists conda; then
								echo "Miniconda exists, not installed..."
				else
								echo "Downloading and installing Miniconda for Linux..."
								wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda3.sh
								chmod +x /tmp/miniconda3.sh
								sudo bash /tmp/miniconda3.sh -b -p /opt/miniconda3
								echo "Miniconda3 installed..."

								ln -s /opt/miniconda3/bin/conda .
								./conda init
								rm conda
				fi
}

install_pipx() {
				echo "Installing pipx..."

				if command_exists pipx; then
								echo "pipx exists, not installed"
				else
								sudo apt-get install -y pipx
								echo "pipx installed.."

								pipx ensurepath
								echo "pipx ensured path..."

								export PIPX_HOME=/usr/local/share/pipx
								echo "PIPX_HOME changed to /usr/local/share/pipx..."

								export PIPX_BIN_DIR=/usr/local/bin
								echo "PIPX_BIN_DIR changed to /usr/local/bin..."

								echo "pipx installed globally..."
				fi
}

install_git(){

				echo "Installing git..."

				if command_exists git; then
								echo "Git exists,not installed"
				else
								sudo apt install -y git
								echo "Git installed.."
				fi
}

install_AEL() {
				echo "Installing Airborne Engineering Limited's DAQ software..."

				echo "Installing dependencies.."
				sudo apt-get install -y libgtk-3-dev libyaml-dev liburiparser-dev libjansson-dev libhdf5-dev libvte-2.91-dev libxcb-cursor0
				
				echo "Installing DAQd.."
				if command_exists daqd; then
						echo "DAQd exists, not installed..."
				else
						cp AEL/daqd /usr/local/bin/
						echo "DAQvd installed..."
				fi

				echo "Installing DAQng..."
				if command_exists daqng; then
						echo "DAQng exists, not installed..."
				else
						cp AEL/daqng /usr/local/bin/
						echo "DAQng installed..."
				fi

				if command_exists daqview; then
						echo "DAQview exists, not installed..."
				else
						pipx install daqview
						echo "DAQview installed.."
				fi

				echo "Installing DAQng_gui..."
				if command_exists daqng_gui; then
						echo "DAQng_gui exists, not installed..."
				else
						cp AEL/daqng_gui /usr/local/bin
						echo "DAQng_gui installed..."
				fi
				
				cp AEL/*svg /usr/share/pixmaps/
				echo "Copied AEL pixmaps..."

				cp AEL/*.desktop /usr/share/applications/
				echo "Copied AEL desktop files..."

				cp AEL/*.service /usr/share/dbus-1/services/
				echo "Copied AEL service..."

				echo "AEL DAQ Software installed..."

}

install_user_settings() {

				echo "Configuring standard user settings..."

				echo "Installing neovim settings..."
				mkdir -p /etc/skel/.config/nvim/
				cp -r ./nvim/* /etc/skel/.config/nvim/

				echo "Copying miniconda setup to profile.d..."
				sudo cp miniconda.sh /etc/profile.d/

				echo "Installing Fish settings..."
				mkdir -p /etc/skel/.config/fish/
				cp -r ./fish/* /etc/skel/.config/fish/

				if ! grep -q "$(which fish)" /etc/shells; then
						echo "Adding Fish to /etc/shells..."
						echo "$(which fish)" | sudo tee -a /etc/shells > /dev/null
				else
						echo "Fish shell is already in /etc/shells."
				fi

				echo "Changing default shell to Fish..."
				chsh -s "$(which fish)"
}

install_customisations(){
				echo "Installing KURE wallpapers..." 
				sudo mkdir -p /usr/share/backgrounds/kure
				cp ./wallpapers/* /usr/share/backgrounds/kure/
				sudo cp autowallpapers.sh /usr/local/bin/
				sudo chmod +x /usr/local/bin/autowallpapers.sh
				sudo cp autowallpapers.service /etc/systemd/system/ 
				mkdir -p /etc/skel/.config/cinnamon/backgrounds
				touch /etc/skel/.config/cinnamon/backgrounds/user-folders.lst
				if ! grep -q "/usr/share/backgrounds/kure" /etc/skel/.config/cinnamon/backgrounds/user-folders.lst; then

								echo "/usr/share/backgrounds/kure" | sudo tee -a /etc/skel/.config/cinnamon/backgrounds/user-folders.lst > /dev/null
				fi
}



# Install all required packages and configurations
install() {
				install_git
				install_fish
				install_neovim
				install_miniconda
				install_tmux
				install_rclone
				install_gcc
				install_pipx
				install_AEL
				install_user_settings
				install_customisations
}

create_users(){

				echo "Installing user accounts..."
				
				echo "Adding 'kureadmin' account..."
				if id "kureadmin" > /dev/null; then
								echo "kureadmin already exists"
				else
								sudo useradd -m -s $(which fish) kureadmin
				fi
				password=$(<admin_password.txt)
				rm admin_password.txt
				echo "kureadmin:$password" | sudo chpasswd
				sudo usermod -aG sudo kureadmin
				sudo usermod -aG dialout kureadmin

				echo "Adding 'kureuser' account..."
				if id "kureuser" > /dev/null; then
								echo "kureuser already exists"
				else
								sudo useradd -m -s $(which fish) kureuser
				fi
				echo "kureuser:kure" | sudo chpasswd
				sudo chage -d 0 kureuser
				sudo usermod -aG dialout kureuser

}

update_distro(){
				echo "Updating the distro..."
				sudo apt update

				echo "Upgrading the distro..."
				sudo apt upgrade -y
}


update_distro
install
create_users
