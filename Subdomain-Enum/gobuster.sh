#!/bin/bash 

# ------------ BRUTEFORCE SUBDOMAIN ENUMERATION WITH GOBUSTER ------------

gobuster_DNS() {
    if [[ -z "$1" ]]; then
        echo "Usage: gobuster_DNS <domain>"
        return 1
    fi

    local domain="$1"
    BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    SUBDOM_DIR="$BASE_DIR/outputs/subdomain"
    mkdir -p "$SUBDOM_DIR"

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
        domain_esc=${domain//./\.}

        gobuster dns -d "$domain" -w "$wordlist" 2>&1 | \
        while IFS= read -r line; do
            echo "$line" | grep -Eo "[A-Za-z0-9._%+-]+\.$domain_esc" | while IFS= read -r sub; do
                sub=$(echo "$sub" | tr -d '\r')
                if [[ -n "$sub" ]]; then
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

# ------------ MAIN SCRIPT (run only when executed directly) ------------
main() {
    echo ""
    if [[ -z "$TARGET" ]]; then
        read -p "🎯 Target IP/Domain: " TARGET
    fi
    if [[ -z "$TARGET" ]]; then
        echo "No target provided. Exiting."
        exit 1
    fi

    echo "🚀 Starting scans for: $TARGET"
    echo "=========================================="

    echo ""
    echo "🌐 Starting DNS Subdomain Enumeration..."
    gobuster_DNS "$TARGET"
}

# Only run main when script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi