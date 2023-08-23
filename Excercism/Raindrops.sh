#! /bin/bash

## https://exercism.org/tracks/bash/exercises/raindrops


# Usage ./Raindrop.sh <Your-Numbr>

# ------------- First Solution --------------------------
(( $1 % 3 )) || result+=Pling
(( $1 % 5 )) || result+=Plang
(( $1 % 7 )) || result+=Plong
echo ${result:-$1}

# -------------------------------------------------------
# There is Different between -A and -a 
# Options which set attributes:
#      -a	to make NAMEs indexed arrays (if supported)
#      -A	to make NAMEs associative arrays (if supported)
# -------------------------------------------------------

# ------------- Second Solution -------------------------
declare -a FACTORS
FACTORS["3"]="Pling"
FACTORS["5"]="Plang" 
FACTORS["7"]="Plong"
RESULT=""
for FACTOR in "${!FACTORS[@]}";
do
	if [[ $(( "$1" % "$FACTOR" )) == 0 ]]; then 
    RESULT+="${FACTORS["$FACTOR"]}"
  fi
done

[[ ! -z "$RESULT" ]] && echo $RESULT

# ------------- Third Solution -------------------------
set -o errexit
set -o nounset

main() {
	[[ $# -ne 1 ]] && exit 1

	local num=$1
	local str=""

	(( num % 3 == 0 )) && str+="Pling"
	(( num % 5 == 0 )) && str+="Plang"
	(( num % 7 == 0 )) && str+="Plong"

	echo "${str:-$num}"

}

main "$@"
