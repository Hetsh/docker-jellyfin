FROM library/alpine:20200428
RUN echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache \
    deluge@testing=2.0.3-r5

# App user
ARG APP_UID=1364
ARG APP_USER="deluge"
ARG HOME_DIR="/etc/deluged"
RUN adduser --disabled-password --uid "$APP_UID" --home "$HOME_DIR" --gecos "$APP_USER" --shell /sbin/nologin "$APP_USER"

# Config
ARG CONF_DIR="$HOME_DIR/config"
ARG DATA_DIR="$HOME_DIR/torrents"
RUN mkdir "$CONF_DIR" "$DATA_DIR" && \
    echo -e "{\n\
    \"file\": 1,\n\
    \"format\": 1\n\
}{\n\
    \"add_paused\": false,\n\
    \"allow_remote\": true,\n\
    \"auto_manage_prefer_seeds\": false,\n\
    \"auto_managed\": true,\n\
    \"cache_expiry\": 60,\n\
    \"cache_size\": 512,\n\
    \"copy_torrent_file\": false,\n\
    \"daemon_port\": 58846,\n\
    \"del_copy_torrent_file\": false,\n\
    \"dht\": true,\n\
    \"dont_count_slow_torrents\": false,\n\
    \"download_location\": \"$DATA_DIR\",\n\
    \"download_location_paths_list\": [],\n\
    \"enabled_plugins\": [],\n\
    \"enc_in_policy\": 1,\n\
    \"enc_level\": 2,\n\
    \"enc_out_policy\": 1,\n\
    \"geoip_db_location\": \"$CONF_DIR/GeoIP/GeoIP.dat\",\n\
    \"ignore_limits_on_local_network\": true,\n\
    \"info_sent\": 0.0,\n\
    \"listen_interface\": \"\",\n\
    \"listen_ports\": [\n\
        6881,\n\
        6891\n\
    ],\n\
    \"listen_random_port\": 50746,\n\
    \"listen_reuse_port\": true,\n\
    \"listen_use_sys_port\": false,\n\
    \"lsd\": true,\n\
    \"max_active_downloading\": 1,\n\
    \"max_active_limit\": -1,\n\
    \"max_active_seeding\": -1,\n\
    \"max_connections_global\": 200,\n\
    \"max_connections_per_second\": 20,\n\
    \"max_connections_per_torrent\": -1,\n\
    \"max_download_speed\": -1.0,\n\
    \"max_download_speed_per_torrent\": -1,\n\
    \"max_half_open_connections\": 50,\n\
    \"max_upload_slots_global\": -1,\n\
    \"max_upload_slots_per_torrent\": -1,\n\
    \"max_upload_speed\": -1.0,\n\
    \"max_upload_speed_per_torrent\": -1,\n\
    \"move_completed\": false,\n\
    \"move_completed_path\": \"$DATA_DIR\",\n\
    \"move_completed_paths_list\": [],\n\
    \"natpmp\": true,\n\
    \"new_release_check\": true,\n\
    \"outgoing_interface\": \"\",\n\
    \"outgoing_ports\": [\n\
        0,\n\
        0\n\
    ],\n\
    \"path_chooser_accelerator_string\": \"Tab\",\n\
    \"path_chooser_auto_complete_enabled\": true,\n\
    \"path_chooser_max_popup_rows\": 20,\n\
    \"path_chooser_show_chooser_button_on_localhost\": true,\n\
    \"path_chooser_show_hidden_files\": false,\n\
    \"peer_tos\": \"0x00\",\n\
    \"plugins_location\": \"$CONF_DIR/plugins\",\n\
    \"pre_allocate_storage\": false,\n\
    \"prioritize_first_last_pieces\": false,\n\
    \"proxy\": {\n\
        \"anonymous_mode\": false,\n\
        \"force_proxy\": false,\n\
        \"hostname\": \"\",\n\
        \"password\": \"\",\n\
        \"port\": 8080,\n\
        \"proxy_hostnames\": true,\n\
        \"proxy_peer_connections\": true,\n\
        \"proxy_tracker_connections\": true,\n\
        \"type\": 0,\n\
        \"username\": \"\"\n\
    },\n\
    \"queue_new_to_top\": false,\n\
    \"random_outgoing_ports\": true,\n\
    \"random_port\": true,\n\
    \"rate_limit_ip_overhead\": true,\n\
    \"remove_seed_at_ratio\": false,\n\
    \"seed_time_limit\": 180,\n\
    \"seed_time_ratio_limit\": 7.0,\n\
    \"send_info\": false,\n\
    \"sequential_download\": false,\n\
    \"share_ratio_limit\": -1,\n\
    \"shared\": false,\n\
    \"stop_seed_at_ratio\": false,\n\
    \"stop_seed_ratio\": 2.0,\n\
    \"super_seeding\": false,\n\
    \"torrentfiles_location\": \"$DATA_DIR\",\n\
    \"upnp\": true,\n\
    \"utpex\": true\n\
}" > "$CONF_DIR/core.conf" && \
    chown -R "$APP_USER":"$APP_USER" "$HOME_DIR"

# Volumes
VOLUME ["$CONF_DIR", "$DATA_DIR"]

#      CONTROL   TRAFFIC TCP     TRAFFIC UDP
EXPOSE 58846/tcp
#EXPOSE 58846/tcp 56881:56889/tcp 56881:56889/udp

USER "$APP_USER"
WORKDIR "$HOME_DIR"
ENV CONF_DIR="$CONF_DIR"
ENTRYPOINT exec deluged --do-not-daemonize --config "$CONF_DIR" --loglevel info
