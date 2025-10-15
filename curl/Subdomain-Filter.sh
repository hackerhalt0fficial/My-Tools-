subdomain_filter() {
    # Repo root and outputs path (derive relative to script location)
    BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    SUBDOM_DIR="$BASE_DIR/outputs/subdomain"
    mkdir -p "$SUBDOM_DIR"

    # Default to the outputs/subdomain directory
    local input_file="${1:-$SUBDOM_DIR/subdomain.txt}"
    local output_file="${2:-$SUBDOM_DIR/alive-subdomains.txt}"

    # Check if input file exists
    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file not found - $input_file"
        return 1
    fi

    echo "Starting subdomain filtering..."
    echo "Reading from: $input_file"
    echo "Target alive output: $output_file"

    # Prefer httpx, fall back to httpx-toolkit if present
    if command -v httpx >/dev/null 2>&1; then
        httpx_bin="httpx"
    elif command -v httpx-toolkit >/dev/null 2>&1; then
        httpx_bin="httpx-toolkit"
    else
        echo "Error: neither 'httpx' nor 'httpx-toolkit' found in PATH. Install one to continue."
        return 2
    fi

    # Use a temp file and only move results if non-empty
    tmp_out=$(mktemp) || { echo "Failed to create temp file"; return 3; }

    # Run httpx with sensible defaults
    # Keep concurrency reasonable; users can override by calling httpx directly if needed
    if [[ "$httpx_bin" == "httpx" ]]; then
        # httpx (projectdiscovery/httpx) usage
        cat "$input_file" | $httpx_bin -ports 80,443,8080,8000,8888 -threads 200 -silent > "$tmp_out"
        rc=$?
    else
        # httpx-toolkit may have different flags; attempt the common ones
        cat "$input_file" | $httpx_bin -ports 80,443,8080,8000,8888 -threads 200 > "$tmp_out" 2>&1
        rc=$?
    fi

    if [[ $rc -ne 0 ]]; then
        echo "Error: $httpx_bin failed (exit $rc). Check tool availability and network." 
        rm -f "$tmp_out"
        return 4
    fi

    if [[ -s "$tmp_out" ]]; then
        mv "$tmp_out" "$output_file"
        echo "Alive subdomains saved in: $output_file"
        return 0
    else
        rm -f "$tmp_out"
        echo "No alive hosts found in $input_file"
        return 0
    fi
}

# ------------ MAIN SCRIPT ------------
subdomain_filter