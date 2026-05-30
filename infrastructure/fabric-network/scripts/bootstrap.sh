#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_cmd docker
ensure_network
render_gossip_bundles

args=()
while IFS= read -r arg; do
  args+=("$arg")
done < <(compose_args "${CORE_COMPOSE_FILES[@]}")
run_compose "${args[@]}" up -d

if [[ "${ENABLE_CA:-false}" == "true" ]]; then
  args=()
  while IFS= read -r arg; do
    args+=("$arg")
  done < <(compose_args "$ROOT_DIR/docker/docker-compose-ca.yaml")
  run_compose "${args[@]}" up -d
fi

if [[ "${ENABLE_MONITORING:-false}" == "true" ]]; then
  args=()
  while IFS= read -r arg; do
    args+=("$arg")
  done < <(compose_args "$ROOT_DIR/docker/docker-compose-monitoring.yaml")
  run_compose "${args[@]}" up -d
fi

if [[ "${ENABLE_EXPLORER:-false}" == "true" ]]; then
  args=()
  while IFS= read -r arg; do
    args+=("$arg")
  done < <(compose_args "$ROOT_DIR/docker/docker-compose-explorer.yaml")
  run_compose "${args[@]}" up -d
fi
