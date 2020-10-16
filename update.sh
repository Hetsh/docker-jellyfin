#!/usr/bin/env bash


# Abort on any error
set -e -u

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh
source libs/docker.sh

# Check dependencies
assert_dependency "jq"
assert_dependency "curl"

# Debian Stable
IMG_CHANNEL="stable"
update_image "library/debian" "Debian" "false" "$IMG_CHANNEL-\d+-slim"

# Packages
PKG_URL="https://packages.debian.org/$IMG_CHANNEL/amd64"
update_pkg "ca-certificates" "CA-Certificates" "false" "$PKG_URL" "\d{8}"
update_pkg "at" "at" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "libsqlite3-0" "SQLite libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "libfontconfig1" "FontConfig libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "libfreetype6" "FreeType libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+\+deb\d+u\d+"
update_pkg "libssl1.1" "SSL libs" "false" "$PKG_URL" "(\d+\.){2}\d+d-\d+\+deb\d+u\d+"
update_pkg "libass9" "ASS libs" "false" "$PKG_URL" "\d+:(\d+\.){2}\d+-\d+"
update_pkg "libbluray2" "Bluray libs" "false" "$PKG_URL" "\d+:(\d+\.){2}\d+-\d+"
update_pkg "libdrm-intel1" "Intel DRM libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "libdrm2" "DRM libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "libmp3lame0" "Lame MP3 libs" "false" "$PKG_URL" "\d+\.\d+-\d+\+b\d+"
update_pkg "libopus0" "Opus libs" "false" "$PKG_URL" "\d+\.\d+-\d+"
update_pkg "libtheora0" "Theora libs" "false" "$PKG_URL" "(\d+\.){2}\d+\+dfsg\.\d+-\d+"
update_pkg "libvdpau1" "VDPAU libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "libvorbis0a" "Vorbis libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "libvorbisenc2" "VorbisEnc libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "libwebp6" "WebP libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "libwebpmux3" "WebPMux libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "libx264-155" "x264 libs" "false" "$PKG_URL" "\d+:(\d+\.){2}\d+\+git[a-z0-9]+-\d+"
update_pkg "libx265-165" "x265 libs" "false" "$PKG_URL" "\d+\.\d+-\d+"
update_pkg "libzvbi0" "ZVBI libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "ocl-icd-libopencl1" "OpenCL libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"

# Jellyfin
MIRROR="https://repo.jellyfin.org/releases/server/debian/versions"
IMG_CODENAME="buster"
CURRENT_FFMPEG_VERSION=$(cat Dockerfile | grep -P --only-matching "(?<=jellyfin-ffmpeg/)(\d+\.){2}\d+-\d+")
NEW_FFMPEG_VERSION=$(curl --silent --location "$MIRROR/jellyfin-ffmpeg" | grep -P -o "(\d+\.){2}\d+-\d+(?=/</a>)" | sort --version-sort | tail -n 1)
if [ "$CURRENT_FFMPEG_VERSION" != "$NEW_FFMPEG_VERSION" ]; then
	prepare_update "" "Jellyfin's FFmpeg" "$CURRENT_FFMPEG_VERSION" "$NEW_FFMPEG_VERSION"
	update_release

	# Since jellyfin's ffmpeg is not a regular package, the version number needs
	# to be replaced with the url to download the pkg
	_UPDATES[-3]="FFMPEG_URL"
	_UPDATES[-2]="\".*\""
	_UPDATES[-1]="\"$MIRROR/jellyfin-ffmpeg/$NEW_FFMPEG_VERSION/jellyfin-ffmpeg_$NEW_FFMPEG_VERSION-${IMG_CODENAME}_amd64.deb\""
fi
CURRENT_SERVER_VERSION=$(cat Dockerfile | grep -P --only-matching "(?<=server/)(\d+\.){2}\d+")
NEW_SERVER_VERSION=$(curl --silent --location "$MIRROR/stable/server" | grep -P -o "(\d+\.){2}\d+(?=/</a>)" | sort --version-sort | tail -n 1)
if [ "$CURRENT_SERVER_VERSION" != "$NEW_SERVER_VERSION" ]; then
	prepare_update "" "Jellyfin Server" "$CURRENT_SERVER_VERSION" "$NEW_SERVER_VERSION"
	update_version "$NEW_SERVER_VERSION"

	# Since jellyfin's ffmpeg is not a regular package, the version number needs
	# to be replaced with the url to download the pkg
	_UPDATES[-3]="SERVER_URL"
	_UPDATES[-2]="\".*\""
	_UPDATES[-1]="\"$MIRROR/stable/server/$NEW_SERVER_VERSION/jellyfin-server_${NEW_SERVER_VERSION}_amd64.deb\""
fi
CURRENT_WEB_VERSION=$(cat Dockerfile | grep -P --only-matching "(?<=web/)(\d+\.){2}\d+")
NEW_WEB_VERSION=$(curl --silent --location "$MIRROR/stable/web" | grep -P -o "(\d+\.){2}\d+(?=/</a>)" | sort --version-sort | tail -n 1)
if [ "$CURRENT_WEB_VERSION" != "$NEW_WEB_VERSION" ]; then
	prepare_update "" "Jellyfin Web" "$CURRENT_WEB_VERSION" "$NEW_WEB_VERSION"
	update_release

	# Since jellyfin's ffmpeg is not a regular package, the version number needs
	# to be replaced with the url to download the pkg
	_UPDATES[-3]="WEB_URL"
	_UPDATES[-2]="\".*\""
	_UPDATES[-1]="\"$MIRROR/stable/web/$NEW_WEB_VERSION/jellyfin-web_${NEW_WEB_VERSION}_all.deb\""
fi

if ! updates_available; then
	#echo "No updates available."
	exit 0
fi

# Perform modifications
if [ "${1-}" = "--noconfirm" ] || confirm_action "Save changes?"; then
	save_changes

	if [ "${1-}" = "--noconfirm" ] || confirm_action "Commit changes?"; then
		commit_changes
	fi
fi