#!/bin/bash 

# ------------ SUBDOMAIN ENUMERATION WITH SUBFINDER ------------

subfinder_dns() {
    if [[ -z "$1" ]]; then
        echo "Usage: subfinder_dns <domain>"
        return 1
    fi

    local domain="$1"
    BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    SUBDOM_DIR="$BASE_DIR/outputs/subdomain"
    mkdir -p "$SUBDOM_DIR"

    local output_file="$SUBDOM_DIR/subfinder_${domain}_results.txt"

    echo " $domain..." | tee "$output_file"

    subfinder -d "$domain" | tee -a "$output_file"

    # Inform user where results are saved (do not append into the results file)
    echo "Results saved to: $output_file"
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
    echo "🌐 Starting Subfinder Enumeration..."
    subfinder_dns "$TARGET"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
