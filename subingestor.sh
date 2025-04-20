#!/bin/bash

## Subingestor a powerful recon tool using subfinder and dnsx for subdomain enumeration

b=$(tput setaf 4)
r=$(tput setaf 1)
g=$(tput setaf 10)
y=$(tput setaf 3)
reset=$(tput sgr0)
c=$(tput setaf 14)
o=$(tput setaf 208) 

isLink=1

usage(){

	cat <<EOF
${r}    _          _     _                                        ${reset}
${r}   | |        | |   (_)                       _               ${reset}
${r}    \ \  _   _| | _  _ ____   ____  ____  ___| |_  ___   ____ ${reset}
${r}     \ \| | | | || \| |  _ \ / _  |/ _  )/___)  _)/ _ \ / ___)${reset}
${r} _____) ) |_| | |_) ) | | | ( ( | ( (/ /|___ | |_| |_| | |    ${reset}
${r}(______/ \____|____/|_|_| |_|\_|| |\____|___/ \___)___/|_|    ${reset}
${r}                            {_____|                           ${reset}


      ${b}Usage${reset} ./${g}subingestor${reset} ${r}[-u|-h]${reset}
	${y}-u${reset}  : ${r}Url provided for ${reset}${y}subfinder${reset}${r} and ${reset}${y}dnsx${reset}${r} to be reconned ${reset}
	${y}-l${reset}  : ${r}Load File to ingest from ${reset}${b}( To be added in future updates ) ${reset}
	${y}-h${reset}  : ${r}Display Help page${reset}

	${b}Example${reset}:
		
	./${g}subingestor.sh${reset} ${y}-u${reset} ${b}google.com${reset}
		${y}Live Subdomains for google.com are as follows${reset}
		${b}dev.google.com${reset}
		${b}production.google.com${reset}
		...
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
	echo "${y}Finding Live Subdomains for $1${reset}"
	subfinder -d $1 -silent -active	
}

linkCheck(){
		link="$1"
		linkParser "$link"
		if [[ "$isLink" -eq 0 ]]; then
			subFind "$testLink"				
		else
			echo "Is not a link.Exiting.."
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
			echo "Invalid option.Exiting.."
			usage
			exit 1
			;;
		:)
			echo "Missing argument.Exiting.."
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
	echo "Too many arguments.Exiting.."
	usage
	exit 1
fi

