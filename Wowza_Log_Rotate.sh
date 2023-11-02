#! /bin/bash

# =================================================================

# Author: Ali Mehraji
# Email: a.mehraji75@gmail.com

# Script Name: Wowza_Log_Rotate.sh
# Date Created: Wed May 10 01:41:47 PM +0330 2023
# Last Modified: Wed May 10 01:41:47 PM +0330 2023

# Description:
# Because of Huge Size in Wowza Logs normal Logrotate doesn't - 
# Compress , So Wee need Pigz To do that in high usage of cpu workers

# Usage:
# bash Wowza_Log_Rotate.sh

# =================================================================

# ======================== Start Of Code ==========================

set -e

_WORKING_DIRECTORY=/usr/local/WowzaStreamingEngine/logs
_LOG_TO=/var/log/compressing_wowza_logs.log

# Compressing with pigz
function Compressing () {
        _DATE=$(date +"[%Y-%m-%d %H:%M]")
        echo "-------------------------------- Compressing ... $_DATE-----------------------------------"
        find $_WORKING_DIRECTORY -iname "*.log" -type f -mtime +1 -print -exec pigz -9 -p2 -q '{}' \; &>> $_LOG_TO
        # What options do in pigz 
        # -9   Highest Compression level
        # -k   Keeps Original log file
        # -p4  Uses 4 cpu cores
        # -q   Quiet 
        _DATE=$(date +"[%Y-%m-%d %H:%M]")
        echo $_DATE >> $_LOG_TO
        echo -en "-------------------------------- Compressed at $_DATE-----------------------------------\n\n"
}

function Remove_old () {
        _DATE=$(date +"[%Y-%m-%d %H:%M]")
        echo "---- Deleting Compressed Files older than 7 Days $_DATE ---------------------"

        find $_WORKING_DIRECTORY -iname "*.gz" -type f -mtime +7 -print -exec rm -f '{}' \; &>> $_LOG_TO

        _DATE=$(date +"[%Y-%m-%d %H:%M]")
        echo -en "---- Deleted at  $_DATE -----------------------------------------------------\n\n"
}

Compressing
Remove_old

unset _WORKING_DIRECTORY
unset _LOG_TO
unset _DATE
