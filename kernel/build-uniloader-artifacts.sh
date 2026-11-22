#!/bin/sh
set -eu

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORKSPACE="${1:-$HOME/Downloads/lamu-kernel-workspace}"
OUT_DIR="${2:-$WORKSPACE/out/dist/kernel_device_modules-6.6}"
DTC="$WORKSPACE/prebuilts/kernel-build-tools/linux-x86/bin/dtc"
BASE_DTB="$OUT_DIR/mgk_64_k66.user/mt6768.dtb"
LAMU_DTBO="$OUT_DIR/mgk_64_k66.user/lamu.dtbo"
DTSO="$REPO_DIR/kernel/dts/lamul-uniloader.dtso"
BUILD_DIR="${TMPDIR:-/tmp}/nura-uniloader-dtb"
STAGE_DIR="$OUT_DIR/mgk_64_k66.user"
FINAL_DIST="$WORKSPACE/out/mgk_64_k66/dist"

mkdir -p "$BUILD_DIR"

"$DTC" -@ -I dts -O dtb -o "$BUILD_DIR/lamul-uniloader.dtbo" "$DTSO"

if [ ! -x "$BUILD_DIR/fdtoverlay" ]; then
	cc -w -O2 -o "$BUILD_DIR/fdtoverlay" \
		"$WORKSPACE/kernel-6.6/scripts/dtc/fdtoverlay.c" \
		"$WORKSPACE/kernel-6.6/scripts/dtc/util.c" \
		"$WORKSPACE/kernel-6.6/scripts/dtc/libfdt/"*.c \
		-I "$WORKSPACE/kernel-6.6/scripts/dtc/libfdt" \
		-I "$WORKSPACE/kernel-6.6/scripts/dtc"
fi

"$BUILD_DIR/fdtoverlay" -i "$BASE_DTB" -o \
	"$STAGE_DIR/mt6768-lamul-uniloader.dtb" \
	"$LAMU_DTBO" "$BUILD_DIR/lamul-uniloader.dtbo"

cp "$BUILD_DIR/lamul-uniloader.dtbo" "$STAGE_DIR/lamul-uniloader.dtbo"

if [ -d "$FINAL_DIST" ]; then
	cp "$STAGE_DIR/lamul-uniloader.dtbo" "$FINAL_DIST/lamul-uniloader.dtbo"
	cp "$STAGE_DIR/mt6768-lamul-uniloader.dtb" "$FINAL_DIST/mt6768-lamul-uniloader.dtb"
fi

echo "uniloader artifacts staged in $STAGE_DIR"
