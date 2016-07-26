#!/bin/bash
# @Author: doody
# @Date:   2016-07-21 12:30:59
# @Last Modified by:   swapsharma
# @Last Modified time: 2016-07-27 01:10:26
# @Todo: Support for all major os
# @Todo: Need to make script more robust

# To install git-annex
sudo apt-get install haskell-platform
git clone git://git-annex.branchable.com/ ~/git-annex

if [ `uname -s` = "Linux" ]; then
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 575159689BEFB442
	version=`lsb_release -r | cut -f2`
	case ${version} in
		16.04 ) echo 'deb http://download.fpcomplete.com/ubuntu xenial main'|sudo tee /etc/apt/sources.list.d/fpco.list
			;;
		15.10 ) echo 'deb http://download.fpcomplete.com/ubuntu wily main'|sudo tee /etc/apt/sources.list.d/fpco.list
			;;
		14.04 ) echo 'deb http://download.fpcomplete.com/ubuntu trusty main'|sudo tee /etc/apt/sources.list.d/fpco.list
			;;
		12.04 ) echo 'deb http://download.fpcomplete.com/ubuntu precise main'|sudo tee /etc/apt/sources.list.d/fpco.list
			;;
	esac

	sudo apt-get update && sudo apt-get install stack -y
fi

cd ~/git-annex
stack setup
stack install
mv ~/.local/bin/git-annex ~/bin

# TO set-up rclone
cd ~/
if [ `uname -s` = "Linux" ]; then
	arch=`uname -i`
	case ${arch} in
		x86_64 ) wget http://downloads.rclone.org/rclone-current-linux-386.zip
			;;
	esac
fi

unzip rclone-v1.17-linux-amd64.zip
cd rclone-v1.17-linux-amd64
#copy binary file
sudo cp rclone /usr/sbin/
sudo chown root:root /usr/sbin/rclone
sudo chmod 755 /usr/sbin/rclone
#install manpage
sudo mkdir -p /usr/local/share/man/man1
sudo cp rclone.1 /usr/local/share/man/man1/
sudo mandb 

# To set up git-annex-remote-rclone
cd ~
wget https://github.com/DanielDent/git-annex-remote-rclone/archive/master.zip
unzip git-annex-remote-rclone-master.zip
cd git-annex-remote-rclone-master
sudo cp git-annex-remote-rclone /usr/sbin
sudo chown root:root /usr/sbin/rclone
sudo chmod 755 /usr/sbin/rclone

# Steps to make git annex usage abstract
echo "
tool_init() {
	git annex init "My_Laptop"
	echo "$@"
	git annex initremote "$@"
}

tool_add() {
	git annex add $1
	git commit -m "Remote files added" $1
	git push -u origin master
	git annex sync --content
	git annex copy $1 --to $2
}

tool_get() {
	git annex sync
	git annex enableremote $2
	git annex get $1 --from $2
}

tool_opt() {
	case \$1 in
		initremote ) tool_init "${@:2}"
			;;
		add ) tool_add "${@:2}"
			;;
		get ) tool_get "${@:2}"
			;;
	esac
}

alias git_tool=tool_opt
" >> ~/.bash_aliases
source ~/.bash_aliases