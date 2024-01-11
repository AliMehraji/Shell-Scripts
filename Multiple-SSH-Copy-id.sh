#! /bin/bash 

# =================================================================

# Author  : Ali Mehraji
# Email   : a.mehraji75@gmail.com

# Script Name   : Multiple-SSH-Copy-id.sh
# Created Date  : Wed May  3 01:44:20 AM +0330 2023 
# Last Modified : Thu Jan 11 11:40:38 PM +0330 2024

# Description: 
# 
# A Shell Script for Adding Public SSH Key to many Servers.

# Usage:
#
#        bash Multiple-SSH-Copy-id.sh IP-File.txt
# 
# IP-File.txt : A file Contains Destination Servers IP.
# This File Could be an ansible inventory.yml file or any file contain IP Adresses

# ======================== Start Of Code ==========================

set -e
set -o nounset                # unset variables as an error


# --------- Generating SSH Key Pair -----------------------------

_GEN_SSH_KEY()
{
	read -p "What Type of SSH Key to be Generated [default=rsa]? : " _SSH_KEY_TYPE
	_SSH_KEY_TYPE=${_SSH_KEY_TYPE:-rsa}

	_SSH_KEY_TYPES=(dsa ecdsa ecdsa-sk ed25519 ed25519-sk ssa rsa)
	if [[ "${_SSH_KEY_TYPES[@]}" =~ "${_SSH_KEY_TYPE,,}" ]];then
	  ssh-keygen -t ${_SSH_KEY_TYPE} -b 4096  -N "";
	else
	  echo "${_SSH_KEY_TYPE} is'nt an SSH Key Type, Creating the default type [rsa]."
		ssh-keygen -t rsa -b 4096;
	fi
}

# --------- Checking if SSH key exists in Local or Not ----------

_CHECK_KEY()
{
	echo -e "\n-------------- Checking SSH Key ---------------\n"

	# Getting/Setting The Public SSH KEY File
	read -p "Path to your Public SSH Key [default=$HOME/.ssh/id_rsa.pub] : " _PUB_SSH_KEY_FILE;
	_PUB_SSH_KEY_FILE=${_PUB_SSH_KEY_FILE:-"$HOME/.ssh/id_rsa.pub"}

	# In Case of The SSH Key not Found.
	if [[ ! -f $_PUB_SSH_KEY_FILE ]]; then

	  echo "> ${_PUB_SSH_KEY_FILE}: No Such file or directory."
	  read -p "Do You Want Me To Generate One [Y/n][default=y]? " _GENERATE
	  _GENERATE=${_GENERATE:-y}
	
	  # ${VARIABLE,,} --> In Bash it lowers the variable.
    if [[ "${_GENERATE,,}" =~ (y|yes) ]]; then
	    _GEN_SSH_KEY
	  else
	    echo "You Can Generate an SSH Key via: "
		  echo -en "\n\tssh-kegen -t <SSH-Key-Type>\t\n"
		  echo "Have A good Day."
		  # Exit with command not found exit code
		  exit 127
	  fi

	elif [[ -f $_PUB_SSH_KEY_FILE ]]; then
		echo "Using ${_PUB_SSH_KEY_FILE} As Public Key For Copying in Servers."
	fi
}

_INSTALL_SSHPASS()
{
	# Identifying OS Package Manager
	declare -A OSInfo;
	OSInfo[/etc/fedora-release]=dnf
	OSInfo[/etc/redhat-release]=yum
	OSInfo[/etc/arch-release]=pacman
	OSInfo[/etc/gentoo-release]=emerge
	OSInfo[/etc/SuSE-release]=zypp
	OSInfo[/etc/debian_version]=apt-get
	OSInfo[/etc/alpine-release]=apk

	_SUPPORTED_OS=false

	for OS_FILE in "${!OSInfo[@]}";
	do
		if [ -e "$OS_FILE" ]; then
			_PCKG_MNG="${OSInfo[$OS_FILE]}"
			sudo ${_PCKG_MNG} install -y sshpass
			_SUPPORTED_OS=true
			break
	  fi  
	done

	if [ "$_SUPPORTED_OS" = false ]; then
    echo "Unsupported Linux Distro."
		echo "Search What is Your Package Manager."
		exit 1
	fi

}

_CHECK_SSH_PASS_INSTALLED()
{
	if ! command -v sshpass &> /dev/null; then 
	  echo -e "\n-------------- Checking SSHPass Command -------\n"
		echo "The sshpass command was not found.";
		read -p "Do You Want Me To install it [Y/n]? " _INSTALL

		if [[ "${_INSTALL,,}" =~ (y|yes) ]]; then 
			_INSTALL_SSHPASS
		else
			echo "Your Answer Was not correct: ${_INSTALL}"
			echo "You Can install it vis bellow command:"
			echo -en "\n\t${PCKG_MNG} install sshpass\t\n"
			# Exit with command not found exit code
			exit 127
		fi
	fi
}

_SSHPASS_COMMAND()
{
	SSHPASS="$PASSWORD" sshpass -e ssh-copy-id -p $_SSH_PORT -i $_PUB_SSH_KEY_FILE -o "StrictHostKeyChecking=no" $USERNAME@$IP;
}

# ---------- SSH PORT  ----------------------------------

_DIFF_SSH_PORTS()
{
	# Finding IP in file with Regex. The file will be passed to script as "$1".
	for IP in `grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' $1`
	do
		read -p "Enter SSH PORT For $IP: " _SSH_PORT;
		echo -e "\n-------------- Copying SSH Key For $IP ---------------\n"
		_SSHPASS_COMMAND
	done
}

_SAME_SSH_PORT()
{
	# User Input for SSH Port Number 
  read -p "Please Enter The SSH Port Value [default=22]: " _SSH_PORT
  # If User Hit Enter With no Value , Default will be 22
  _SSH_PORT=${_SSH_PORT:-22}

  for IP in `grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' $1`
  do
    echo -e "\n-------------- Copying SSH Key For $IP ---------------\n"
	  _SSHPASS_COMMAND
  done
}

_SSH_KEY_COPY()
{
	# User Input For Yes/No answer for ssh port number
	
	if _CHECK_KEY && _CHECK_SSH_PASS_INSTALLED;then
		echo -en "-------------- Checking SSH PORT --------------\n"
	  read -p "All Servers SSH Ports is (22) ? [Y/n]: " _ANSWER

	# Chacking What The Answer was.
		case ${_ANSWER} in 
			# For Answer No (n/N)
			[nN]*)
				_DIFF_SSH_PORTS $1
				;;
			# For Answer yes (y/Y)
			[yY]*)
				_SAME_SSH_PORT $1
				;;
			*)
				echo "You Need To Enter y/Y or n/N. $REPLY"
				exit 1
				;;
		esac
	fi
		  
}
 
# ---------- Copy Users Rsa keygen to servers -----------


read -p "Enter Your User Name in Servers: " USERNAME
read -sp "Enter Your Password in Servers: " PASSWORD
echo ""
_SSH_KEY_COPY $1

exit 0
