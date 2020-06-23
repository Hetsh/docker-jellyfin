# Deluge
Super small code hosting platform.

## Running the server
```bash
docker run --detach --name deluge --publish 3022:3022 --publish 3000:3000 hetsh/deluge
```

## Stopping the container
```bash
docker stop deluge
```

## Configuring
Deluge is configured via its [web interface](http://localhost:3000).
A configuration wizard will guide you through the initial setup if you run the server for the first time.
If you want to reuse a existing configuration, it needs to contain these parameters:
```ini
[repository]
ROOT        = /deluge/repos ;change this path to your repos
SCRIPT_TYPE = sh

[server]
START_SSH_SERVER = true
SSH_PORT         = 3022
STATIC_ROOT_PATH = /usr/share/webapps/deluge

[log]
ROOT_PATH = /var/log/deluge
```
Mount the existing configuration and make sure the deluge user (id `1360`) has RW permissions:
```bash
docker run --mount type=bind,source=/path/to/config.ini,target=/etc/deluge/app.ini ...
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
docker run --mount type=bind,source=/path/to/storage,target=/deluge ...
```

## Time
Synchronizing the timezones will display the correct time in the logs.
The timezone can be shared with this mount flag:
```bash
docker run --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly ...
```

## Automate startup and shutdown via systemd
```bash
systemctl enable deluge --now
```
The systemd unit can be found in my [GitHub repository](https://github.com/Hetsh/docker-deluge).
By default, the systemd service assumes `/etc/deluge/app.ini` for config, `/etc/deluge/data` for storage and `/etc/localtime` for timezone.
You need to adjust these to suit your setup.

## Fork Me!
This is an open project hosted on [GitHub](https://github.com/Hetsh/docker-deluge). Please feel free to ask questions, file an issue or contribute to it.
