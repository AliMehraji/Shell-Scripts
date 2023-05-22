#! /bin/bash 

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
