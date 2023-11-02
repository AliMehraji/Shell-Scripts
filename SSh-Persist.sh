#! /bin/bash

# =================================================================

# Author: Ali Mehraji
# Email: a.mehraji75@gmail.com

# Script Name: ssh-persist 
# Date Created: Mon May  1 12:37:48 AM +0330 2023
# Last Modified: Mon May  1 12:37:48 AM +0330 2023

# Description: 
# Checking ssh tunnel with a port is up if its not 
# Establishing a new Tunnel

# Usage:
# SSH Tunnel Automation with cronjob

# =================================================================

# ======================== Start Of Code ==========================

set -e

# First you need To add ssh key into destination Server,
# either with ssh-copy-id or just simple copy and paste public ssh key
# in to a file named authorized_keys in .ssh dir in Destination Server
#
# First Set executable permission 
# chmod +x sh-persist.sh
#
# then Set A simple Cronjob and use this script like below:
# */5 * * * *  $HOME/ssh-persist.sh >> $HOME/AutoSSH.log
#

TUN_PORT=
SSH_PORT=
REMOTE_USER=
REMOTE_HOST=

if [ `nc -zv 127.0.0.1 $TUN_PORT &> /dev/null; echo $?` -ne 0 ]
then
	echo -e " --------------- $(date) ----------------------------"
  echo ' > You missing SSH Tunnel. Creating one ...'
	ssh -p $SSH_PORT -CnfND 0.0.0.0:$TUN_PORT $REMOTE_USER@$REMOTE_HOST
fi

echo -e " > DO YOUR STUFF  < \n > SSH Tunnel Is Okay < "
echo -e " --------------- $(date) ----------------------------\n\n"
