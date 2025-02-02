#!/bin/bash

usage(){
	cat <<EOF
	Usage
	-u  : Url provided for subfinder and dnsx to be reconned
	
EOF
}


while getopts ":u:" opts; do
	case $opts in
		u)
			link=$OPTARG
			echo $link	
			;;
		\?)
			echo "Invalid option"
			exit 1
			;;
		:)
			echo "Missing argument"
			exit 1
			;;
	esac
done
if [[ ! -n $1 ]]; then
	usage
	exit 
fi

shift $((OPTIND-1))

if [[ $# -ge 1 ]]; then
	echo "Too many arguments"
	usage
	exit 1
fi

