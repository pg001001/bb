#!/bin/bash

# Define usage/help message
usage() {
    echo "Usage: $0 [options]
Options:
  -h  Display this help message.
  -t  Target domain.
  -l  File with list of domains.
  -w  Wordlist.
  -d  Use Knockpy Deep mode.
  -f  Use Knockpy Fast mode.
  -g  Github token.
    -i  Ignore directory splitting."
    exit 1
}

# Initialize variables
TARGET_DOMAIN=""
DOMAIN_LIST=""
WORDLIST=""
GITHUB_TOKEN=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
IGNORE_SPLIT="false"
DEFAULT_WORDLIST="/home/user/wordlist/SecLists/Discovery/DNS/subdomains-top1million-5000.txt"

# Parse arguments
while getopts ":ht:l:w:dfg:i" opt; do
    case ${opt} in
        h ) usage ;;
        t ) TARGET_DOMAIN=${OPTARG} ;;
        l ) DOMAIN_LIST=${OPTARG} ;;
        w ) WORDLIST=${OPTARG} ;;
        d ) KNOCKPY_MODE="deep" ;;
        f ) KNOCKPY_MODE="fast" ;;
        #g ) GITHUB_TOKEN=${OPTARG} ;;
        i ) IGNORE_SPLIT="true" ;;
        \? ) echo "Invalid option: $OPTARG" 1>&2; exit 1 ;;
        : ) echo "Invalid option: $OPTARG requires an argument" 1>&2; exit 1 ;;
    esac
done

# Check if at least one of the required options is set
if [[ -z "$TARGET_DOMAIN" && -z "$DOMAIN_LIST" ]]; then
    echo "Either -t (target domain) or -l (domain list) must be specified."
    usage
fi

