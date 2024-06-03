#!/bin/bash

# Function to run nuclei scan with technology-specific templates
run_nuclei_scan() {
    local domain=$1
    local date=$(date +'%Y-%m-%d')
    local base_dir="${domain}/$([ "$IGNORE_SPLIT" = "false" ] && echo "${date}/")"
    mkdir -p "${base_dir}"
    
    echo "running nuclie scans"
    cat "${base_dir}/allUrls_${domain}.txt" | grep = | tee "${base_dir}/param.txt"
    cat "${base_dir}/param.txt" | nuclei /home/user/fuzzing-templates
    
    echo "Nuclei scan completed. Results saved to ${base_dir}/"
}

# Check if domain is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

domain=$1

# Run nuclei scan with technology-specific templates
run_nuclei_scan "$domain" 
