FROM library/debian:stable-20200803-slim
RUN DEBIAN_FRONTEND="noninteractive" && \
    apt-get update && \
    apt-get install --assume-yes \
        gnupg=2.2.12-1+deb10u1 \
        wget=1.20.1-1.1 \
        apt-transport-https=1.8.2.1 \
        ca-certificates=20190110 && \
    rm -r /var/lib/apt/lists /var/cache/apt

# App user
ARG APP_USER="jellyfin"
ARG APP_UID=1365
ARG DATA_DIR="/jellyfin"
RUN useradd --uid "$APP_UID" --user-group --create-home --home "$DATA_DIR" --shell /sbin/nologin "$APP_USER"

#      INTERFACE
EXPOSE 8096/tcp

USER "$APP_USER"
WORKDIR "$DATA_DIR"
ENTRYPOINT exec jellyfin
