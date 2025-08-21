# ----------------------------------------
# 🐋 WordPress + Apache + PHP 7.4
# ----------------------------------------
FROM wordpress:php7.4-apache

ENV DEBIAN_FRONTEND=noninteractive

# ----------------------------------------
# ⚡ Utils + WP-CLI + Python3 (for banner server)
# ----------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
      mariadb-client \
      curl unzip sudo \
      python3 \
  && curl -sS -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x /usr/local/bin/wp \
  && rm -rf /var/lib/apt/lists/*

# Prefer index.html first (then WP)
RUN sed -i 's#^\s*DirectoryIndex .*#DirectoryIndex index.html index.php#' /etc/apache2/mods-enabled/dir.conf

# Small Apache header (optional flair)
RUN a2enmod headers \
  && printf 'Header set X-Lab "AxCipher Intro Lab"\n' > /etc/apache2/conf-available/axcipher.conf \
  && a2enconf axcipher

# ----------------------------------------
# 📦 Seed files go to /opt/seed_html (NOT /var/www/html)
#   so the volume on /var/www/html won't shadow them.
# ----------------------------------------
RUN mkdir -p /opt/seed_html/hidden_dir
COPY landing/index.html /opt/seed_html/index.html
COPY landing.png        /opt/seed_html/landing.png
RUN printf "User-agent: *\nDisallow: /hidden_dir\n\n# 🚩 flag{robots_txt_exposed}\n" > /opt/seed_html/robots.txt \
  && printf "🚩 flag{dirb_exposed_directory}\n" > /opt/seed_html/hidden_dir/flag.txt \
  && printf "<?php\n// Fake backup, do not use in prod.\n// 🚩 flag{backup_file_exposed}\n" > /opt/seed_html/wp-config.bak \
  && chown -R www-data:www-data /opt/seed_html \
  && chmod 644 /opt/seed_html/index.html /opt/seed_html/landing.png /opt/seed_html/robots.txt /opt/seed_html/hidden_dir/flag.txt /opt/seed_html/wp-config.bak

# Banner text (CRLF)
RUN printf "220 AxCipher CTF Service ready 🚩 flag{nmap_banner_flag}\r\n" > /etc/motd.banner

# ----------------------------------------
# 📡 FAST banner server (send-and-close)
# ----------------------------------------
RUN set -eux; \
  echo "Writing /usr/local/bin/ctf1337.py"; \
  cat > /usr/local/bin/ctf1337.py <<'PY'
#!/usr/bin/env python3
import socket, threading, os

BANNER_PATH = "/etc/motd.banner"
DEFAULT = b"220 AxCipher CTF Service ready \xF0\x9F\x9A\xA9 flag{nmap_banner_flag}\r\n"

def banner():
    try:
        data = open(BANNER_PATH, "rb").read()
        return data.rstrip(b"\n") + b"\r\n"
    except Exception:
        return DEFAULT

def handle(conn):
    try:
        conn.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    except Exception:
        pass
    try:
        conn.sendall(banner())
        try:
            conn.shutdown(socket.SHUT_WR)   # signal EOF
        except Exception:
            pass
    finally:
        try: conn.close()
        except: pass

def main():
    s = socket.socket()
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("0.0.0.0", 1337))
    s.listen(50)
    print("[ctf1337] Listening on :1337", flush=True)
    while True:
        c, _ = s.accept()
        threading.Thread(target=handle, args=(c,), daemon=True).start()

if __name__ == "__main__":
    main()
PY
RUN chmod +x /usr/local/bin/ctf1337.py

# Entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
