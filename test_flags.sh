#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Starting AxCipher Lab flag checks..."

GREEN="✅"
RED="❌"

check_flag() {
  local desc="$1"
  local cmd="$2"
  echo -n "🔎 $desc... "
  result=$(eval "$cmd" 2>/dev/null || true)
  if [[ -n "$result" ]]; then
    echo "$GREEN Found!"
    echo "   ✅ $result"
  else
    echo "$RED Missing!"
  fi
}

# --- Web checks ---
check_flag "landing.png reachable (200 OK)" "curl -sI http://localhost:8080/landing.png | awk 'toupper(\$1)==\"HTTP/1.1\" || toupper(\$1)==\"HTTP/1.0\" {print \$2}' | grep -E '^(200)$'"
check_flag "Index page HTML comment flag"   "curl -s  http://localhost:8080/ | grep -i 'flag{'"
check_flag "robots.txt flag"                "curl -s  http://localhost:8080/robots.txt | grep -i 'flag{'"
check_flag "Hidden dir flag.txt"            "curl -s  http://localhost:8080/hidden_dir/flag.txt | grep -i 'flag{'"
check_flag "wp-config.bak flag"             "curl -s  http://localhost:8080/wp-config.bak | grep -i 'flag{'"

# --- Banner service on 1337 ---
check_flag "Netcat banner flag"             "echo | nc -w2 localhost 1337 | tr -d '\r' | grep -i 'flag{'"
check_flag "Nmap banner script flag"        "nmap --script=banner -p1337 localhost 2>/dev/null | grep -i 'flag{'"

echo "🎉 Flag test complete!"
