#! /bin/bash

# =================================================================

# Author: Ali Mehraji
# Email: a.mehraji75@gmail.com

# Script Name: Image_Prune.sh
# Date Created: Mon May 22 10:47:06 PM +0330 2023
# Last Modified: Tue Nov 21 06:29:01 PM +0330 2023

# Description:
# This script is for keeping last 2 image that built and tagged via different tags 

# Usage:
# You Can use this script like below:
# 1. bash Image_Prune.sh
# 2. First grant executable permission via chmod +x Image_Prune.sh and invoke it ./Image_Prune.sh

# =================================================================

# ======================== Start Of Code ==========================

set -e

_RM_DANGLING_IMAGE(){
  if [ "$(docker images -f "dangling=true" -q)" == "" ];then
    echo "There is no Dangling image to Remove."
  else
    docker rmi -f $(docker images -f "dangling=true" -q)
  fi
}

# keep last 2 builds for each image from the repository
_KEEP_TWO()
{
  # Docker images sorted and uniqed by repository
  _UNIQUE_IMAGES=`docker images --format "{{.Repository}}" | sort | uniq`

  for _UNIQUE_IMAGE in ${_UNIQUE_IMAGES[@]};
  do
    # reverse sorted by Created Time and their tag 
    # keep latest 2 images and provide except that two image:tags
    _IMAGE_TAGS=`docker images --format "{{.Repository}}:{{.Tag}};'{{.CreatedAt}}'" --filter reference="$_UNIQUE_IMAGE" | sort -t ';' -k2r | tail -n+3 | cut -d ';' -f1`

    for _IMAGE_TAG in ${_IMAGE_TAGS[@]};
    do
      if [ "$_IMAGE_TAG" == "" ]; then
        echo "There is no redundant Docker Image"
      else
        echo -e "\n------------------ Deleting $_IMAGE_TAG -----------------\n"
        docker rmi $_IMAGE_TAG
      fi
    done;
  done;
}

# First Remove Dangling images --> image_name:<none>
_RM_DANGLING_IMAGE

# After Removing dangling images remove all docker images but 2 latest ones , base on Created Time
_KEEP_TWO
