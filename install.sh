#!/bin/bash

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
		echo -e "\e[1;31mCowardly refusing to symlink config, $2 already exists\e[0m"		
	fi 
}

echo_bold() {
	echo -e "\e[1m$1\e[0m should be bold"
}

install_linux() {
	case $( lsb_release -is ) in
		Ubuntu)
			echo "installing for Ubuntu"
			echo -e "\e[1mConfigre apt proxy?\e[0m"
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
			echo -e "\e[1m"
			read -s -p "Install ssh server? [yN] " -n 1 sshd
			echo -en "\e[0m"
			case $sshd in
				[yY]* )
					echo "yes"
					package_list=(${package_list[@]} "openssh-server")
					;;
				* ) echo "no";;
			
			esac
			echo -e "\e[1m"
			read -s -p "Install i3 gui? [yN] " -n 1 i3
			echo -en "\e[0m"
			case $i3 in
				[yY]* ) 
					echo "yes"
					package_list=(${package_list[@]} ${i3_packages[@]})
					;;

				*) echo "no";;
			esac
			sudo apt update
			sudo apt install -m $(echo ${package_list[*]})
			echo -e "\e[1m"
			read -s -p "Copy ssh keys and config? [yN] " -n 1 sshkeys
			echo -en "\e[0m"
			case $sshkeys in
				[yY]*)
					echo "yes"
					scp -r alexandria:/tank/config/ssh ~/.ssh
					DOTFILESGITURI="git@github.com:$DOTFILESGITURI"
					;;
				*) 
					echo "no"
					DOTFILESGITURI="https://github.com/$DOTFILESGITURI"
					;;
			esac
			echo -e "\e[1m"
			echo "Retrieving dotfiles"
			echo -en "\e[0m"
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
					echo -e "\e[1m"
					echo "Symlinking configs"
					echo -en "\e[0m"
					cd
					symlink_config ~/dev/dotfiles/i3/config .config/i3/config
					symlink_config ~/dev/dotfiles/compton/compton.conf .config/compton.conf
					symlink_config ~/dev/dotfiles/i3/i3status .i3status.conf
					symlink_config ~/dev/dotfiles/rofi/config .config/rofi/config
				;;		
			esac
			echo -e "\e[1m"
			echo "You should now be setup, good luck!"
			echo -en "\e[0m"
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
