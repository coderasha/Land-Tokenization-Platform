#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_cmd docker

printf 'Docker network: %s
' "$DOCKER_NETWORK"
docker network inspect "$DOCKER_NETWORK" --format '{{.Name}} {{len .Containers}} containers' 2>/dev/null || echo 'missing'

echo
echo 'Core stack:'
args=()
while IFS= read -r arg; do
  args+=("$arg")
done < <(compose_args "${CORE_COMPOSE_FILES[@]}")
run_compose "${args[@]}" ps

echo
echo 'All related containers:'
docker ps --format 'table {{.Names}}	{{.Status}}	{{.Ports}}' | rg 'orderer|peer0|couchdb|explorer|grafana|prometheus|cadvisor|node-exporter|ca_' || true
