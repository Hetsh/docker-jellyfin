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
update_image "amd64/debian" "Debian" "false" "$IMG_CHANNEL-\d+-slim"

# Packages
PKG_URL="https://packages.debian.org/$IMG_CHANNEL/amd64"
update_pkg "ca-certificates" "CA-Certificates" "false" "$PKG_URL" "\d{8}"
update_pkg "at" "at" "false" "$PKG_URL" "(\d+\.)+\d+-(\d+\.)+\d+"
update_pkg "libsqlite3-0" "SQLite libs" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"
update_pkg "libass9" "ASS libs" "false" "$PKG_URL" "\d+:(\d+\.)+\d+-\d+"
update_pkg "libbluray2" "Bluray libs" "false" "$PKG_URL" "\d+:(\d+\.)+\d+-\d+\+deb\d+u\d+"
update_pkg "libdrm-intel1" "Intel DRM libs" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"
update_pkg "libdrm2" "DRM libs" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"
update_pkg "libmp3lame0" "Lame MP3 libs" "false" "$PKG_URL" "\d+\.\d+-\d+"
update_pkg "libopus0" "Opus libs" "false" "$PKG_URL" "(\d+\.)+\d+-(\d+\.)+\d+"
update_pkg "libopenmpt0" "OpenMPT libs" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"
update_pkg "libtheora0" "Theora libs" "false" "$PKG_URL" "(\d+\.)+\d+\+dfsg\.\d+-\d+"
update_pkg "libvdpau1" "VDPAU libs" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"
update_pkg "libvorbisenc2" "VorbisEnc libs" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"
update_pkg "libvpx6" "VPX Libs" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"
update_pkg "libwebpmux3" "WebPMux libs" "false" "$PKG_URL" "(\d+\.)+\d+-(\d+\.)+\d+"
update_pkg "libx264-160" "x264 libs" "false" "$PKG_URL" "\d+:(\d+\.)+\d+\+git[a-z0-9]+-(\d+\.)+\d+"
update_pkg "libx265-192" "x265 libs" "false" "$PKG_URL" "\d+\.\d+-\d+"
update_pkg "libzvbi0" "ZVBI libs" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"
update_pkg "ocl-icd-libopencl1" "OpenCL libs" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"
update_pkg "libelf1" "ELF libs" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"
update_pkg "libllvm13" "LLVM libs" "false" "$PKG_URL" "\d+:(\d+\.)+\d+-\d+~deb\d+u\d+"
update_pkg "libx11-xcb1" "X/XCB libs" "false" "$PKG_URL" "\d+:(\d+\.)+\d+-\d+"
update_pkg "libxcb-dri2-0" "XCB/DRI2 libs" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"
update_pkg "libxcb-dri3-0" "XCB/DRI3 libs" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"
update_pkg "libxcb-present0" "XCB/Present libs" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"
update_pkg "libxcb-randr0" "XCB/RandR libs" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"
update_pkg "libxcb-sync1" "XCB/Sync libs" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"
update_pkg "libxcb-xfixes0" "XCB/XFiles libs" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"
update_pkg "libxshmfence1" "Share-Memory-Fence libs" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"

# Jellyfin
VERSION_REGEX="(\d+\.){2}\d+"
update_web "FFMPEG_VERSION" "Jellyfin FFmpeg" "false" "https://repo.jellyfin.org/releases/server/debian/versions/jellyfin-ffmpeg/" "$VERSION_REGEX-\d+"
update_web "SERVER_VERSION" "Jellyfin Server" "true" "https://repo.jellyfin.org/releases/server/debian/versions/stable/server" "$VERSION_REGEX"
update_web "WEB_VERSION" "Jellyfin Web" "false" "https://repo.jellyfin.org/releases/server/debian/versions/stable/web" "$VERSION_REGEX"

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
