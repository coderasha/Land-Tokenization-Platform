#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"
if [[ -f "$ENV_FILE" ]]; then
  set -a
  source "$ENV_FILE"
  set +a
fi

EXPLORER_DB_NAME="${EXPLORER_DB_NAME:-fabricexplorer}"
EXPLORER_DB_USER="${EXPLORER_DB_USER:-hppoc}"
EXPLORER_DB_PASSWORD="${EXPLORER_DB_PASSWORD:-change-me}"

VARA_KEY_FILE="$(find "$ROOT_DIR/organizations/peerOrganizations/vara.example.com/users/Admin@vara.example.com/msp/keystore" -maxdepth 1 -type f | head -n 1)"
SAHAJ_KEY_FILE="$(find "$ROOT_DIR/organizations/peerOrganizations/sahaj.example.com/users/Admin@sahaj.example.com/msp/keystore" -maxdepth 1 -type f | head -n 1)"

if [[ -z "$VARA_KEY_FILE" || -z "$SAHAJ_KEY_FILE" ]]; then
  echo "Missing admin keystore material for Explorer configuration" >&2
  exit 1
fi

cat > "$ROOT_DIR/explorer/explorerconfig.json" <<EOF
{
  "persistence": "postgreSQL",
  "platforms": ["fabric"],
  "postgreSQL": {
    "host": "explorerdb",
    "port": "5432",
    "database": "$EXPLORER_DB_NAME",
    "username": "$EXPLORER_DB_USER",
    "passwd": "$EXPLORER_DB_PASSWORD"
  },
  "sync": {
    "type": "local",
    "platform": "fabric",
    "blocksSyncTime": "1"
  },
  "jwt": {
    "secret": "replace-this-secret",
    "expiresIn": "2h"
  }
}
EOF

cat > "$ROOT_DIR/explorer/runtime-fabric/config.json" <<EOF
{
  "network-configs": {
    "land-network": {
      "name": "Land Network",
      "profile": "./connection-profile/first-network.json"
    }
  },
  "license": "Apache-2.0"
}
EOF

cat > "$ROOT_DIR/explorer/runtime-fabric/connection-profile/first-network.json" <<EOF
{
  "name": "land-network",
  "version": "1.0.0",
  "license": "Apache-2.0",
  "client": {
    "tlsEnable": true,
    "adminCredential": {
      "id": "exploreradmin",
      "password": "exploreradminpw"
    },
    "enableAuthentication": false,
    "organization": "VaraMSP",
    "connection": {
      "timeout": {
        "peer": {
          "endorser": "300"
        },
        "orderer": "300"
      }
    }
  },
  "channels": {
    "landchannel": {
      "peers": {
        "peer0.vara.example.com": {},
        "peer0.sahaj.example.com": {}
      },
      "connection": {
        "timeout": {
          "peer": {
            "endorser": "6000",
            "eventHub": "6000",
            "eventReg": "6000"
          }
        }
      }
    }
  },
  "organizations": {
    "VaraMSP": {
      "mspid": "VaraMSP",
      "adminPrivateKey": {
        "path": "/tmp/crypto/peerOrganizations/vara.example.com/users/Admin@vara.example.com/msp/keystore/$(basename "$VARA_KEY_FILE")"
      },
      "peers": [
        "peer0.vara.example.com"
      ],
      "signedCert": {
        "path": "/tmp/crypto/peerOrganizations/vara.example.com/users/Admin@vara.example.com/msp/signcerts/cert.pem"
      }
    },
    "SahajMSP": {
      "mspid": "SahajMSP",
      "adminPrivateKey": {
        "path": "/tmp/crypto/peerOrganizations/sahaj.example.com/users/Admin@sahaj.example.com/msp/keystore/$(basename "$SAHAJ_KEY_FILE")"
      },
      "peers": [
        "peer0.sahaj.example.com"
      ],
      "signedCert": {
        "path": "/tmp/crypto/peerOrganizations/sahaj.example.com/users/Admin@sahaj.example.com/msp/signcerts/cert.pem"
      }
    }
  },
  "peers": {
    "peer0.vara.example.com": {
      "tlsCACerts": {
        "path": "/tmp/crypto/peerOrganizations/vara.example.com/peers/peer0.vara.example.com/tls/ca.crt"
      },
      "url": "grpcs://peer0.vara.example.com:7051",
      "grpcOptions": {
        "ssl-target-name-override": "peer0.vara.example.com"
      }
    },
    "peer0.sahaj.example.com": {
      "tlsCACerts": {
        "path": "/tmp/crypto/peerOrganizations/sahaj.example.com/peers/peer0.sahaj.example.com/tls/ca.crt"
      },
      "url": "grpcs://peer0.sahaj.example.com:8051",
      "grpcOptions": {
        "ssl-target-name-override": "peer0.sahaj.example.com"
      }
    }
  }
}
EOF

cp "$ROOT_DIR/explorer/runtime-fabric/connection-profile/first-network.json" "$ROOT_DIR/explorer/fabric/connection-profile/first-network.json"
cp "$ROOT_DIR/explorer/runtime-fabric/config.json" "$ROOT_DIR/explorer/fabric/config.json"

echo "Rendered Explorer runtime config"
