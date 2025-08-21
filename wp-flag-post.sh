#!/bin/bash
set -euo pipefail

WP_PATH="/var/www/html/blog"

echo "📝 Creating hidden WordPress flag post (if missing)..."

# Only create if no private "Hidden CTF Flag Post" exists
if ! wp post list --path="$WP_PATH" --allow-root --status=private --fields=ID,post_title | grep -qi "Hidden CTF Flag Post"; then
  wp post create \
    --path="$WP_PATH" \
    --post_type=post \
    --post_status=private \
    --post_title="Hidden CTF Flag Post" \
    --post_content=$'Congratulations! You found the hidden post!\n\nFlag: flag{wp_hidden_post}' \
    --allow-root >/dev/null
  echo "✅ Hidden flag post created."
else
  echo "ℹ Hidden flag post already present."
fi
