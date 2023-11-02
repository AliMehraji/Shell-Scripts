#! /bin/bash

# =================================================================

# Author: Ali Mehraji
# Email: a.mehraji75@gmail.com

# Script Name: renew ssh tunnel  
# Date Created: Mon May  1 12:47:19 AM +0330 2023
# Last Modified: Mon May  1 12:47:19 AM +0330 2023

# Description: 
# Sometimes ssh tuneel is connected but its not working as a functional Tunnel 
# and cant be used for purpuses.

# Usage:
# renewing ssh tunnel with cronjob

# =================================================================

# ======================== Start Of Code ==========================

set -e

# First you need To add ssh key into destination Server,
# either with ssh-copy-id or just simple copy and paste public ssh key
# in to a file named authorized_keys in .ssh dir in Destination Server

TUN_PORT=
SSH_PORT=
REMOTE_USER=
REMOTE_HOST=

# Killing ssh Tunnel -----------
for PROCID in `ps -aux | grep "$TUN_PORT" | grep -v grep | awk '{ print $2}'`
do
	echo "Killing process with $PROCID PID ..."
	kill -9 $PROCID
done

echo -e "----------- $(date) -----------"
echo "SSH Tunnel with Port $TUN_PORT Droped!"


# Issuing New SSH Tunnel -----------
ssh -p $SSH_PORT -CnfND 0.0.0.0:$TUN_PORT $REMOTE_USER@$REMOTE_HOST

echo "SSH Tunnel with Port $TUN_PORT Established!"
echo -e "----------- $(date) -----------\n"
