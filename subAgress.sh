#!/bin/bash

usage(){
	cat <<EOF
	Usage ./
	-u  : Url provided for subfinder and dnsx to be reconned
	-l  : Load File to ingest from.	
EOF
}



fileCheck(){
		if [[ -f $1 ]]; then
			file="$1"
			echo "loading file $1"

		else
			echo "Not a file"
			exit 1		
		fi
}

linkParser(){
	link="$1"
	echo $link | grep -Eiwq "^(https?:\/\/)?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
	if [[ $? -eq 0 ]]; then
		isLink=0
	else
		isLink=1
	fi
}

linkCheck(){
		link="$1"
		linkParser "$link"
		if [[ "$isLink" -eq 0 ]]; then
			echo "Is a link"	
		else
			echo "Is not a link"
			exit 1
		fi	
}
while getopts ":u:l:" opts; do
	case $opts in
		u)
			link="$OPTARG"
			if [[ -n $OPTARG ]]; then
				linkCheck $link	
			fi
			;;
		l)
			file="$OPTARG"
			if [[ -n $OPTARG ]] ; then
				fileCheck $file
				
			fi
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

