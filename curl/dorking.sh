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

  echo "URLs saved to $output_file"
}

# main Function Call

input_file="/home/halt/My-Tools-/subdomain.txt"
if [[ ! -f "$input_file" ]]; then
  echo "File $input_file not found!"
  exit 1
fi

while IFS= read -r domain || [[ -n "$domain" ]]; do
  # Trim whitespace from domain
  domain=$(echo "$domain" | xargs)
  if [[ -z "$domain" ]]; then
    continue
  fi

  output_file="${domain}_archived_urls.txt"
  # Clear previous output file if exists
  > "$output_file"

  echo "Fetching archived URLs for domain: $domain"
  fetch_vulnweb_archives "$domain" "$FROM_DATE" "$output_file"
done < "$input_file"
