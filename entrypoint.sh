#!/bin/bash
set -e

# --- env sanity ---
: "${WORDPRESS_DB_HOST:?WORDPRESS_DB_HOST missing}"
: "${WORDPRESS_DB_USER:?WORDPRESS_DB_USER missing}"
: "${WORDPRESS_DB_PASSWORD:?WORDPRESS_DB_PASSWORD missing}"
: "${WORDPRESS_DB_NAME:?WORDPRESS_DB_NAME missing}"

DB_HOST="${WORDPRESS_DB_HOST%%:*}"
DB_PORT="${WORDPRESS_DB_HOST##*:}"
[[ "$DB_PORT" == "$DB_HOST" ]] && DB_PORT=3306
echo "ℹ Using DB → $DB_HOST:$DB_PORT (db=${WORDPRESS_DB_NAME}, user=${WORDPRESS_DB_USER})"

# --- start banner FIRST (fast nmap every time) ---
echo "📡 Starting banner on 1337/tcp (send-and-close; fast)"
python3 /usr/local/bin/ctf1337.py &
sleep 0.2

# --- seed /var/www/html if empty (volume shadowing fix) ---
if [ "$(find /var/www/html -mindepth 1 -maxdepth 1 | wc -l)" -eq 0 ]; then
  echo "🌱 Seeding /var/www/html from /opt/seed_html ..."
  cp -a /opt/seed_html/* /var/www/html/
  chown -R www-data:www-data /var/www/html
else
  # make sure landing assets exist even if volume already had WP content
  for f in index.html landing.png robots.txt wp-config.bak; do
    if [ ! -e "/var/www/html/$f" ] && [ -e "/opt/seed_html/$f" ]; then
      cp -a "/opt/seed_html/$f" "/var/www/html/$f"
    fi
  done
  if [ ! -e "/var/www/html/hidden_dir/flag.txt" ]; then
    mkdir -p /var/www/html/hidden_dir
    cp -a /opt/seed_html/hidden_dir/flag.txt /var/www/html/hidden_dir/flag.txt
  fi
  chown -R www-data:www-data /var/www/html
fi

# --- wait for DB (best-effort; don't kill banner on transient failure) ---
set +e
echo "⏳ Waiting for MariaDB..."
until mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
  echo "❌ DB not ready yet..."
  sleep 3
done
echo "✅ Database is ready!"
set -e

# --- WordPress under /var/www/html/blog ---
WP_PATH="/var/www/html/blog"
if [ ! -f "$WP_PATH/wp-settings.php" ]; then
  echo "📥 Downloading WordPress core to $WP_PATH ..."
  wp core download --path="$WP_PATH" --allow-root
fi
if [ ! -f "$WP_PATH/wp-config.php" ]; then
  echo "⚙ Generating wp-config.php ..."
  wp config create \
     --path="$WP_PATH" \
     --allow-root \
     --dbhost="$WORDPRESS_DB_HOST" \
     --dbname="$WORDPRESS_DB_NAME" \
     --dbuser="$WORDPRESS_DB_USER" \
     --dbpass="$WORDPRESS_DB_PASSWORD"
fi
if ! wp core is-installed --path="$WP_PATH" --allow-root; then
  echo "🚀 Installing WordPress ..."
  wp core install \
    --path="$WP_PATH" \
    --allow-root \
    --url="http://localhost:8080/blog" \
    --title="AxCipher Intro CTF" \
    --admin_user="admin" \
    --admin_password="adminpass" \
    --admin_email="admin@example.com" \
    --skip-email
  echo "✅ WordPress installed"
else
  echo "ℹ WordPress already installed"
fi

# Hidden WP flag post (idempotent)
if ! wp post list --path="$WP_PATH" --allow-root --status=any --format=ids \
  | xargs -r -n1 wp post get --path="$WP_PATH" --allow-root --field=post_title 2>/dev/null \
  | grep -q "Hidden CTF Flag Post"; then
  echo "📝 Seeding hidden flag post ..."
  wp post create \
    --path="$WP_PATH" \
    --allow-root \
    --post_type=post \
    --post_status=private \
    --post_title="Hidden CTF Flag Post" \
    --post_content=$'Congratulations! You found the hidden post! 🎉\n\n🚩 flag{wp_hidden_post}'
fi

echo "🌍 Apache up. Landing: http://localhost:8080  |  Blog: http://localhost:8080/blog"
exec apache2-foreground
