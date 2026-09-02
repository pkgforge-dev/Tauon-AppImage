#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	flac                \
	libgme              \
	libimagequant       \
	libnotify           \
	libvorbis           \
	mpg123              \
	openjpeg2           \
	opusfile            \
	p7zip               \
	pipewire-audio      \
	pipewire-jack       \
	python-jxlpy        \
	python-opengl       \
	python-plexapi      \
	python-pychromecast \
	python-pypresence   \
	python-tekore       \
	python-tidalapi     \
	tauon-music-box     \
	unrar               \
	wavpac

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini

# Comment this out if you need an AUR package
#make-aur-package tauon-music-box-git

# If the application needs to be manually built that has to be done down here

# if you also have to make nightly releases check for DEVEL_RELEASE = 1
#
# if [ "${DEVEL_RELEASE-}" = 1 ]; then
# 	nightly build steps
# else
# 	regular build steps
# fi
