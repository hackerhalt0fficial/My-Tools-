# My-Tools

This repository contains various tools and wordlists used in security testing and enumeration.

> ⚠️ Note: The `rockyou.txt` wordlist is **not included in this repository** because it exceeds GitHub's 100MB file size limit.

## 🔽 How to Download `rockyou.txt`

You can download the `rockyou.txt` wordlist manually from trusted sources.

### 📥 Option 1: From Kali Linux (if installed)

If you're using Kali Linux or another pentesting distro, you likely already have it:

```bash
sudo gzip -d /usr/share/wordlists/rockyou.txt.gz
cp /usr/share/wordlists/rockyou.txt /your/project/path/Enumeration/Wordlists/
