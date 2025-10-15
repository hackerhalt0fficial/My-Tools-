# My-Tools

Collection of small enumeration and recon helper scripts.

This repository collects a variety of shell scripts that wrap popular tools (subfinder, gobuster, whatweb, httpx/httpx-toolkit, curl) and place results in a consistent outputs/ directory structure.

## 🔽 How to Download `rockyou.txt`

You can download the `rockyou.txt` wordlist manually from trusted sources.

### 📥 Option 1: From Kali Linux (if installed)

If you're using Kali Linux or another pentesting distro, you likely already have it:

```bash
sudo gzip -d /usr/share/wordlists/rockyou.txt.gz
cp /usr/share/wordlists/rockyou.txt /your/project/path/Enumeration/Wordlists/
```

---

## Project layout (relevant files)

- `Enumeration/http-enum.sh` — Web technology checks (whatweb) and subdomain enumeration orchestration (subfinder + gobuster). Writes under `outputs/enumeration/` and `outputs/subdomain/`.
- `Subdomain-Enum/` — standalone helpers for subfinder/gobuster (now aligned to outputs folder).
- `curl/dorking.sh` — archives/dorking helper using the Wayback CDX API. Writes into `outputs/dorking/` only if results exist.
- `curl/Subdomain-Filter.sh` — filters/validates subdomains using httpx/httpx-toolkit. Defaults to reading from `outputs/subdomain/subdomain.txt` and writing alive results to `outputs/subdomain/alive-subdomains.txt`.
- `outputs/` — new standardized outputs directory (contains `enumeration/`, `subdomain/`, `dorking/`).

---

## Outputs structure

All scripts now write into `outputs/` at the repository root. The recommended layout is:

- `outputs/enumeration/` — human-readable reports from enumeration tools (whatweb, nmap snippets, etc.)
- `outputs/subdomain/` — raw and processed subdomain lists
	- `subfinder_<domain>_results.txt` — raw subfinder output
	- `subdomains_<domain>.txt` — gobuster brute-forced subdomains
	- `subdomain.txt` — merged unique subdomains (filtered)
	- `alive-subdomains.txt` — reachable hosts after filtering by httpx
- `outputs/dorking/` — Wayback/CDX or dorking results per-domain (only created if non-empty)

This keeps outputs separated from scripts and makes it easier to archive or consume results programmatically.

---

## Prerequisites

Install the tools used by the scripts (examples):

```bash
# Debian/Ubuntu example
sudo apt update
sudo apt install -y gobuster curl jq

# install subfinder (check its docs) and whatweb
# install httpx/httpx-toolkit (e.g. go install or package)

# Install SecLists for the gobuster wordlist (optional but recommended)
sudo apt install -y seclists || true
ls -l /opt/SecLists/Discovery/DNS/subdomains-top1million-110000.txt
```

Note: On some distros SecLists is packaged in a different path. You can edit scripts to point at your preferred wordlist or export an env var.

---

## How to run (examples)

1) Run the main enumeration driver (interactive prompt for target):

```bash
bash Enumeration/http-enum.sh

# This will prompt for a target and then run: whatweb, subfinder, gobuster (background),
# deduplicate results into outputs/subdomain/subdomain.txt and trigger Subdomain-Filter.sh.
```

2) Run subfinder-only (standalone):

```bash
bash Subdomain-Enum/subfinder.sh
# set TARGET env var or modify the script to call subfinder_dns <domain>
```

3) Run gobuster-only (standalone):

```bash
bash Subdomain-Enum/gobuster.sh
# set TARGET env var or call gobuster_DNS <domain>
```

4) Run dorking to fetch Wayback URLs (writes to outputs/dorking/):

```bash
bash curl/dorking.sh
# ensure outputs/subdomain/subdomain.txt exists (from previous steps)
```

5) Run the subdomain filter to get alive hosts:

```bash
bash curl/Subdomain-Filter.sh
# defaults to outputs/subdomain/subdomain.txt and writes outputs/subdomain/alive-subdomains.txt
```

---

## Behavior changes made

- Scripts now derive a repository root (`BASE_DIR`) and write outputs to `outputs/` so results are centralized.
- Gobuster parsing was hardened to capture both stdout and stderr and extract subdomains reliably across versions.
- `dorking.sh` writes into `outputs/dorking/` and only creates per-domain files if they contain results.
- `Subdomain-Filter.sh` defaults now point to `outputs/subdomain/`.

---

## Troubleshooting

- If gobuster appears to produce no results, confirm the wordlist path exists:
	- `/opt/SecLists/Discovery/DNS/subdomains-top1million-110000.txt`
- If subdomain files are empty, check `outputs/subdomain/` for raw outputs from `subfinder` and `gobuster`.
- If a tool binary is missing, install it or change the script to point to the correct binary.

---

## Next improvements (suggested)

- Add a small CLI wrapper to accept input/output directory and target arguments.
- Add PID file management for background scans so they can be stopped cleanly.
- Run `shellcheck` and apply automated fixes for style/portability.
- Add a `README.md` inside `outputs/` describing the naming conventions.

---

If you want, I can implement any of the suggested next improvements (pick one) and wire it into the scripts.
