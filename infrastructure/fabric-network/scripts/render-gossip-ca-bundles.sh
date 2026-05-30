#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

render_bundle() {
  local own_tls_dir="$1"
  local remote_tls_ca="$2"
  local output="$own_tls_dir/combined-ca.crt"

  cat "$own_tls_dir/ca.crt" "$remote_tls_ca" > "$output"
  chmod 0644 "$output"
  echo "Rendered $output"
}

render_bundle   "$ROOT_DIR/organizations/peerOrganizations/vara.example.com/peers/peer0.vara.example.com/tls"   "$ROOT_DIR/organizations/peerOrganizations/sahaj.example.com/msp/tlscacerts/tlsca.sahaj.example.com-cert.pem"

render_bundle   "$ROOT_DIR/organizations/peerOrganizations/sahaj.example.com/peers/peer0.sahaj.example.com/tls"   "$ROOT_DIR/organizations/peerOrganizations/vara.example.com/msp/tlscacerts/tlsca.vara.example.com-cert.pem"
