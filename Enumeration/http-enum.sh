#!/bin/bash 

# checking web Technology 

what_web(){
    echo "Checking Web Technology"
    echo 
    
    # Temporary file for processing
    temp_file=$(mktemp)
    
    # Run whatweb and save to temp file
    whatweb $IP --color=never > "$temp_file"
    
    # Color codes
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color
    
    echo -e "${BOLD}🔍 WEB TECHNOLOGY SCAN - KEY FINDINGS${NC}" | tee whatweb.txt
    echo "==========================================" | tee -a whatweb.txt
    echo -e "Target: ${BOLD}$IP${NC}" | tee -a whatweb.txt
    echo "Date: $(date)" | tee -a whatweb.txt
    echo "==========================================" | tee -a whatweb.txt
    echo "" | tee -a whatweb.txt
    
    # Extract and display ONLY critical information
    echo -e "${BOLD}🚀 CRITICAL TECHNOLOGIES:${NC}" | tee -a whatweb.txt
    echo "──────────────────────────" | tee -a whatweb.txt
    
    # Web Server
    if grep -q "HTTPServer" "$temp_file"; then
        server=$(grep -o "HTTPServer\[[^]]*\]" "$temp_file" | head -1 | sed 's/HTTPServer\[//;s/\]//')
        echo -e "${GREEN}🖥️  Web Server: $server${NC}" | tee -a whatweb.txt
    fi
    
    # IP Address
    if grep -q "IP" "$temp_file"; then
        ip=$(grep -o "IP\[[^]]*\]" "$temp_file" | head -1 | sed 's/IP\[//;s/\]//')
        echo -e "${BLUE}🌍 IP Address: $ip${NC}" | tee -a whatweb.txt
    fi
    
    # Country
    if grep -q "Country" "$temp_file"; then
        country=$(grep -o "Country\[[^]]*\]" "$temp_file" | head -1 | sed 's/Country\[//;s/\]//')
        echo -e "${YELLOW}🗺️  Country: $country${NC}" | tee -a whatweb.txt
    fi
    
    # Page Title
    if grep -q "Title" "$temp_file"; then
        title=$(grep -o "Title\[[^]]*\]" "$temp_file" | head -1 | sed 's/Title\[//;s/\]//')
        echo -e "${CYAN}📝 Page Title: $title${NC}" | tee -a whatweb.txt
    fi
    
    # Security Headers
    security_found=0
    if grep -q "X-Frame-Options" "$temp_file"; then
        xfo=$(grep -o "X-Frame-Options\[[^]]*\]" "$temp_file" | head -1 | sed 's/X-Frame-Options\[//;s/\]//')
        echo -e "${GREEN}🔒 X-Frame-Options: $xfo${NC}" | tee -a whatweb.txt
        security_found=1
    fi
    
    if grep -q "X-XSS-Protection" "$temp_file"; then
        xxss=$(grep -o "X-XSS-Protection\[[^]]*\]" "$temp_file" | head -1 | sed 's/X-XSS-Protection\[//;s/\]//')
        echo -e "${GREEN}🔒 X-XSS-Protection: $xxss${NC}" | tee -a whatweb.txt
        security_found=1
    fi
    
    # Cookies
    if grep -q "Cookies" "$temp_file"; then
        cookies=$(grep -o "Cookies\[[^]]*\]" "$temp_file" | head -1 | sed 's/Cookies\[//;s/\]//')
        echo -e "${YELLOW}🍪 Cookies: $cookies${NC}" | tee -a whatweb.txt
    fi
    
    # Technologies
    if grep -q "HTML5" "$temp_file"; then
        echo -e "${GREEN}📄 HTML5: Yes${NC}" | tee -a whatweb.txt
    fi
    
    if grep -q "Script" "$temp_file"; then
        echo -e "${GREEN}⚡ JavaScript: Yes${NC}" | tee -a whatweb.txt
    fi
    
    # Framework detection
    if grep -q "WordPress" "$temp_file"; then
        echo -e "${GREEN}🚀 WordPress: Detected${NC}" | tee -a whatweb.txt
    fi
    
    if grep -q "PHP" "$temp_file"; then
        echo -e "${GREEN}🐘 PHP: Detected${NC}" | tee -a whatweb.txt
    fi
    
    echo "" | tee -a whatweb.txt
    echo "==========================================" | tee -a whatweb.txt
    echo -e "${BOLD}✅ Scan Complete${NC}" | tee -a whatweb.txt
    echo "Full results saved to whatweb.txt" | tee -a whatweb.txt
    
    # Clean up
    rm -f "$temp_file"
    
    echo "Key technologies highlighted above."
}

# API Subdoamin Finding 


# Bruteforce Subdomain Finding 
gobuster_DNS(){
    output="subdomains_${IP}.txt"
    
    # Clear the output file at start
    > "$output"
    
    echo "🔍 Starting background DNS scan: $IP"
    echo "💾 Real-time output: $output"
    echo ""
    
    # Run in background but save in real-time
    {
    counter=0
    gobuster dns -d $IP -w /opt/SecLists/Discovery/DNS/subdomains-top1million-110000.txt 2>/dev/null | \
    while IFS= read -r line; do
        if [[ "$line" == *"Found:"* ]]; then
            subdomain=$(echo "$line" | awk '{print $2}')
            ((counter++))
            echo "$subdomain" >> "$output"
            echo "[$counter] 🎯 $subdomain"
        fi
    done
    echo "✅ Scan completed! Total: $counter subdomains" >> "$output"
    } &
    
    echo "🎯 Process running in background (PID: $!)"
    echo "📊 Monitor: tail -f $output"
}

# Function Call
read -p "🎯 Target IP/Domain: " IP

echo ""
echo "🚀 Starting scans for: $IP"
echo "=========================================="

# Run what_web scan
echo ""
echo "🔍 Starting Web Technology Scan..."
what_web

echo ""
echo "=========================================="

# Run gobuster DNS scan
echo ""
echo "🌐 Starting DNS Subdomain Enumeration..."
gobuster_DNS

echo ""
echo "=========================================="
echo "✅ All scans initiated for: $IP"
