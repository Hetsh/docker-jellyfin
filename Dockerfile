FROM library/debian:stable-20201012-slim
ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && \
    apt-get install --no-install-recommends --assume-yes \
        ca-certificates=20190110 \
        at=3.1.23-1 \
        libsqlite3-0=3.27.2-3 \
        libfontconfig1=2.13.1-2 \
        libfreetype6=2.9.1-3+deb10u2 \
        libssl1.1=1.1.1d-0+deb10u3 \
        libass9=1:0.14.0-2 \
        libbluray2=1:1.1.0-1 \
        libdrm-intel1=2.4.97-1 \
        libdrm2=2.4.97-1 \
        libmp3lame0=3.100-2+b1 \
        libopus0=1.3-1 \
        libtheora0=1.1.1+dfsg.1-15 \
        libvdpau1=1.1.1-10 \
        libvorbis0a=1.3.6-2 \
        libvorbisenc2=1.3.6-2 \
        libwebp6=0.6.1-2 \
        libwebpmux3=0.6.1-2 \
        libx264-155=2:0.155.2917+git0a84d98-2 \
        libx265-165=2.9-4 \
        libzvbi0=0.2.35-16 \
        ocl-icd-libopencl1=2.2.12-2 && \
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
ARG FFMPEG_URL="https://repo.jellyfin.org/releases/server/debian/ffmpeg/jellyfin-ffmpeg_4.3.1-1-buster_amd64.deb"
ARG SERVER_URL="https://repo.jellyfin.org/releases/server/debian/stable/server/jellyfin-server_10.6.4-1_amd64.deb"
ARG WEB_URL="https://repo.jellyfin.org/releases/server/debian/stable/web/jellyfin-web_10.6.4-1_all.deb"
ADD "$FFMPEG_URL" "$SERVER_URL" "$WEB_URL" ./
RUN dpkg --install *.deb && \
    rm *.deb && \
    chown -R jellyfin:jellyfin "$WEB_DIR" "$FFMPEG_DIR" "$DATA_DIR" "$CACHE_DIR" "$CONF_DIR"

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
