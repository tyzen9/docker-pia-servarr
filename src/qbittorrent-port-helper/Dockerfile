FROM alpine:latest
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/main/" >> /etc/apk/repositories && \
    apk add --no-cache \
        bash \
        curl \
        nmap-ncat

ADD qbittorrent-listeing-port-manager.sh /scripts/qbittorrent-listeing-port-manager.sh
ADD qbittorrent-listeing-port-manager.env /scripts/qbittorrent-listeing-port-manager.env

RUN chmod +x /scripts/*.sh

CMD ["/scripts/qbittorrent-listeing-port-manager.sh"]