# Function to process a single domain
process_domain() {
    local domain=$1
    local date=$(date +'%Y-%m-%d')
    local base_dir="${domain}/$([ "$IGNORE_SPLIT" = "false" ] && echo "${date}/")"
    mkdir -p "${base_dir}"
    
    # Subdomain enumeration
    
    # subfinder
    echo "Running Subfinder for ${domain}..."
    subfinder -d "${domain}" -o "${base_dir}/subfinder.txt"
    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    
    # sublist3r
    echo "Running Sublist3r for ${domain}..."
    sublist3r -d "${domain}" -v -o "${base_dir}/sublist3r.txt"
    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    
    # amass
    echo "Running Amass for ${domain}..."
    #amass enum -passive -d "${domain}" -o "${base_dir}/amass.txt"
    amass intel -whois -d "${domain}" -o "${base_dir}/amass-intel.txt"
    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    
    # crst subdomain
    echo "Running Crst for ${domain}..."
    crtsh -d "${domain}" | tee "${base_dir}/crst.txt"
    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    
    # findomain subdomain
    echo "Running findomain for ${domain}..."
    findomain -t "${domain}" | tee -a "${base_dir}/findomain.txt"
    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    
    # assetfinder subdomain
    echo "Running assetfinder for ${domain}..."
    assetfinder "${domain}" | tee -a "${base_dir}/assetfinder.txt"
    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    
    # github to find domains
    # echo "Running Github Scan for ${domain}..."
    # python3 /home/user/tools/github-search/github-subdomains.py -d $domain -t $GITHUB_TOKEN -v | tee "${base_dir}/github.txt"
    # echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    
    # knockpy
    # echo "Running Knockpy in $KNOCKPY_MODE mode for ${domain}..."
    # knockpy -d "${domain}" --recon --bruteforce --save "${base_dir}/knockpy.txt"
    # echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    
    # # running wordlist to bruteforce domain search
    # if [[ -n "$WORDLIST" ]]; then
    #     # Use the user-provided wordlist
    #     WORDLIST_TO_USE="$WORDLIST"
    # else
    #     # Fallback to the default wordlist
    #     WORDLIST_TO_USE="$DEFAULT_WORDLIST"
    #     echo "Using default wordlist: $DEFAULT_WORDLIST"
    # fi
    
    # # Check that the wordlist to use exists
    # if [[ -f "$WORDLIST_TO_USE" ]]; then
    #     echo "Running Gobuster for ${domain}..."
    #     gobuster dns -d "${domain}" -w "$WORDLIST_TO_USE" -o "${base_dir}/gobuster.txt"
    #     if [[ $? -ne 0 ]]; then
    #         echo "Gobuster encountered an error with domain: ${domain}. Check above for details."
    #     fi
    # else
    #     echo "The specified wordlist file does not exist: $WORDLIST_TO_USE"
    # fi
    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

    echo "Finding live domains"
    find "${base_dir}" -name "*.txt" -exec cat {} + | sort -u | grep -i "${domain}" | tee "${base_dir}/all.txt"
    #cat "${base_dir}/all.txt" | httpx -ports 80,443,8080,8000,8081,8008,8888,8443,9000,9001,9090 -t 200 | sort -u | grep -i "${domain}" | tee "${base_dir}/all-live.txt"
    #httpx -l "${base_dir}/all.txt" -silent | sort -u > "${base_dir}/all-live.txt"   
    cat "${base_dir}/all.txt" | httprobe | sort -u > "${base_dir}/all-live.txt"


    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    
    # Gather and filter URLs
    echo "Gathering URLs for ${domain} with gau,katana,waybackurls"
    # cat "${base_dir}/all.txt" | gau --subs --blacklist png,jpg,gif,jpeg,swf,woff,svg --o "${base_dir}/allUrls.txt"
    gau "${base_dir}/all-live.txt" --subs --blacklist png,jpg,gif,jpeg,swf,woff,svg --o "${base_dir}/temp_gau.txt" && cat "${base_dir}/temp_gau.txt" >> "${base_dir}/allUrls.txt" && rm "${base_dir}/temp_gau.txt"
    cat "${base_dir}/all-live.txt" | katana -jc -silent  >> "${base_dir}/allUrls.txt"
    # cat "${base_dir}/all.txt" | waybackurls >> "${base_dir}/allUrls.txt" 2>/dev/null
    waymore -i "${base_dir}/all-live.txt" -mode U >> "${base_dir}/allUrls.txt" 2>/dev/null
    
    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    
    # find live urls
    echo "Getting live urls for ${domain}..."
    cat "${base_dir}/allUrls.txt" | httpx -mc 200,403,500 -o "${base_dir}/liveallurls.txt" 2>/dev/null
    echo cat "${base_dir}/liveallurls.txt" | wc -l  

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
        cat "${base_dir}/liveallurls.txt" | gf $test > "${base_dir}/vulv/$test.txt"
    done

    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

    # get js files 
    echo "Discovering sensitive data like apikeys, accesstoken, authorizations, jwt, etc in JavaScript files"
    grep -E '\.js(\?|$)' "${base_dir}/allUrls.txt" > "${base_dir}/js_files.txt"
    # cat "${base_dir}/js_files.txt" | uro | while read url; do python3 /home/user/recon/js/SecretFinder/SecretFinder.py -i $url -o cli; done
    
    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    
    # find open port if found using naabu and nmap
    echo "Searching for open ports on ${domain}..."
    cat "${base_dir}/all-live.txt" | naabu -top-ports 100 -nmap-cli 'nmap -sV -oX nmap-output' | tee -a "${base_dir}/ports.txt"

    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    
    echo "Processing for ${domain} completed. Results are in ${base_dir}."

    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

    #echo "Starting nuclie scans"
    #nuclei -t /home/user/nuclei-templates/ -l "${base_dir}/all-live.txt" -es info -o "${base_dir}/nucleiall.txt"
}

# Main logic to process either a single domain or a list of domains
if [[ -n "$TARGET_DOMAIN" ]]; then
    process_domain "$TARGET_DOMAIN"
    elif [[ -n "$DOMAIN_LIST" && -f "$DOMAIN_LIST" ]]; then
    while IFS= read -r domain; do
        process_domain "$domain"
    done < "$DOMAIN_LIST"
else
    echo "Domain list file $DOMAIN_LIST does not exist."
    exit 1
fi
