#navigation
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
function mcd() { mkdir -p "$1"; cd "$1";}

#find
alias fhere='find . -name'
alias fihere='find . -iname'

#nmap
alias sortip='sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4'
alias gnmapip='cut -f 2 -d " "'

#archive
alias tgz='tar -zxvf'
alias tbz='tar -jxvf'
function extract () {
   if [ -f $1 ] ; then
       case $1 in
           *.tar.bz2)   tar xvjf $1    ;;
           *.tar.gz)    tar xvzf $1    ;;
           *.bz2)       bunzip2 $1     ;;
           *.rar)       unrar x $1       ;;
           *.gz)        gunzip $1      ;;
           *.tar)       tar xvf $1     ;;
           *.tbz2)      tar xvjf $1    ;;
	   *.tbz)	tar jxvf $1    ;;
           *.tgz)       tar xvzf $1    ;;
           *.zip)       unzip $1       ;;
           *.Z)         uncompress $1  ;;
           *.7z)        7z x $1        ;;
           *.xz)	unxz $1        ;;
           *)           echo "don't know how to extract '$1'..." ;;
       esac
   else
       echo "'$1' is not a valid file!"
   fi
 }

function o() {
  if [ -f $1 ] ; then
    case $1 in 
      *.pdf)	evince $1 ;;
      *.jpg)	eog $1 ;;
      *.gif)	eog $1 ;;
      *.png)	eog $1 ;;
      *.html)	chromium-browser $1 ;;
      *.docx)	libreoffice $1 ;;
      *.xlsx)	libreoffice $1 ;;
      *)	echo "I don't know how to open '$1'...";;
    esac
  else
    echo "'$1' is not a valid file!"
  fi
}

function update-dotfiles() {
  OD=`pwd`
  cd ~/dev/dotfiles
  git pull
  cd
  source .bash_profile
  source .bash_aliases
  cd $OD
  echo "Updated dotfiles, you may to to reload your session for some to take effect"
}

#misc
alias myip="curl http://ipecho.net/plain; echo"
alias backup='rsync -avP --exclude-from=$HOME/sync/`hostname -s`-exclude.txt ~/ alexandria:/tank/backups/systems/`hostname -s`/'
alias genpasswd='cat /dev/urandom | LC_ALL=C tr -cd [:alnum:] | head -c 30; echo'
alias fzfp="fzf --preview 'cat {}'"
alias weather="curl wttr.in"

#OS X specific aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
	#hide and show hidden files in finder
	alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
	alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && fillall Finder"

	#hide and show all desktop icons
	alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
	alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

	#lock screen
	alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

	#control volume
	alias stfu="osascript -e 'set volume output muted true'"
	alias pumpitup="osascript -e 'set volume output volume 100'"

	#unison in text mode
	alias unison="unison -ui text"

	#empty trash and cleanup various locations
	alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"

	#get md5sum and sha1sum
	command -v md5sum > /dev/null || alias md5sum="md5"
	command -v sha1sum > /dev/null || alias sha1sum="shasum"

fi

#Linux specific aliases

if [[ "$OSTYPE" == "linux-gnu" ]]; then
	#get pbcopy pbpaste
	alias pbcopy="xclip -selection clipboard"
	alias pbpaste="xclip -selection clipboard -o"
	alias afk="i3lock-fancy"
	alias vpn-up="nmcli --ask connection up tunesmith"
	alias vpn-down="nmcli connection down tunesmith"
	alias stfu="pactl set-sink-mute 0 1"
	alias mute=stfu
	alias unmute="pactl set-sink-mute 0 0"
fi