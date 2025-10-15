#!/bin/bash 

# ------------ BRUTEFORCE SUBDOMAIN ENUMERATION WITH GOBUSTER ------------

gobuster_DNS() {
    if [[ -z "$1" ]]; then
        echo "Usage: gobuster_DNS <domain>"
        return 1
    fi

    local domain="$1"
    local output="subdomains_${domain}.txt"

    > "$output"

    echo "🔍 Starting background DNS scan: $domain"
    echo "💾 Saving subdomains to: $output"
    echo ""

    {
        counter=0
        gobuster dns -d "$domain" -w /opt/SecLists/Discovery/DNS/subdomains-top1million-110000.txt 2>/dev/null | \
        tee /dev/stderr | 
        while IFS= read -r line; do
            if [[ "$line" == *"Found:"* ]]; then
                subdomain=$(echo "$line" | awk '{print $2}')
                ((counter++))
                echo "$subdomain" >> "$output"
                echo "[$counter] 🎯 $subdomain"
            fi
        done
        echo "✅ Scan completed! Total: $counter subdomains"
    } &

    echo "🎯 Process running in background (PID: $!)"
    echo "📊 Monitor: tail -f $output"
}

# ------------ MAIN SCRIPT ------------

echo ""
echo "🚀 Starting scans for: $TARGET"
echo "=========================================="

echo ""
echo "🌐 Starting DNS Subdomain Enumeration..."
gobuster_DNS "$TARGET"