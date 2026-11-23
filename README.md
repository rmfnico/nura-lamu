# Nura — Moto G15 Power

port for the Motorola Moto G15 Power (XT2521-5) and Motorola Moto G05 (XT2523-4).
note: this port hasn't been tested to boot yet. Treat releases as test points; nothing is guaranteed to boot.

Device

- SoC: MediaTek MT6768
- Architecture: aarch64
- Boot header: v4
- Page size: 4096

Files

- `device/` — device package
- `kernel/` — kernel build config and overlays

The device package depends on `linux-motorola-lamu`, which is not
included in this repository yet.

## Secondary device: Motorola Moto G05 (lamul)

G05 is a side device, boot untested, shares firmware where verified.

- Moto G05 (XT2523-4, `lamul`) is a side device for uniLoader testing.
- The lamu family shares firmware; the same kernel build is intended
  to work on both devices.
- G05 boot untested.

uniLoader's configured memory layout is separate from the device tree:
the loader runs from `0x40080000`, the ramdisk destination is
`0x47c80000`, and the kernel payload is copied to `0xb2b00000`, inside
the uninterrupted `0xa0000000`-`0xbdffffff` RAM bank reported on both
devices. The DTB `/memory` node at `0x40000000` describes RAM to Linux;
it is not the kernel payload destination. MediaTek LK gunzips boot.img
kernels into its own buffer, but that limit does not apply to this
uniLoader path, and no size limit for it has been established here.

Kernel sources

Sources are kept upstream, not vendored here.

| Project | Commit |
|---|---|
| [android common](https://android.googlesource.com/kernel/common) | `7ed219d1133d473dd3590c95967761096b8c1b1e` |
| [lamu modules](https://github.com/LineageOS/android_kernel_motorola_lamu-modules) | `70e7426a69b8ba42667722f57bf4c709faf7ad3b` |
| [lamu MediaTek modules](https://github.com/LineageOS/android_kernel_motorola_lamu-mediatek_modules) | `635ca317b538541c6c33c1abee9aa56b01aeb407` |

Build target: `mgk_64_k66`

Overlays:
- `mt6768_overlay.config`
- `lamu_overlay.config`
- `lineage.config`
- `uniloader_overlay.config`

`uniloader_overlay.config` enables built-in SimpleDRM, fbdev emulation,
VT and the framebuffer console for early output from a bootloader-
initialized simple framebuffer. The embedded command line uses
`console=tty0` instead of `console=ttynull` so kernel messages reach
that console. BTF debug data and KASAN are disabled to keep the
uncompressed image small. The overlay is inert when no
`simple-framebuffer` node is present in the device tree.

## G05 / uniLoader test artifacts

`kernel/dts/lamul-uniloader.dtso` describes the framebuffer that
uniLoader sets up on the Moto G05 (XT2523-4, `lamul`). The values are
taken from `board/motorola/board-lamul.c` in the uniLoader tree. Its
`/chosen` fragment declares `ranges` so the framebuffer `reg` is
translated correctly. It also reserves the ramoops region used by LK at
`0x4d010000`, size `0xe0000`, with `0x40000` record and console areas
and 16-byte ECC. Pstore, console pstore and RAM pstore are enabled in
the kernel config so logs survive a failed boot.

The downstream `mediatek-drm` module carries a stale `mtk_drm_fbdev.c`
that does not build with `CONFIG_DRM_FBDEV_EMULATION=y`. Apply
`kernel/patches/disable-mtk-drm-fbdev.patch` in the kernel workspace
before building; it leaves generic fbdev emulation for SimpleDRM intact.

After the normal kernel build, run:

```sh
./kernel/build-uniloader-artifacts.sh ~/Downloads/lamu-kernel-workspace
```

This produces `lamul-uniloader.dtbo` and a pre-merged
`mt6768-lamul-uniloader.dtb` (base DTB + lamu overlay + framebuffer
overlay). They are staged in
`out/dist/kernel_device_modules-6.6/mgk_64_k66.user/` and copied to
`out/mgk_64_k66/dist/` when that directory exists. The pre-merged DTB
is for the uniLoader test only; it is not a Moto G15 Power device tree.

## Kernel checkout

Install Git, Python 3, Java 11 and the Android `repo` tool.

Run from a new directory:

```sh
mkdir -p ~/src/lamu-kernel
cd ~/src/lamu-kernel
repo init -u https://github.com/rmfnico/nura-lamu -b main -m kernel/manifest.xml
repo sync
```

The manifest pins all source projects to the revisions used for this port.

## Kernel build

From the kernel checkout root:

```sh
./build_mgk_64_k66.sh
```

Build artifacts are staged in `out/mgk_64_k66/dist/`.

The kernel uses the Kleaf/Bazel build system.

The `linux-motorola-lamu` postmarketOS kernel package is not implemented yet.

## Status

- Kernel source configuration prepared.
- Kernel build completed.
- Device package added.
- Boot and hardware functionality not yet tested on lamu.
- G05 boot remains untested; no successful Linux boot has been
  confirmed. This remains an experimental cross-device test.
- The G05 console, framebuffer translation, ramoops and image size
  fixes are built into this iteration but have not been retested yet.
- The MT6768 DTB already carries a valid `/memory` node at
  `0x40000000`; no RAM values are guessed or injected for the G05.
