#!/usr/bin/env bash


# Abort on any error
set -e -u

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh
source libs/docker.sh

update_custom() {
	local ID="$1"
	local NAME="$2"
	local MAIN="$3"
	local MIRROR="$4"
	local URL_REGEX="$5"
	local VERSION_REGEX="$6"

	local CURRENT_URL=$(cat Dockerfile | grep --only-matching --perl-regexp "(?<=$ID=\").*(?=\")")
	local NEW_URL=$(curl --silent --location "$MIRROR" | grep --only-matching --perl-regexp "(?<=href=(\"|'))$URL_REGEX(?=(\"|'))")
	if [ -z "$CURRENT_URL" ] || [ -z "$NEW_URL" ]; then
		echo -e "\e[31mFailed to scrape $NAME URL!\e[0m"
		return
	fi

	# Convert to URI
	if [ "${NEW_URL:0:4}" == "http" ]; then
		# Already URI
		true
	elif [ "${NEW_URL:0:1}" == '/' ]; then
		# Absolute path
		ROOT=$(echo "$MIRROR" | grep --only-matching --perl-regexp "http(s)?:\/\/[^\/]+")
		NEW_URL="${ROOT}$NEW_URL"
	else
		# Relative path
		NEW_URL="$MIRROR/$NEW_URL"
	fi

	local CURRENT_VERSION=$(echo "$CURRENT_URL" | grep --only-matching --perl-regexp "$VERSION_REGEX")
	local NEW_VERSION=$(echo "$NEW_URL" | grep --only-matching --perl-regexp "$VERSION_REGEX")
	if [ -z "$CURRENT_VERSION" ] || [ -z "$NEW_VERSION" ]; then
		echo -e "\e[31mFailed to scrape $NAME version!\e[0m"
		return
	fi

	if [ "$CURRENT_URL" != "$NEW_URL" ]; then
		prepare_update "$ID" "$NAME" "$CURRENT_VERSION" "$NEW_VERSION" "$CURRENT_URL" "$NEW_URL"

		if [ "$MAIN" = "true" ] && [ "${CURRENT_VERSION%-*}" != "${NEW_VERSION%-*}" ]; then
			update_version "$NEW_VERSION"
		else
			update_release
		fi
	fi
}

# Check dependencies
assert_dependency "jq"
assert_dependency "curl"

# Debian Stable
IMG_CHANNEL="stable"
update_image "amd64/debian" "Debian" "false" "$IMG_CHANNEL-\d+-slim"

# Packages
PKG_URL="https://packages.debian.org/$IMG_CHANNEL/amd64"
update_pkg "ca-certificates" "CA-Certificates" "false" "$PKG_URL" "\d{8}~deb\d+u\d+"
update_pkg "at" "at" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "libsqlite3-0" "SQLite libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+\+deb\d+u\d+"
update_pkg "libssl1.1" "SSL libs" "false" "$PKG_URL" "(\d+\.){2}\d+d-\d+\+deb\d+u\d+"
update_pkg "libass9" "ASS libs" "false" "$PKG_URL" "\d+:(\d+\.){2}\d+-\d+"
update_pkg "libbluray2" "Bluray libs" "false" "$PKG_URL" "\d+:(\d+\.){2}\d+-\d+"
update_pkg "libdrm-intel1" "Intel DRM libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "libdrm2" "DRM libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "libmp3lame0" "Lame MP3 libs" "false" "$PKG_URL" "\d+\.\d+-\d+\+b\d+"
update_pkg "libopus0" "Opus libs" "false" "$PKG_URL" "\d+\.\d+-\d+"
update_pkg "libtheora0" "Theora libs" "false" "$PKG_URL" "(\d+\.){2}\d+\+dfsg\.\d+-\d+"
update_pkg "libvdpau1" "VDPAU libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "libvorbisenc2" "VorbisEnc libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "libvpx5" "VPX Libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+\+deb\d+u\d+"
update_pkg "libwebpmux3" "WebPMux libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+\+deb\d+u\d+"
update_pkg "libx264-155" "x264 libs" "false" "$PKG_URL" "\d+:(\d+\.){2}\d+\+git[a-z0-9]+-\d+"
update_pkg "libx265-165" "x265 libs" "false" "$PKG_URL" "\d+\.\d+-\d+"
update_pkg "libzvbi0" "ZVBI libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "ocl-icd-libopencl1" "OpenCL libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"

# Jellyfin
IMG_CODENAME="buster"
VERSION_REGEX="(\d+\.){2}\d+-\d+"
update_custom "FFMPEG_URL" "Jellyfin FFmpeg" "false" "https://repo.jellyfin.org/releases/server/debian/ffmpeg" ".*jellyfin-ffmpeg_$VERSION_REGEX-${IMG_CODENAME}_amd64\.deb" "$VERSION_REGEX-$IMG_CODENAME"
update_custom "SERVER_URL" "Jellyfin Server" "true" "https://repo.jellyfin.org/releases/server/debian/stable" ".*jellyfin-server_${VERSION_REGEX}_amd64\.deb" "$VERSION_REGEX"
update_custom "WEB_URL" "Jellyfin Web" "false" "https://repo.jellyfin.org/releases/server/debian/stable" ".*jellyfin-web_${VERSION_REGEX}_all\.deb" "$VERSION_REGEX"

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
