#!/bin/bash

# Check if domain is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Function to scan for JavaScript files, download them, and search for sensitive information
scan_js() {
    local domain=$1
    local date=$(date +'%Y-%m-%d')
    local base_dir="${domain}/$([ "$IGNORE_SPLIT" = "false" ] && echo "${date}/")"
    mkdir -p "${base_dir}"

    # Scan for JavaScript files
    echo "Scanning for JavaScript files on ${domain}..."
    echo "${domain}" | katana | grep "\.js$" | httpx -mc 200 | tee "${base_dir}/js.txt"
    # echo "${domain}" | gau | grep "\.js$" | httpx -mc 200 | tee "${base_dir}/js.txt"
    cat allUrls_${domain}.txt | grep "\.js$" | httpx -mc 200 | tee "${base_dir}/js.txt"
    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

    # Download each JavaScript file
    echo "Downloading JavaScript files..."
    # file="${base_dir}/js.txt"
    # while IFS= read -r link; do
    #     wget -q "$link" -P "${base_dir}/js_files/"
    # done < "$file"

    # mkdir -p "${base_dir}/js_files/"  && 
    xargs -a "${base_dir}/js.txt" -I {} wget -q {} -P "${base_dir}/js_files/"

    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

    # Search for sensitive information in downloaded JavaScript files
    echo "Searching for sensitive information in JavaScript files..."
    grep -r -E "aws_access_key|aws_secret_key|api key|passwd|pwd|heroku|slack|firebase" "${base_dir}/js_files/" | tee "${base_dir}/sensitive_info.txt"

    # nuclei -l js.txt -t ~/nuclei-templates/exposures/ -o js_bugs.txt
    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

    echo "JavaScript scanning completed. Results are stored in ${base_dir}."
}

# Run the JS scan function with the provided domain
scan_js "$1"
