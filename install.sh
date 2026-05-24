#!/bin/sh
# Tailscale installer for SirrOS, Mobian and Droidian
# Based on the official Tailscale install.sh (BSD-3-Clause)
#
# Usage:
#   sh install.sh
#   TAILSCALE_VERSION=1.88.4 sh install.sh
#   TRACK=unstable sh install.sh

set -eu

main() {
	OS=""
	VERSION=""
	PACKAGETYPE=""
	APT_KEY_TYPE=""
	TRACK="${TRACK:-stable}"
	TAILSCALE_VERSION="${TAILSCALE_VERSION:-}"

	# Validate track value
	case "$TRACK" in
		stable|unstable) ;;
		*)
			echo "Unsupported track: $TRACK"
			exit 1
			;;
	esac

	# Require /etc/os-release to identify the distro
	if [ ! -f /etc/os-release ]; then
		echo "Could not find /etc/os-release. Unknown system."
		exit 1
	fi

	. /etc/os-release

	# Map each supported distro to its Debian base and codename
	case "$ID" in
		Sirros|sirros)
			# SirrOS Phosh Edition — based on Debian Trixie
			OS="debian"
			VERSION="trixie"
			PACKAGETYPE="apt"
			APT_KEY_TYPE="keyring"
			;;
		mobian)
			# Mobian — Debian for mobile devices
			OS="debian"
			VERSION="${VERSION_CODENAME:-trixie}"
			PACKAGETYPE="apt"
			APT_KEY_TYPE="keyring"
			;;
		droidian)
			# Droidian — Debian for Android devices
			OS="debian"
			VERSION="${VERSION_CODENAME:-trixie}"
			PACKAGETYPE="apt"
			APT_KEY_TYPE="keyring"
			;;
		*)
			echo "Unsupported OS: ${PRETTY_NAME:-$ID}"
			echo "This script only supports SirrOS, Mobian and Droidian."
			exit 1
			;;
	esac

	# Prefer curl, fall back to wget
	CURL=
	if type curl >/dev/null 2>&1; then
		CURL="curl -fsSL"
	elif type wget >/dev/null 2>&1; then
		CURL="wget -q -O-"
	else
		echo "curl or wget is required. Please install one of them and try again."
		exit 1
	fi

	# Check internet connectivity before proceeding
	$CURL "https://pkgs.tailscale.com/" >/dev/null 2>&1 || {
		echo "Cannot reach https://pkgs.tailscale.com/"
		echo "Please check your internet connection."
		exit 1
	}

	# Determine how to run privileged commands
	SUDO=
	if [ "$(id -u)" = 0 ]; then
		SUDO=""
	elif type sudo >/dev/null 2>&1; then
		SUDO="sudo"
	elif type doas >/dev/null 2>&1; then
		SUDO="doas"
	else
		echo "This installer must run as root, or sudo/doas must be available."
		exit 1
	fi

	# Show what is about to be installed
	if [ -n "$TAILSCALE_VERSION" ]; then
		echo "Installing Tailscale $TAILSCALE_VERSION for $PRETTY_NAME (debian/$VERSION)..."
	else
		echo "Installing Tailscale for $PRETTY_NAME (debian/$VERSION)..."
	fi

	export DEBIAN_FRONTEND=noninteractive
	set -x

	# Add the Tailscale GPG key and apt repository
	$SUDO mkdir -p --mode=0755 /usr/share/keyrings
	$CURL "https://pkgs.tailscale.com/$TRACK/debian/$VERSION.noarmor.gpg" \
		| $SUDO tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
	$SUDO chmod 0644 /usr/share/keyrings/tailscale-archive-keyring.gpg
	$CURL "https://pkgs.tailscale.com/$TRACK/debian/$VERSION.tailscale-keyring.list" \
		| $SUDO tee /etc/apt/sources.list.d/tailscale.list
	$SUDO chmod 0644 /etc/apt/sources.list.d/tailscale.list

	# Install Tailscale
	$SUDO apt-get update
	if [ -n "$TAILSCALE_VERSION" ]; then
		$SUDO apt-get install -y "tailscale=$TAILSCALE_VERSION" tailscale-archive-keyring
	else
		$SUDO apt-get install -y tailscale tailscale-archive-keyring
	fi

	set +x

	echo ""
	echo "Installation complete! Log in to start using Tailscale by running:"
	echo ""
	if [ -z "$SUDO" ]; then
		echo "  tailscale up"
	else
		echo "  $SUDO tailscale up"
	fi
}

main
