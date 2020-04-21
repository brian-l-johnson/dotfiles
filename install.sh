#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)
txtred=$(tput setaf 1)

base_packages=(
		  joe
		  tmux
		  screen
		  rsync
		  unison
		  fzf
		  ripgrep
		  git
		  build-essential
		);
		
i3_packages=(
		i3-wm
		rofi
		compton
		i3status
		feh
		fonts-font-awesome
		pavucontrol
		pasystray
		i3lock-fancy
		nm-tray
		blueman
		scrot
		dunst
	      );

yubikey_packages=(
		    scdaemon
		    gnupg-agent
		    yubikey-personalization-gui
		    yubikey-manager
		 );
	     
DOTFILESGITURI="brian-l-johnson/dotfiles.git"

symlink_config() {
	if [ ! -e $2 ]; then
		local DIR=$(dirname $2)
		if [ ! -d $DIR ]; then
			mkdir -p $DIR
		fi
		ln -s $1 $2
	else
		echo "${bold}${txtred}Cowardly refusing to symlink config${normal}"		
	fi 
}


install_linux() {
	case $( lsb_release -is ) in
		Ubuntu)
			echo "installing for Ubuntu"
			echo "${bold}Configre apt proxy?${normal}"
			select aptproxy in "Manual" "Automatic" "No"
			do
				case $aptproxy in
					Manual ) 
					echo "Acquire::http::Proxy \"http://manage:3142\";"| sudo tee /etc/apt/apt.conf.d/01proxy
						;;
					Automatic ) 
						sudo apt install auto-apt-proxy
						;;
					No ) echo "leaving alone";;
				esac
				break;
			done
			
			package_list=(${base_packages[@]})
			read -s -p "${bold}Install ssh server? [yN]${normal} " -n 1 sshd
			case $sshd in
				[yY]* )
					echo "yes"
					package_list=(${package_list[@]} "openssh-server")
					;;
				* ) echo "no";;
			
			esac
			read -s -p "${bold}Install i3 gui? [yN]${normal} " -n 1 i3
			case $i3 in
				[yY]* ) 
					echo "yes"
					package_list=(${package_list[@]} ${i3_packages[@]})
					;;

				*) echo "no";;
			esac
			read -s -p "${bold}Install Yubikey tools? [yN]${normal}" -n 1 yubikey
			case $yubikey in
				[yY]* )
					echo "yes"
					package_list=(${package_list[@]} ${yubikey_packages[@]})
					;;
				*) echo "no"
			esac
			sudo apt update
			sudo apt install -m $(echo ${package_list[*]})
			read -s -p "${bold}Copy ssh keys and config? [yN] ${normal}" -n 1 sshkeys
			if [[ ${yubikey^^} == "Y" ]]; then
				rsync -avp alexandria:/tank/config/gnupg ~/.gunpg
			fi
			
			case $sshkeys in
				[yY]*)
					echo "yes"
					rsync -avp alexandria:/tank/config/ssh ~/.ssh
					DOTFILESGITURI="git@github.com:$DOTFILESGITURI"
					;;
				*) 
					echo "no"
					DOTFILESGITURI="https://github.com/$DOTFILESGITURI"
					;;
			esac
			echo "${bold}Retrieving dotfiles${normal}"
			cd
			if [ ! -d "dev" ]
			then
				mkdir dev
			fi
			cd dev
			if [ ! -d "dotfiles" ]
			then
				echo "Retrieving dotfiles repo"
				git clone $DOTFILESGITURI
			else
				echo "Updating exiting dotfiles repo"
				cd dotfiles
				git pull
			fi
			cd
			symlink_config ~/dev/dotfiles/bash_aliases .bash_aliases
			symlink_config ~/dev/dotfiles/bash_profile .bash_profile

			case $i3 in
				[yY]* )
					echo "${bold}Symlinking configs${normal}"
					cd
					symlink_config ~/dev/dotfiles/i3/config .config/i3/config
					symlink_config ~/dev/dotfiles/compton/compton.conf .config/compton.conf
					symlink_config ~/dev/dotfiles/i3/i3status.conf .i3status.conf
					symlink_config ~/dev/dotfiles/rofi/config .config/rofi/config
				;;		
			esac
			
			echo "${bold}Loading dconf profiles${normal}"
			dconf load  /org/gnome/terminal/legacy/profiles:/ < ~/dev/dotfiles/dconf/gnome-terminal.dconf
			
			echo "${bold}You should now be setup, good luck!${normal}"
			;;
			
		*)
			echo "I don't know how to install for this distro";;
	esac
}



case $( uname -s ) in
	Linux) 
		install_linux
		;;
	*) 
		echo "I don't know how to install for this OS";;
esac
