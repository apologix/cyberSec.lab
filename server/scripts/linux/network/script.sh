#!/usr/bin/env sh
set -eu
host_name=$(hostname); os_name=$(uname -srm); arch=$(uname -m); uptime_seconds=$(awk '{print int($1)}' /proc/uptime 2>/dev/null || printf '0')
interfaces=$(ip -j addr 2>/dev/null | tr -d '\n' || printf '[]')
json=$(printf '{"session_id":"%s","collector_version":"1.0.0","platform":"linux","hostname":"%s","os":"%s","architecture":"%s","network_data":{"interfaces":%s},"uptime_seconds":%s}' "$(uuidgen 2>/dev/null | tr -d '-' || date +%s)" "$host_name" "$os_name" "$arch" "$interfaces" "$uptime_seconds")
if [ -n "${CYBERLAB_COLLECTOR_URL:-}" ] && [ -n "${CYBERLAB_COLLECTOR_TOKEN:-}" ]; then curl --fail --silent --show-error --max-time 15 -H 'Content-Type: application/json' -H "X-Collector-Token: $CYBERLAB_COLLECTOR_TOKEN" --data "$json" "$CYBERLAB_COLLECTOR_URL"; else printf '%s\n' "$json"; fi
