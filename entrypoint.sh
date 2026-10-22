#!/bin/sh
set -e
UUID=${UUID:-$(cat /proc/sys/kernel/random/uuid)}
WS_PATH=${WS_PATH:-/caliber-ws}
PORT=${PORT:-8080}
echo "UUID=$UUID WS_PATH=$WS_PATH PORT=$PORT"
cat > /tmp/config.json <<JSON
{
  "log": {"loglevel": "warning"},
  "inbounds": [{
    "listen": "0.0.0.0",
    "port": $PORT,
    "protocol": "vless",
    "settings": {
      "clients": [{"id": "$UUID", "flow": ""}],
      "decryption": "none"
    },
    "streamSettings": {
      "network": "ws",
      "security": "none",
      "wsSettings": {"path": "$WS_PATH"}
    }
  }],
  "outbounds": [{"protocol": "freedom"}]
}
JSON
exec xray run -config /tmp/config.json
