#!/bin/bash

# Function to perform URL enumeration for a given domain
url_enumeration() {
    local domain=$1
    local date=$(date +'%Y-%m-%d')
    local base_dir="${domain}/$([ "$IGNORE_SPLIT" = "false" ] && echo "${date}/")"
    mkdir -p "${base_dir}"
    
    # gau
    echo "Running gau for ${domain}..."
    gau "${domain}" --subs --blacklist png,jpg,gif,jpeg,swf,woff,svg --o "${base_dir}/${domain}_temp_gau.txt"
    cat "${base_dir}/${domain}_temp_gau.txt" >> "${base_dir}/allUrls_${domain}.txt"
    rm "${base_dir}/${domain}_temp_gau.txt"
    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

    # katana
    echo "Running katana for ${domain}..."
    echo "${domain}" | katana -jc -silent >> "${base_dir}/allUrls_${domain}.txt"
    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

    # waymore
    echo "Running waymore for ${domain}..."
    waymore -i <(echo "${domain}") -mode U >> "${base_dir}/allUrls_${domain}.txt" 2>/dev/null
    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

    # Remove duplicate URLs
    echo "Removing duplicate URLs..."
    sort -u "${base_dir}/allUrls_${domain}.txt" -o "${base_dir}/allUrls_${domain}.txt"
    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

    echo "Getting live urls for ${domain}..."
    cat "${base_dir}/allUrls_${domain}.txt" | httpx -mc 200,403,500 -o "${base_dir}/liveallurls_${domain}.txt" 2>/dev/null
    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

    mkdir -p "${base_dir}/vulv/"
    
    #find endpoints for specific attacks
    tests=(
        "idor"
        "img-traversal"
        "interestingEXT"
        "interestingparams"
        "interestingsubs"
        "lfi"
        "rce"
        "redirect"
        "sqli"
        "ssrf"
        "ssti"
        "xss"
    )
    
    # Loop through each test variable and execute the command
    for test in "${tests[@]}"; do
        echo "Running gf for $test..."
        # Output the result to a file named after the test in the specified vuln subdirectory
        cat "${base_dir}/liveallurls_${domain}.txt" | gf $test > "${base_dir}/vulv/$test.txt"
    done

    paramspider --domain "${domain}" --exclude woff,css,js,png,svg,php,jpg --output "${base_dir}/paramspider_${domain}.txt"

}

# Check if domain is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Run the URL enumeration function with the provided domain
url_enumeration "$1"
