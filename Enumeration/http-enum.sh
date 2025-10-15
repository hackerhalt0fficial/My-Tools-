#!/bin/bash

# Base directory (repo root)
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="$BASE_DIR/outputs"
ENM_DIR="$OUTPUT_DIR/enumeration"
SUBDOM_DIR="$OUTPUT_DIR/subdomain"

# Ensure directories exist
mkdir -p "$ENM_DIR" "$SUBDOM_DIR"

# ------------ WEB TECHNOLOGY CHECK ------------

what_web() {
    if [[ -z "$1" ]]; then
        echo "Usage: what_web <domain>"
        return 1
    fi

    local target="$1"
    local temp_file=$(mktemp)
    local output_file="$ENM_DIR/whatweb_${target}.txt"

    echo -e "Checking Web Technology for: $target" | tee "$output_file"
    echo "" | tee -a "$output_file"

    # Run whatweb streaming output to temp and file real-time
    # Save the full whatweb output to both the temp file (for parsing) and the final output file
    whatweb "$target" --color=never | tee "$temp_file" "$output_file"

    # Color codes for formatted output
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color

    echo -e "${BOLD}🔍 WEB TECHNOLOGY SCAN - KEY FINDINGS${NC}" | tee -a "$output_file"
    echo "==========================================" | tee -a "$output_file"
    echo -e "Target: ${BOLD}$target${NC}" | tee -a "$output_file"
    echo "Date: $(date)" | tee -a "$output_file"
    echo "==========================================" | tee -a "$output_file"
    echo "" | tee -a "$output_file"

    # Extract and display critical info from temp_file
    echo -e "${BOLD}🚀 CRITICAL TECHNOLOGIES:${NC}" | tee -a "$output_file"
    echo "──────────────────────────" | tee -a "$output_file"

    if grep -q "HTTPServer" "$temp_file"; then
        server=$(grep -o "HTTPServer\[[^]]*\]" "$temp_file" | head -1 | sed 's/HTTPServer\[//;s/\]//')
        echo -e "${GREEN}🖥️  Web Server: $server${NC}" | tee -a "$output_file"
    fi

    if grep -q "IP" "$temp_file"; then
        ip=$(grep -o "IP\[[^]]*\]" "$temp_file" | head -1 | sed 's/IP\[//;s/\]//')
        echo -e "${BLUE}🌍 IP Address: $ip${NC}" | tee -a "$output_file"
    fi

    if grep -q "Country" "$temp_file"; then
        country=$(grep -o "Country\[[^]]*\]" "$temp_file" | head -1 | sed 's/Country\[//;s/\]//')
        echo -e "${YELLOW}🗺️  Country: $country${NC}" | tee -a "$output_file"
    fi

    if grep -q "Title" "$temp_file"; then
        title=$(grep -o "Title\[[^]]*\]" "$temp_file" | head -1 | sed 's/Title\[//;s/\]//')
        echo -e "${CYAN}📝 Page Title: $title${NC}" | tee -a "$output_file"
    fi

    if grep -q "X-Frame-Options" "$temp_file"; then
        xfo=$(grep -o "X-Frame-Options\[[^]]*\]" "$temp_file" | head -1 | sed 's/X-Frame-Options\[//;s/\]//')
        echo -e "${GREEN}🔒 X-Frame-Options: $xfo${NC}" | tee -a "$output_file"
    fi

    if grep -q "X-XSS-Protection" "$temp_file"; then
        xxss=$(grep -o "X-XSS-Protection\[[^]]*\]" "$temp_file" | head -1 | sed 's/X-XSS-Protection\[//;s/\]//')
        echo -e "${GREEN}🔒 X-XSS-Protection: $xxss${NC}" | tee -a "$output_file"
    fi

    if grep -q "Cookies" "$temp_file"; then
        cookies=$(grep -o "Cookies\[[^]]*\]" "$temp_file" | head -1 | sed 's/Cookies\[//;s/\]//')
        echo -e "${YELLOW}🍪 Cookies: $cookies${NC}" | tee -a "$output_file"
    fi

    if grep -q "HTML5" "$temp_file"; then
        echo -e "${GREEN}📄 HTML5: Yes${NC}" | tee -a "$output_file"
    fi

    if grep -q "Script" "$temp_file"; then
        echo -e "${GREEN}⚡ JavaScript: Yes${NC}" | tee -a "$output_file"
    fi

    if grep -q "WordPress" "$temp_file"; then
        echo -e "${GREEN}🚀 WordPress: Detected${NC}" | tee -a "$output_file"
    fi

    if grep -q "PHP" "$temp_file"; then
        echo -e "${GREEN}🐘 PHP: Detected${NC}" | tee -a "$output_file"
    fi

    echo "" | tee -a "$output_file"
    echo "==========================================" | tee -a "$output_file"
    echo -e "${BOLD}✅ Scan Complete${NC}" | tee -a "$output_file"
    echo "Full results saved to $output_file" | tee -a "$output_file"

    rm -f "$temp_file"

    echo "Key technologies highlighted above."
}

