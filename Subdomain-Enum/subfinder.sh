#!/bin/bash 

# ------------ SUBDOMAIN ENUMERATION WITH SUBFINDER ------------

subfinder_dns() {
    if [[ -z "$1" ]]; then
        echo "Usage: subfinder_dns <domain>"
        return 1
    fi

    local domain="$1"
    local output_file="subfinder_${domain}_results.txt"

    echo " $domain..." | tee "$output_file"

    subfinder -d "$domain" | tee -a "$output_file"

    echo "$output_file" | tee -a "$output_file"
}


# ------------ MAIN SCRIPT ------------

echo ""
echo "🚀 Starting scans for: $TARGET"
echo "=========================================="

echo ""
echo "=========================================="

echo ""
echo "🌐 Starting Subfinder Enumeration..."
subfinder_dns "$TARGET"
