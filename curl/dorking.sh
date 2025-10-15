#!/bin/bash
# ------------ DORKING WITH CURL AND GOOGLE SEARCH ------------

fetch_vulnweb_archives() {
  local target_domain="$1"
  local from_date="$2"
  local output_file="$3"
  local base_url="http://web.archive.org/cdx/search/cdx?url=${target_domain}/*&output=text&fl=original&collapse=urlkey"

  if [[ -n "$from_date" ]]; then
    base_url="${base_url}&from=${from_date}"
  fi

  # Fetch URLs and save to the output file
  curl -s "$base_url" | while read -r url; do
    echo "$url" >> "$output_file"
  done
}

# main Function Call

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUBDOM_DIR="$BASE_DIR/outputs/subdomain"
DORK_DIR="$BASE_DIR/outputs/dorking"
mkdir -p "$SUBDOM_DIR" "$DORK_DIR"

input_file="$SUBDOM_DIR/subdomain.txt"
if [[ ! -f "$input_file" ]]; then
  echo "File $input_file not found!"
  exit 1
fi

# Ensure curl is available
if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required but not found in PATH."
  exit 2
fi

while IFS= read -r domain || [[ -n "$domain" ]]; do
  # Trim whitespace from domain
  domain=$(echo "$domain" | xargs)
  if [[ -z "$domain" ]]; then
    continue
  fi

  output_file="$DORK_DIR/${domain}_archived_urls.txt"
  echo "Fetching archived URLs for domain: $domain"

  # Use a temp file and only save final file if there's content
  tmp_output=$(mktemp) || { echo "Failed to create temp file"; exit 1; }
  fetch_vulnweb_archives "$domain" "$FROM_DATE" "$tmp_output"

  if [[ -s "$tmp_output" ]]; then
    mv "$tmp_output" "$output_file"
    echo "URLs saved to $output_file"
  else
    rm -f "$tmp_output"
    echo "No archived URLs found for $domain; skipping file creation."
  fi
done < "$input_file"
