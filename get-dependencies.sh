#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	cargo                   \
	flac                    \
	libappindicator         \
	libgme                  \
	libimagequant           \
	libnotify               \
	libopenmpt              \
	libprojectm             \
	libsamplerate           \
	libvorbis               \
	miniaudio               \
	mpg123                  \
	noto-fonts              \
	noto-fonts-extra        \
	opencc                  \
	openjpeg2               \
	opusfile                \
	p7zip                   \
	pipewire-audio          \
	pipewire-jack           \
	pkgconf                 \
	python-beautifulsoup4   \
	python-build            \
	python-cairo            \
	python-dbus             \
	python-gobject          \
	python-installer        \
	python-jxlpy            \
	python-musicbrainzngs   \
	python-mutagen          \
	python-natsort          \
	python-opengl           \
	python-pillow           \
	python-plexapi          \
	python-pychromecast     \
	python-pylast           \
	python-pypresence       \
	python-pysdl3           \
	python-rapidfuzz        \
	python-requests         \
	python-send2trash       \
	python-setproctitle     \
	python-tekore           \
	python-tidalapi         \
	python-unidecode        \
	python-websocket-client \
	sdl3_image              \
	unrar                   \
	wavpack                 \
	xdg-utils

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini

# Comment this out if you need an AUR package
#make-aur-package tauon-music-box-git

echo "Building kissfft..."
echo "---------------------------------------------------------------"
git clone --depth 1 https://github.com/mborgerding/kissfft.git && (
	cd kissfft
	make KISSFFT_TOOLS=0
	make install PREFIX=/usr KISSFFT_TOOLS=0
	ldconfig
)

echo "Building tauon-music-box..."
echo "---------------------------------------------------------------"
git clone https://github.com/Taiko2k/Tauon.git ./Tauon && (
	cd ./Tauon

	git fetch --tags origin
	TAG=$(git tag --sort=-v:refname | grep -vi 'pre\|rc\|alpha\|beta' | head -1)
	git checkout "$TAG"
	echo "${TAG#v}" > ~/version

	# use system kissfft instead of the expected cloned repository
	sed -i 's|"src/phazor/kissfft/kiss_fftr.c", "src/phazor/kissfft/kiss_fft.c", ||g' pyproject.toml
	sed -i 's|"samplerate"|"kissfft-float", "samplerate"|g' pyproject.toml
	sed -i 's|com.github.taiko2k.tauonmb.desktop|tauonmb.desktop|' extra/com.github.taiko2k.tauonmb.appdata.xml

	python -m build --wheel

	# Tiny Rust binary that calculates LRCLIB challenges
	(
		cd src/lrclib-solver
		export RUSTUP_TOOLCHAIN=stable
		export CARGO_TARGET_DIR=target
		cargo fetch --locked --target host-tuple
		CFLAGS="${CFLAGS-} -fno-lto" cargo build --frozen --release --all-features
	)

	python -m installer --destdir=/ dist/*.whl

	for dir in src/tauon/locale/*; do
		install -Dm644 \
			"${dir}/LC_MESSAGES/"*.mo \
			-t "/usr/share/locale/$(basename "${dir}")/LC_MESSAGES"
	done

	install -Dm644 extra/tauonmb.desktop -t /usr/share/applications
	install -Dm644 extra/com.github.taiko2k.tauonmb.appdata.xml -t /usr/share/metainfo
	install -Dm644 extra/tauonmb-symbolic.svg -t /usr/share/icons/hicolor/symbolic/apps
	install -Dm644 extra/tauonmb.svg -t /usr/share/icons/hicolor/scalable/apps
	install -Dm755 extra/tauonmb.sh /usr/bin/tauon

	site_packages=$(python -c "import site; print(site.getsitepackages()[0])")
	install -Dm755 src/lrclib-solver/target/release/lrclib-solver "${site_packages}/tauon/lrclib-solver"
)
