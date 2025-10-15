#!/bin/bash

# ------------ WEB TECHNOLOGY CHECK ------------

what_web() {
    if [[ -z "$1" ]]; then
        echo "Usage: what_web <domain>"
        return 1
    fi

    local target="$1"
    local temp_file=$(mktemp)
    local output_file="whatweb_${target}.txt"

    echo -e "Checking Web Technology for: $target" | tee "$output_file"
    echo "" | tee -a "$output_file"

    # Run whatweb streaming output to temp and file real-time
    whatweb "$target" --color=never | tee "$temp_file"

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
    local output_file="subfinder_${domain}_results.txt"

    echo "Running subfinder for domain: $domain..." | tee "$output_file"

    # Real-time output to terminal & file
    subfinder -d "$domain" | tee -a "$output_file"

    echo "Subfinder completed. Results saved to: $output_file" | tee -a "$output_file"
}

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
        tee /dev/stderr |  # Print all gobuster output to terminal
        while IFS= read -r line; do
            if [[ "$line" == *"Found:"* ]]; then
                # Extract only the subdomain after "Found:"
                subdomain=$(echo "$line" | awk '{print $2}')
                ((counter++))
                echo "$subdomain" >> "$output"  # Save only subdomain to file
                echo "[$counter] 🎯 $subdomain"
            fi
        done
        echo "✅ Scan completed! Total: $counter subdomains"
    } &

    echo "🎯 Process running in background (PID: $!)"
    echo "📊 Monitor: tail -f $output"
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

# Uncomment calls below to run scans as desired

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

echo ""
echo "=========================================="
echo "✅ All scans initiated for: $TARGET"
