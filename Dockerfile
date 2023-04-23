FROM amd64/debian:stable-20230411-slim
ARG DEBIAN_FRONTEND="noninteractive"
RUN apt update && \
    apt install --no-install-recommends --assume-yes \
        ca-certificates=20210119 \
        at=3.1.23-1.1 \
        libsqlite3-0=3.34.1-3 \
        libass9=1:0.15.0-2 \
        libbluray2=1:1.2.1-4+deb11u2 \
        libdrm-intel1=2.4.104-1 \
        libdrm2=2.4.104-1 \
        libmp3lame0=3.100-3 \
        libopenmpt0=0.4.11-1 \
        libopus0=1.3.1-0.1 \
        libtheora0=1.1.1+dfsg.1-15 \
        libvdpau1=1.4-3 \
        libvorbisenc2=1.3.7-1 \
        libvpx6=1.9.0-1 \
        libwebpmux3=0.6.1-2.1 \
        libx264-160=2:0.160.3011+gitcde9a93-2.1 \
        libx265-192=3.4-2 \
        libzvbi0=0.2.35-18 \
        ocl-icd-libopencl1=2.2.14-2 \
        libelf1=0.183-1 \
        libllvm13=1:13.0.1-6~deb11u1 \
        libx11-xcb1=2:1.7.2-1 \
        libxcb-dri2-0=1.14-3 \
        libxcb-dri3-0=1.14-3 \
        libxcb-present0=1.14-3 \
        libxcb-randr0=1.14-3 \
        libxcb-sync1=1.14-3 \
        libxcb-xfixes0=1.14-3 \
        libxshmfence1=1.3-1 && \
    rm -r /var/lib/apt/lists /var/cache/apt

# App user
ARG APP_USER="jellyfin"
ARG APP_UID=1365
RUN useradd --uid "$APP_UID" --user-group --no-create-home --shell /sbin/nologin "$APP_USER"

# Download app
ARG WEB_DIR="/usr/share/jellyfin/web"
ARG FFMPEG_DIR="/usr/lib/jellyfin-ffmpeg/ffmpeg"
ARG DATA_DIR="/var/lib/jellyfin"
ARG CACHE_DIR="/var/cache/jellyfin"
ARG CONF_DIR="/etc/jellyfin"
ARG FFMPEG_VERSION=5.1.3-1
ARG SERVER_VERSION=10.8.10
ARG WEB_VERSION=10.8.10
ARG MIRROR="https://repo.jellyfin.org/releases/server/debian/versions"
RUN apt update && \
    apt install --no-install-recommends --assume-yes wget && \
    wget --quiet \
        "$MIRROR/jellyfin-ffmpeg/$FFMPEG_VERSION/jellyfin-ffmpeg${FFMPEG_VERSION%%.*}_$FFMPEG_VERSION-bullseye_amd64.deb" \
        "$MIRROR/stable/server/$SERVER_VERSION/jellyfin-server_$SERVER_VERSION-1_amd64.deb" \
        "$MIRROR/stable/web/$WEB_VERSION/jellyfin-web_$WEB_VERSION-1_all.deb" && \
    apt purge --assume-yes --auto-remove wget && \
    rm -r /var/lib/apt/lists /var/cache/apt && \
    dpkg --install jellyfin-*.deb && \
    rm jellyfin-*.deb && \
    chown -R "$APP_USER":"$APP_USER" "$WEB_DIR" "$FFMPEG_DIR" "$DATA_DIR" "$CACHE_DIR" "$CONF_DIR"

#      HTTP     HTTPS    SERVICE-DISCOVERY CLIENT-DISCOVERY
EXPOSE 8096/tcp 8920/tcp 1900/udp          7359/udp

USER "$APP_USER"
ENV WEB_DIR="$WEB_DIR" \
    FFMPEG_DIR="$FFMPEG_DIR" \
    DATA_DIR="$DATA_DIR" \
    CACHE_DIR="$CACHE_DIR" \
    CONF_DIR="$CONF_DIR"
ENTRYPOINT exec jellyfin \
                --service \
                --webdir "$WEB_DIR" \
                --ffmpeg "$FFMPEG_DIR" \
                --datadir "$DATA_DIR" \
                --cachedir "$CACHE_DIR" \
                --configdir "$CONF_DIR"
