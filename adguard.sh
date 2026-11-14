#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/adguard-compose.yaml"
PROJECT="adguard"

dc() {
  docker compose -f "$COMPOSE_FILE" --env-file "$SCRIPT_DIR/.env" -p "$PROJECT" "$@"
}

usage() {
  cat <<'EOF'
Usage: adguard.sh [command]

Commands:
  up, start     Start AdGuard (default)
  down, stop    Stop and remove the AdGuard container
  restart       Restart AdGuard
  logs          Follow the last 100 log lines
  pull          Pull the AdGuard image
  status, ps    Show container status
  -h, --help    Show this help
EOF
}

case "${1:-up}" in
  up|start)   dc up -d ;;
  down|stop)  dc down ;;
  restart)    dc restart ;;
  logs)       dc logs -f --tail=100 ;;
  pull)
    dc pull
    echo "Image pulled. Run './adguard.sh up' to apply it."
    ;;
  status|ps)  dc ps ;;
  -h|--help)  usage; exit 0 ;;
  *)
    echo "Unknown command: $1" >&2
    usage >&2
    exit 1
    ;;
esac