# ------------ SUBDOMAIN ENUMERATION WITH SUBFINDER ------------

subfinder_dns() {
    if [[ -z "$1" ]]; then
        echo "Usage: subfinder_dns <domain>"
        return 1
    fi

    local domain="$1"
    local output_file="$SUBDOM_DIR/subfinder_${domain}_results.txt"

    echo " $domain..." | tee "$output_file"

    subfinder -d "$domain" | tee -a "$output_file"

    # Print where results were saved
    echo "Results saved to: $output_file"
}

# ------------ BRUTEFORCE SUBDOMAIN ENUMERATION WITH GOBUSTER ------------

gobuster_DNS() {
    if [[ -z "$1" ]]; then
        echo "Usage: gobuster_DNS <domain>"
        return 1
    fi

    local domain="$1"
    local output="$SUBDOM_DIR/subdomains_${domain}.txt"

    > "$output"

    echo "🔍 Starting background DNS scan: $domain"
    echo "💾 Saving subdomains to: $output"
    echo ""

    # Verify wordlist exists
    local wordlist="/opt/SecLists/Discovery/DNS/subdomains-top1million-110000.txt"
    if [[ ! -f "$wordlist" ]]; then
        echo "Error: Gobuster wordlist not found: $wordlist"
        echo "Please provide a valid wordlist or install SecLists."
        return 2
    fi

    {
        counter=0
        # Escape dots in domain for regex matching
        domain_esc=${domain//./\.}

        # Stream gobuster output (both stdout/stderr) and extract subdomains matching the domain
        gobuster dns -d "$domain" -w "$wordlist" 2>&1 | \
        while IFS= read -r line; do
            # Extract potential subdomains (alphanum, dot, underscore, hyphen) ending with the domain
            echo "$line" | grep -Eo "[A-Za-z0-9._%+-]+\.$domain_esc" | while IFS= read -r sub; do
                sub=$(echo "$sub" | tr -d '\r')
                if [[ -n "$sub" ]]; then
                    # Avoid duplicates
                    if ! grep -Fxq "$sub" "$output" 2>/dev/null; then
                        ((counter++))
                        echo "$sub" >> "$output"
                        echo "[$counter] 🎯 $sub"
                    fi
                fi
            done
        done
        echo "✅ Scan completed! Total: $counter subdomains"
    } &

    bg_pid=$!
    echo "🎯 Process running in background (PID: $bg_pid)"
    echo "📊 Monitor: tail -f $output"
}

# ------------ FILTER DUPLICATE SUBDOMAINS ------------

filter_duplicate_subdomains() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: filter_duplicate_subdomains <file1> <file2>"
        return 1
    fi

    local file1="$1"
    local file2="$2"
    local output_file="subdomain.txt"

    if [[ ! -f "$file1" ]]; then
        echo "Error: File not found - $file1"
        return 2
    fi

    if [[ ! -f "$file2" ]]; then
        echo "Error: File not found - $file2"
        return 3
    fi

    cat "$file1" "$file2" | sort -u > "$output_file"

    echo "Duplicates removed. Unique subdomains saved to: $output_file"
}

# ------------- MAIN SCRIPT EXECUTION -------------

read -p "🎯 Target IP/Domain: " TARGET

if [[ -z "$TARGET" ]]; then
    echo "No target provided. Exiting."
    exit 1
fi

echo ""
echo "🚀 Starting scans for: $TARGET"
echo "=========================================="

echo ""
echo "🔍 Starting Web Technology Scan..."
what_web "$TARGET"

echo ""
echo "=========================================="

echo ""
echo "🌐 Starting Subfinder Enumeration..."
subfinder_dns "$TARGET"

echo ""
echo "🌐 Starting DNS Subdomain Enumeration..."
gobuster_DNS "$TARGET"

# Wait a bit to ensure gobuster background process producing output (optionally wait or sync differently)
sleep 10

# Run duplicate filter on gobuster and subfinder outputs
filter_duplicate_subdomains "/home/halt/My-Tools-/subdomain/subdomains_${TARGET}.txt" "/home/halt/My-Tools-/subdomain/subfinder_${TARGET}_results.txt"

echo ""
echo "=========================================="
echo "✅ All scans initiated for: $TARGET"
echo "✅ Unique subdomains saved in subdomain.txt"

# /curl/Subdomain-Filter.sh
echo ""
echo "Starting Subdomain Filtering..."
bash /home/halt/My-Tools-/curl/Subdomain-Filter.sh

# /curl/dorking.sh
echo ""
echo "Starting Dorking with Curl..."
bash /home/halt/My-Tools-/curl/dorking.sh

