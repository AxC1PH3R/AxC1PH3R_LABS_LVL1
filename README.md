# AxC1PH3R LABS – Level 1 ⚙️🕵️‍♂️

Tiny Dockerized CTF lab:
- WordPress on **http://localhost:8080/**
- Banner service on **port 1337** prints 🚩 `flag{nmap_banner_flag}`
- Web flags in `robots.txt`, `/hidden_dir/`, and a fake `wp-config.bak`
- One-command tests via `./test_flags.sh`

[![CI](https://img.shields.io/badge/build-docker-blue)](#)
[![Made with ❤️ by AxC1PH3R](https://img.shields.io/badge/made%20by-AxC1PH3R-purple)](#)

---

## 🚀 Quick Start

```bash
docker compose up -d --build
./test_flags.sh
