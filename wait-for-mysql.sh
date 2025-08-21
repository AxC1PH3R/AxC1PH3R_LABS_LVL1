#!/bin/bash
set -e

HOST="$WORDPRESS_DB_HOST"
USER="$WORDPRESS_DB_USER"
PASS="$WORDPRESS_DB_PASSWORD"

echo "⏳ Waiting for MariaDB at $HOST..."

# Extract hostname and port from WORDPRESS_DB_HOST (format: host:port)
DB_HOST=$(echo $HOST | cut -d: -f1)
DB_PORT=$(echo $HOST | cut -s -d: -f2)
DB_PORT=${DB_PORT:-3306}

until mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" -u"$USER" -p"$PASS" --silent; do
  echo "❌ DB not ready yet..."
  sleep 3
done

echo "✅ MariaDB is ready!"
exec "$@"
