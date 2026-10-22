FROM alpine:3.20
RUN apk add --no-cache ca-certificates wget unzip nginx && \
    wget -q -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    mkdir -p /usr/local/bin && unzip -o /tmp/xray.zip -d /tmp/xray && \
    mv /tmp/xray/xray /usr/local/bin/xray && chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray /tmp/xray.zip
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
