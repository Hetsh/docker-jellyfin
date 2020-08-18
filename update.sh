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
update_pkg "gnupg" "GnuPG" "false" "$PKG_URL" "(\d+\.)+\d+-\d+\+deb\d+u\d+"
update_pkg "wget" "Wget" "false" "$PKG_URL" "(\d+\.)+\d+-(\d+\.)+\d+"
update_pkg "apt-transport-https" "HTTPS APT Transport" "false" "$PKG_URL" "(\d+\.){3}\d+"
update_pkg "ca-certificates" "CA-Certificates" "false" "$PKG_URL" "\d{8}"

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