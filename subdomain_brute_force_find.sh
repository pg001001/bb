#!/bin/bash

# Function to perform subdomain brute force using gobuster
subdomain_brute_force() {
    local domain=$1
    local wordlist="/home/user/main/subdomains_brute_force/n0kovo_subdomains_tiny.txt"
    local output_file="${domain}_subdomains.txt"
    local base_dir="${domain}"

    mkdir -p "${base_dir}"

    echo "Running gobuster for subdomain brute force on ${domain}..."
    gobuster dns -d "$domain" -w "$wordlist" -o "${base_dir}/${domain}_subdomains_dns_brute.txt"

    echo "Subdomain brute force completed. Results saved to ${output_file}"
}

# Check if domain is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Run the subdomain brute force function with the provided domain
subdomain_brute_force "$1"
