#!/bin/sh
set -e
UUID=${UUID:-$(cat /proc/sys/kernel/random/uuid)}
WS_PATH=${WS_PATH:-/caliber-ws}
PORT=${PORT:-8080}
echo "WS_PATH=$WS_PATH PORT=$PORT"
mkdir -p /tmp/www /run/nginx
cat > /tmp/www/index.html <<HTML
<!doctype html><html><head><title>ws-sg</title></head><body><h1>ws-sg service</h1><p>Service is running.</p></body></html>
HTML
cat > /tmp/xray.json <<JSON
{
  "log": {"loglevel": "warning"},
  "inbounds": [{
    "listen": "127.0.0.1",
    "port": 8081,
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
cat > /etc/nginx/http.d/default.conf <<NGINX
server {
    listen $PORT;
    server_name _;
    location = /health { access_log off; default_type text/plain; return 200 "ok\n"; }
    location $WS_PATH {
        proxy_pass http://127.0.0.1:8081;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_read_timeout 3600s;
    }
    location / { root /tmp/www; index index.html; }
}
NGINX
rm -f /etc/nginx/http.d/*.conf.bak
xray run -config /tmp/xray.json &
exec nginx -g 'daemon off;'
