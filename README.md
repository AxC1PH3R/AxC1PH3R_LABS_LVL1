# AxC1PH3R LABS – Level 1 ⚙️🕵️‍♂️

Tiny Dockerized CTF lab:
- WordPress on **http://localhost:8080/**
- Banner service on **port 1337** prints 🚩 `flag{nmap_banner_flag}`
- Web flags in `robots.txt`, `/hidden_dir/`, and a fake `wp-config.bak`
- One-command tests via `./test_flags.sh`

[![CI](https://img.shields.io/badge/build-docker-blue)](#)
[![Made with ❤️ by AxC1PH3R](https://img.shields.io/badge/made%20by-AxC1PH3R-purple)](#)

---
## 📝 Lab Scope & Test Questions
⚠️ Disclaimer: This lab is for educational use only. Do not attempt these techniques on systems you don’t own or have permission to test.

The following are in-scope targets and questions to guide your testing:
- ❓ Question: Which flag is hidden in the HTTP headers?
- ❓ Question: What sensitive flag is left inside HTML comments?
- ❓ Question: Which disallowed entry reveals an exposed flag?
- ❓ Question: Which file leaks a flag when accessed directly?
- ❓ Question: Which flag is leaked due to backup file exposure?
- ❓ Question: Which flag is displayed in the service banner?

---

## 🚀 Quick Start

```bash
docker compose up -d --build
./test_flags.sh
```
---

# Open:
- Landing: http://localhost:8080/
- Blog (auto-installed to /blog): http://localhost:8080/blog
- Banner flag: nc localhost 1337

## 🧪 Flag Test Script
```./test_flags.sh
```
What it checks:
- landing.png returns 200 OK
- HTML comment flag on /
- robots.txt, /hidden_dir/flag.txt, wp-config.bak flags
- Port 1337 banner flag (nc + nmap)

---

## 🧰 Project Structure
```
.
├── ctf1337.py              # Banner service (port 1337)
├── docker-compose.yml      # WordPress + MariaDB + banner
├── Dockerfile              # Builds wp_ctf image
├── entrypoint.sh           # Seeds web root, starts banner, installs WP
├── flags                   # Extra flags (robots.txt, backup, hidden_dir)
│   ├── hidden_dir
│   ├── robots.txt
│   └── wp-config.bak
├── index.html              # Root landing
├── landing
│   ├── index.html
│   └── landing.png
├── landing.png             # Direct /landing.png
├── test_flags.sh           # CLI checker 🚩
├── uploads
│   └── landing.png
├── wait-for-mysql.sh       # (helper)
└── wp-flag-post.sh         # Seeds hidden WP post with a flag
```

---

## 🔧 Reset from scratch
```
docker compose down -v --remove-orphans
docker compose up -d --build
./test_flags.sh
```

---
## 🧩 Troubleshooting
Port open, but no banner?
Inside container:
```
docker compose exec wp_ctf bash -lc 'ss -ltnp | grep :1337 || true'
```
You should see a LISTEN on 0.0.0.0:1337.

Nmap slow? Use faster probes:
```
nmap --script=banner -p1337 localhost
nmap -sV --version-light --max-retries 0 -p1337 localhost
```
Landing 56 Recv failure?
Your volume may have shadowed baked files. Our entrypoint.sh auto-seeds /var/www/html from /opt/seed_html if empty.

---

## ⚠️ Notes
- All creds/flags are intentionally insecure for training.
- Don’t reuse in production.

---
### © License
```
MIT License

Copyright (c) 2025 AxC1PH3R

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including, without limitation, the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


