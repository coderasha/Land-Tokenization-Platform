#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_cmd docker

extra_args=()
if [[ "${1:-}" == "--volumes" ]]; then
  extra_args+=(--volumes --remove-orphans)
fi

for compose_file in \
  "$ROOT_DIR/docker/docker-compose-explorer.yaml" \
  "$ROOT_DIR/docker/docker-compose-monitoring.yaml" \
  "$ROOT_DIR/docker/docker-compose-ca.yaml" \
  "$ROOT_DIR/docker/docker-compose-peers.yaml" \
  "$ROOT_DIR/docker/docker-compose-orderer.yaml"; do
  args=()
  while IFS= read -r arg; do
    args+=("$arg")
  done < <(compose_args "$compose_file")
  run_compose "${args[@]}" down "${extra_args[@]}" || true
done
