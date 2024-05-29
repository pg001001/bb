#!/bin/bash

# Check if domain is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

domain=$1

# Ensure all required scripts are executable
# chmod +x subdomain_find.sh url_find.sh js_find.sh port_scan.sh

# Run subdomain enumeration script
echo "Starting subdomain enumeration..."
./subdomain_find.sh "$domain"

# Run URL enumeration script
echo "Starting URL enumeration..."
./url_find.sh "$domain"

# Run JavaScript file analysis script
echo "Starting JavaScript file analysis..."
./js_find.sh "$domain"

# Run port scanning script
echo "Starting port scanning..."
./port_scan.sh "$domain"

echo "All tasks completed for ${domain}. Results are stored in the respective directories."
