#!/bin/sh
set -e

UPSTREAM_HOST="${UPSTREAM_HOST:-host.docker.internal}"
UPSTREAM_PORT="${UPSTREAM_PORT:-8000}"
AUTH_USER="${AUTH_USER:-admin}"
AUTH_PASS="${AUTH_PASS:-changeme}"

# Hash the password using Caddy's built-in tool
HASHED_PASS=$(caddy hash-password --plaintext "$AUTH_PASS")

cat > /etc/caddy/Caddyfile <<EOF
:8080 {
    basicauth * {
        ${AUTH_USER} ${HASHED_PASS}
    }
    reverse_proxy ${UPSTREAM_HOST}:${UPSTREAM_PORT}
}
EOF

exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
