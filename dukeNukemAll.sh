#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] Down + remove orphans + volumes"
docker compose down -v --remove-orphans || true

echo "[2/5] Prune networks"
docker network prune -f || true

echo "[3/5] Remove project volumes (best-effort)"
docker volume rm axcipher-lab_wp_data gt-sandbox_wp_data c4902928043c6be44f0752db6ae2e2284f8a27d1ca937d418d528a1f2402190e 2>/dev/null || true
docker volume prune -f || true

echo "[4/5] Purge stale images & build cache"
docker image prune -a -f || true
docker builder prune -a -f || true

echo "[5/5] Build fresh & up"
docker compose build --no-cache
docker compose up -d
docker compose ps
