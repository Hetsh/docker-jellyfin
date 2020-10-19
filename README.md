# Jellyfin
Easy to set up Jellyfin media server.

## Running the server
```bash
docker run --detach --name jellyfin --publish 8096:8096 hetsh/jellyfin
```

## Stopping the container
```bash
docker stop jellyfin
```

## Configuration
Jellyfin is configured via its [web interface](http://localhost:8096).
A configuration wizard will guide you through the initial setup if you run the server for the first time.

## Creating persistent storage
```bash
DATA_STORAGE="/path/to/data"
CONFIG_STORAGE="/path/to/conf"
CACHE_STORAGE="/path/to/data"
mkdir -p "$DATA_STORAGE" "$CONFIG_STORAGE" "$CACHE_STORAGE"
chown -R 1365:1365 "$DATA_STORAGE" "$CONFIG_STORAGE" "$CACHE_STORAGE"
```
`1365` is the numerical id of the user running the server (see Dockerfile).
The user must have RW access to the storage directories.
Start the server with the additional mount flags:
```bash
docker run \
--mount type=bind,source=/path/to/data,target=/var/lib/jellyfin \
--mount type=bind,source=/path/to/conf,target=/etc/jellyfin \
--mount type=bind,source=/path/to/cache,target=/var/cache/jellyfin ...
```

## Adding media
Media can be mounted anywhere, as long as it is readable by the jellyfin user (uid: 1365):
```bash
docker run --mount type=bind,source=/path/to/media,target=/media ...
```

## Time
Synchronizing the timezones will display the correct time in the logs.
The timezone can be shared with this mount flag:
```bash
docker run --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly ...
```

## Automate startup and shutdown via systemd
The systemd unit can be found in my GitHub [repository](https://github.com/Hetsh/docker-jellyfin).
```bash
systemctl enable jellyfin --now
```
By default, the systemd service assumes some custom paths for data, cache, config, media and `/etc/localtime` for timezone.
Since this is a personal systemd unit file, you might need to adjust some parameters to suit your setup.

## Fork Me!
This is an open project hosted on [GitHub](https://github.com/Hetsh/docker-jellyfin).
Please feel free to ask questions, file an issue or contribute to it.
