#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCKER_NETWORK="docker_land_network"
CORE_COMPOSE_FILES=(
  "$ROOT_DIR/docker/docker-compose-orderer.yaml"
  "$ROOT_DIR/docker/docker-compose-peers.yaml"
)
OPTIONAL_COMPOSE_FILES=(
  "$ROOT_DIR/docker/docker-compose-ca.yaml"
  "$ROOT_DIR/docker/docker-compose-monitoring.yaml"
  "$ROOT_DIR/docker/docker-compose-explorer.yaml"
)

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

compose_args() {
  local args=()
  local file
  for file in "$@"; do
    args+=( -f "$file" )
  done
  printf '%s\n' "${args[@]}"
}

run_compose() {
  local -a args=("$@")
  docker compose "${args[@]}"
}

ensure_network() {
  if ! docker network inspect "$DOCKER_NETWORK" >/dev/null 2>&1; then
    docker network create "$DOCKER_NETWORK" >/dev/null
    echo "Created docker network: $DOCKER_NETWORK"
  fi
}

render_gossip_bundles() {
  "$ROOT_DIR/scripts/render-gossip-ca-bundles.sh"
}
