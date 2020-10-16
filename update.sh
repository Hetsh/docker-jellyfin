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
update_pkg "libx264-155" "x264 libs" "false" "$PKG_URL" "\d+:(\d+\.){2}\d+\+git[a-z0-9]+-\d+" =2:0.155.2917+git0a84d98-2
update_pkg "libx265-165" "x265 libs" "false" "$PKG_URL" "\d+\.\d+-\d+"
update_pkg "libzvbi0" "ZVBI libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"
update_pkg "ocl-icd-libopencl1" "OpenCL libs" "false" "$PKG_URL" "(\d+\.){2}\d+-\d+"

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