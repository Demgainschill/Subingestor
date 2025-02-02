#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

TARGET=""
LOAD_FILE=""
OUTPUT_FILE=""

# Parse options
while getopts "u:l:o:h" opt; do
  case $opt in
    u) TARGET=$OPTARG ;;
    l) LOAD_FILE=$OPTARG ;;
    o) OUTPUT_FILE=$OPTARG ;;
    h) echo "Usage: $0 -u <target domain> -l <load file> -o <output file>"; exit 0 ;;
    *) echo "Invalid option"; exit 1 ;;
  esac
done

# Ensure target or load file is provided
if [[ -z "$TARGET" && -z "$LOAD_FILE" ]]; then
  echo "Error: You must provide a target (-u) or a load file (-l)"
  exit 1
fi

# Set default output file
if [[ -z "$OUTPUT_FILE" ]]; then
  OUTPUT_FILE="${TARGET}_subdomains.txt"
fi

# Function to check if a subdomain is alive
check_alive() {
  local domain=$1
  if echo "$domain" | dnsx -silent -resp-only; then
    echo -e "${GREEN}[FOUND] $domain${NC}"
    echo "$domain,FOUND" >> "$OUTPUT_FILE"
  else
    echo -e "${RED}[NOT FOUND] $domain${NC}"
    echo "$domain,NOT_FOUND" >> "$OUTPUT_FILE"
  fi
}

# Load existing progress if file exists
if [[ -n "$LOAD_FILE" && -f "$LOAD_FILE" ]]; then
  echo "Loading progress from $LOAD_FILE..."
  cp "$LOAD_FILE" "$OUTPUT_FILE"
fi

# Find subdomains if target is provided
if [[ -n "$TARGET" ]]; then
  echo "Finding subdomains for $TARGET..."
  subfinder -d "$TARGET" -silent > subdomains.tmp
fi

# Combine found and loaded subdomains
cat subdomains.tmp "$OUTPUT_FILE" | awk -F',' '{print $1}' | sort -u > subdomains.txt

# Process subdomains with progress
TOTAL=$(wc -l < subdomains.txt)
COUNT=0

echo "Checking for live subdomains..."
> "$OUTPUT_FILE"
while IFS= read -r subdomain; do
  ((COUNT++))
  echo -ne "Progress: $COUNT/$TOTAL\r"
  check_alive "$subdomain"
done < subdomains.txt

echo "Subdomain enumeration complete. Results saved in $OUTPUT_FILE."

