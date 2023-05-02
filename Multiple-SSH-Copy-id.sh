#! /bin/bash 
#
# TODO:
# 1) Port Function for Same port in all servers or are different
# 2) Createing and getting SSH Key Automate
# Add Comments And Project Description
# --------- Checking if SSH key exists in Local or Not -----------

_CHECK_KEY()
{
	echo -e "\n-------------- Checking SSH Key ---------------\n"
	read -p "Path to your public ssh key: " _SSH_KEY;
	if [[ ! -f $_SSH_KEY || "$_SSH_KEY" == "" ]];then
		echo "You Have No SSH Key!"
		echo "Creating an RSA Key"
		sleep 10;

		ssh-keygen -t rsa -b 4096;
		_SSH_KEY="$HOME/.ssh/id_rsa.pub" 
	fi
}

# ---------- Copy Users Rsa keygen to servers -----------

_SSH_COPY()
{
	_SSHPASS_PATH=$(which sshpass)
	if _CHECK_KEY; then
		# Check if sshpass package is installed or not!
		if [[ -f "$_SSHPASS_PATH" ]];then 
			for IP in `grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' $1`;do
				echo -e "\n-------------- Copying SSH Key For $IP ---------------\n"
				read -p "Enter SSH PORT For $IP: " PORT;
				# sshpass -e  will use en variable named SSHPASS
				SSHPASS="$PASSWORD" sshpass -e ssh-copy-id -p $PORT -i $_SSH_KEY -o "StrictHostKeyChecking=no" $USERNAME@$IP;
		  done
	  else
		  echo "You need to install 'sshpass' package!";
			# Exit with command not found exit code
		  exit 127
	  fi
	fi

}

read -p "Enter Your User Name in Servers: " USERNAME
read -sp "Enter Your Password in Servers: " PASSWORD
echo ""
_SSH_COPY $1

exit 0
