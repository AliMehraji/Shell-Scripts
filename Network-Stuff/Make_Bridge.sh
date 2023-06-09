#! /bin/bash

# =================================================================

# Author: Ali Mehraji
# Email: a.mehraji75@gmail.com

# Script Name:  Make_Bridge.sh
# Date Created: Tue May 23 12:33:13 AM +0330 2023
# Last Modified: Tue May 23 12:33:13 AM +0330 2023

# Description: 
# Make a master , slave bridge ethernet for KVM usage 
# To Get Ip From DHCP

# Usage:
# bash Make_Bridge.sh  or ./Make_Bridge.sh

# =================================================================

# ======================== Start Of Code ==========================

set -e


# -------- Show Connections with nmcli -----------------------------------------------------
SHOW()
{
	read -p "Do You Need To See What Connections There Are?[y/n] " answer1
	answer1=${answer:-"y"}
	if [[ $answer1 = @("y"|"yes") ]];then
		echo "------------ You Have These Connections -----------------------"
		sudo nmcli connection show 
	fi
}

# ------ Choosing Ethernet to be slave for bridge --------------------------------------------
ETH()
{
	read -p "Which ethernet you need to be slave for $BR_NAME : " BR_INT
	while [[ $BR_INT = "" ]];do
		echo "You have to choose an etherntet connection"
		read -p "Which ethernet you need to be slave for $BR_NAME : " BR_INT
	done
}

# ------- Provide DNS -----------------------
DNS()
{
  read -p "Provide First DNS[8.8.8.8]:" DNS1
  DNS1=${DNS1:-"8.8.8.8"}
  read -p "Provide Second DNS[4.2.2.4]:" DNS2
  DNS2=${DNS2:-"4.2.2.4"}
}

# -------- bridge name ----------------------
Bridge()
{
  read -p "Name for bridge [br10]: " BR_NAME
  BR_NAME=${BR_NAME:-"br10"}

}

#----- provide GateWay -------------------------
Gateway()
{
  read -p "GateWay For $BR_NAME: " GW
	while [[ $GW = "" ]];do
		echo "Please Provide a gateway for $BR_NAME: "
    read -p "GateWay For $BR_NAME: " GW
	done
}

#---- Provide ip for bridge --------------------
Subnet_IP()
{
  echo "Subnet IP like '192.168.1.105/24'"
  read -p "Subnet IP For $BR_NAME: " SUBNET_IP
  while [[ $SUBNET_IP = "" ]];do
    echo "Please Provide a Subnet ip for $BR_NAME: "
    read -p "Subnet IP For $BR_NAME: " SUBNET_IP
  done

}

#--------- Dhcp for bridge ---------------
Auto()
{
	sudo nmcli connection modify ${BR_NAME} ipv4.method auto
}

# ------ Manual ip for bridge ------------
Manual()
{
	Subnet_IP
	Gateway
	sudo nmcli connection modify ${BR_NAME} ipv4.addresses ${SUBNET_IP} ipv4.method auto
	sudo nmcli connection modify ${BR_NAME} ipv4.gateway ${GW}

}
#--------- Method for ipv4 (dhcp or manual) ----
Method()
{
	read -p "Set $BR_NAME to get ip from dhcp?[Y/n] " answer2
	answer2=${answer2:-"Y"}
	if [[ $answer2 = "Y" ]];then
		Auto
	else
		Manual
	fi
}


### ------ Main Function -----------------------
Main()
{
	SHOW
	ETH 
	DNS
	Bridge

	#-------- main nmcli Commands ----------------
	sudo nmcli connection add type bridge autoconnect yes con-name ${BR_NAME} ifname ${BR_NAME}

	Method
	
	sudo nmcli connection modify ${BR_NAME} ipv4.dns ${DNS1} +ipv4.dns ${DNS2}
	sudo nmcli connection delete ${BR_INT}
	sudo nmcli connection add type bridge-slave autoconnect yes con-name ${BR_INT} ifname ${BR_INT} master ${BR_NAME}
	sudo nmcli connection up $BR_NAME

    # For getting ip from dhcp it needs to connection reload 
	echo "---------- Reloading Connections -------"
	sleep 5
	sudo nmcli connection reload
	sudo nmcli connection show
}

Main 
