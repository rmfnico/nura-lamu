# Moto G15 Power (lamu) — postmarketOS

port for the Motorola Moto G15 Power (XT2521-5).
note: this port hasn't been tested to boot yet.

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

Kernel sources

Sources are kept upstream, not vendored here.

| Project | Commit |
|---|---|
| [android common](https://android.googlesource.com/kernel/common) | `7ed219d1133d473dd3590c95967761096b8c1b1e` |
| [lamu modules](https://github.com/LineageOS/android_kernel_motorola_lamu-modules) | `70e7426a69b8ba42667722f57bf4c709faf7ad3b` |

Build target: `mgk_64_k66`

Overlays:
- `mt6768_overlay.config`
- `lamu_overlay.config`
- `lineage.config`
