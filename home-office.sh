#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/home-office-compose.yaml"
PROJECT="home-office"

dc() {
  docker compose -f "$COMPOSE_FILE" --env-file "$SCRIPT_DIR/.env" -p "$PROJECT" "$@"
}

usage() {
  cat <<'EOF'
Usage: home-office.sh [command]

Commands:
  up, start     Start HomeOffice (default)
  down, stop    Stop and remove the HomeOffice containers
  restart       Restart HomeOffice
  logs          Follow the last 100 log lines
  pull          Pull the HomeOffice images
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
    echo "Image pulled. Run './home-office.sh up' to apply it."
    ;;
  status|ps)  dc ps ;;
  -h|--help)  usage; exit 0 ;;
  *)
    echo "Unknown command: $1" >&2
    usage >&2
    exit 1
    ;;
esac

