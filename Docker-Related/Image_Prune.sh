#! /bin/bash

# =================================================================

# Author: Ali Mehraji
# Email: a.mehraji75@gmail.com

# Script Name: Image_Prune.sh
# Date Created: Mon May 22 10:47:06 PM +0330 2023
# Last Modified: Mon May 22 10:47:06 PM +0330 2023

# Description:
# This script is for keeping last 2 image that built and tagged via different tags 

# Usage:
# You Can use this script like below:
# 1. bash Image_Prune.sh
# 2. First grant executable permission via chmod +x Image_Prune.sh and invoke it ./Image_Prune.sh

# =================================================================

# ======================== Start Of Code ==========================

set -e

# keep last 2 builds for each image from the repository
_KEEP_TWO()
{
  # Docker images sorted and uniqed by repository
  for _UNIQUE_IMAGE in `docker images --format "{{.Repository}}" | sort | uniq`;
  do
    # reverse sorted by Created Time and their tag 
    # keep latest 2 images and provide except that two image:tags
    for _IMAGE_TAG in `docker images --format "{{.Repository}}:{{.Tag}};'{{.CreatedAt}}'" \
            --filter reference="$_UNIQUE_IMAGE" | sort -t ';' -k2r | tail -n+3 | cut -d ';' -f1`
    do
      echo -e "\n------------------ Deleting $_IMAGE_TAG -----------------\n"
      docker rmi $_IMAGE_TAG
    done;
  done;
}

_KEEP_TWO
