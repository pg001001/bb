#!/bin/bash

# Check if domain is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

domain=$1

# Ensure all required scripts are executable
# chmod +x subdomain_find.sh url_find.sh js_find.sh port_scan.sh generate_wordlist.sh

# Run subdomain enumeration 
echo "Starting subdomain enumeration..."
./subdomain_find.sh "$domain"

# Run URL enumeration 
echo "Starting URL enumeration..."
./url_find.sh "$domain"

# Run JavaScript file analysis 
echo "Starting JavaScript file analysis..."
./js_find.sh "$domain"

# Run port scanning 
echo "Starting port scanning..."
./port_scan.sh "$domain"

# Run custom wordlist generator 
echo "Starting generation of custom wordlist..."
./generate_wordlist.sh "$domain"

# Run nuclie scans for scanning bugs
# echo "Starting nuclie scans..."
# ./subdomain_brute_force_find.sh "$domain"

# Run subdomain dns brute force to find new domains
echo "Starting dns brute force..."
# ./nuclie_scan_1.sh "$domain"
./nuclie_scan_2.sh "$domain"

echo "All tasks completed for ${domain}. Results are stored in the respective directories."
