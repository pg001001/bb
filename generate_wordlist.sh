#!/bin/bash

# Function to generate a custom word list from the domain content
generate_wordlist() {
    local domain=$1
    local date=$(date +'%Y-%m-%d')
    local base_dir="${domain}/$([ "$IGNORE_SPLIT" = "false" ] && echo "${date}/")"
    mkdir -p "${base_dir}"

    local output_file="${base_dir}/custom_wordlist.txt"
    # local temp_dir=$(mktemp -d)
    
    # Use cewl to generate word list
    echo "Generating word list"
    cewl -d 3 -m 1 -w "${output_file}" "${domain}"
    
    # Filter out common parameters and keywords
    # grep -E 'username|password|email|token|session|param|id|key|user|admin|login|signup|redirect|action|submit|file|page|lang|ref|search|query|filter|sort' "${output_file}" > "${domain}/filtered_$output_file"
    
    # # Display the generated word list
    # echo "Custom word list has been created and saved to: ${domain}/filtered_$output_file"
    # cat "${domain}/filtered_$output_file"
    
    # # Cleanup temporary directory
    # rm -rf "$temp_dir"
}

# Check if domain is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Generate custom word list
generate_wordlist "$1"
