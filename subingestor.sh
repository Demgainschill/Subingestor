#!/bin/bash
isLink=1

usage(){

	cat <<EOF
	Usage ./subingestor [-u|-h]
	-u  : Url provided for subfinder and dnsx to be reconned
	-l  : Load File to ingest from ( Added in future update )
	-h  : Display Help page
EOF

}



fileCheck(){
		if [[ -f "$1" ]]; then
			file="$1"
			echo "Ingesting subdomain file $1"

		else
			echo "Not a file"
			exit 1		
		fi
}

linkParser(){
	testLink="$1"
	grep -Eiwq "^(https?:\/\/)?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$" <<< "$testLink"
	if [[ $? -eq 0 ]]; then
		isLink=0
	else
		isLink=1
	fi
}

subFind(){
	echo "Finding Live Subdomains for $1"
	subfinder -d $1 -silent -active	
}

linkCheck(){
		link="$1"
		linkParser "$link"
		if [[ "$isLink" -eq 0 ]]; then
			subFind "$testLink"				
		else
			echo "Is not a link"
			exit 1
		fi	
}

while getopts ":hu:l:" opts; do
	case $opts in
		h)
			usage
			exit 1
			;;
		u)
			link="$OPTARG"
			if [[ -n $OPTARG ]]; then
				linkCheck "$link"	
			fi
			;;
		l)
			file="$OPTARG"
			if [[ -n $OPTARG ]] ; then
				fileCheck "$file"
				
			fi
			;;
		\?)
			echo "Invalid option"
			usage
			exit 1
			;;
		:)
			echo "Missing argument"
			usage
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

