#!/bin/bash

# Function to identify technologies running on a domain using whatweb
identify_technologies() {
    local domain=$1
    echo "Identifying technologies for ${domain}..."
    technologies=$(whatweb --log-verbose=stdout --quiet "$domain")
    echo "Technologies found: $technologies"
    echo "$technologies"
}

# Function to run nuclei scan with technology-specific templates
run_nuclei_scan() {
    local domain=$1
    local technologies=$2
    local base_dir="${domain}"
    
    mkdir -p "$base_dir"
    
    echo "Running general nuclei scan for ${domain}..."
    nuclei -u "$domain" -o "${base_dir}/general_scan.txt"
    
    if [[ $technologies == *"WordPress"* ]]; then
        echo "Running WordPress-specific nuclei templates..."
        nuclei -u "$domain" -t cves/2021/CVE-2021-29447.yaml -o "${base_dir}/wordpress_scan.txt"
        # Add more WordPress-specific templates here
    fi
    
    if [[ $technologies == *"Apache"* ]]; then
        echo "Running Apache-specific nuclei templates..."
        nuclei -u "$domain" -t cves/2021/CVE-2021-40438.yaml -o "${base_dir}/apache_scan.txt"
        # Add more Apache-specific templates here
    fi
    
    if [[ $technologies == *"nginx"* ]]; then
        echo "Running nginx-specific nuclei templates..."
        nuclei -u "$domain" -t cves/2013/CVE-2013-4547.yaml -o "${base_dir}/nginx_scan.txt"
        # Add more nginx-specific templates here
    fi
    
    echo "Nuclei scan completed. Results saved to ${base_dir}/"
}

# Check if domain is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

domain=$1

# Identify technologies
technologies=$(identify_technologies "$domain")

# Run nuclei scan with technology-specific templates
run_nuclei_scan "$domain" "$technologies"
