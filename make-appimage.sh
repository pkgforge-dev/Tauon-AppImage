#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q tauon-music-box-git | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/tauonmb.svg
export DESKTOP=/usr/share/applications/tauonmb.desktop

export DEPLOY_SYS_PYTHON=1
export DEPLOY_PIPEWIRE=1
export DEPLOY_SDL=1
# Deploy dependencies
quick-sharun /usr/bin/tauonmb /usr/bin/tauon

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
