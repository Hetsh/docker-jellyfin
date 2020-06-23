# Jellyfin
Super small code hosting platform.

## Running the server
```bash
docker run --detach --name jellyfin --publish 3022:3022 --publish 3000:3000 hetsh/jellyfin
```

## Stopping the container
```bash
docker stop jellyfin
```

## Creating persistent storage
```bash
STORAGE="/path/to/storage"
mkdir -p "$STORAGE"
chown -R 1360:1360 "$STORAGE"
```
`1360` is the numerical id of the user running the server (see Dockerfile).
The user must have RW access to the storage directory.
Start the server with the additional mount flags:
```bash
docker run --mount type=bind,source=/path/to/storage,target=/jellyfin ...
```

## Time
Synchronizing the timezones will display the correct time in the logs.
The timezone can be shared with this mount flag:
```bash
docker run --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly ...
```

## Automate startup and shutdown via systemd
```bash
systemctl enable jellyfin --now
```
The systemd unit can be found in my [GitHub repository](https://github.com/Hetsh/docker-jellyfin).
By default, the systemd service assumes `/etc/jellyfin/app.ini` for config, `/etc/jellyfin/data` for storage and `/etc/localtime` for timezone.
You need to adjust these to suit your setup.

## Fork Me!
This is an open project hosted on [GitHub](https://github.com/Hetsh/docker-jellyfin). Please feel free to ask questions, file an issue or contribute to it.
