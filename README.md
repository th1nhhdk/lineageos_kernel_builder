# lineageos_kernel_builder #
Bash script to build a custom LineageOS Kernel without having to download unnecessary source code.

## Supported devices ##
- Sony Xperia 1 II (`pdx203`)
- Sony Xperia 5 II (`pdx206`) (not regularly tested, should work)
- OnePlus 6 (`enchilada`) (untested)
- OnePlus 6T (`fajita`) (untested)
- Xiaomi Mi Mix 2S (`polaris`) (not regularly tested, should work)

## How to use ##
- Check `./config.sh` for configuration options.

- Symlink a device configuration file from `./device_configs/` to `./include/device_config.sh` before running `lineageos_kernel_builder.sh`, for example:
```bash
ln -sf ./device_configs/pdx206_device_config.sh ./include/device_config.sh # We are now building for pdx206
```

- Then:
```bash
lineageos_kernel_builder.sh download_sources
# lineageos_kernel_builder.sh make_defconfig  # optional: run "make defconfig" in Kernel source directory
# lineageos_kernel_builder.sh make_menuconfig # optional: run "make menuconfig" in Kernel source directory
lineageos_kernel_builder.sh make_kernel
lineageos_kernel_builder.sh make_anykernel3_zip # ${enable_anykernel3_zip} needs to be "true" for this to work
```

- You can also run `build_all_configs.sh` to build for all device configs in `./device_configs/`.

## (Recommended) Using cached `prebuilts_clang_host_linux_x86` ##
- Because `prebuilts_clang_host_linux_x86` is very big (about 13GB!), you can cache it to avoid redownloading everytime you build the Kernel:
```bash
lineageos_kernel_builder.sh download_sources
mkdir -p ./cache/
source ./include/device_config.sh
cp -r ./build/prebuilts/clang/host/linux-x86 ./cache/prebuilts_clang_host_linux_x86-${aosp_tag}
```
- Now everytime you build the script will use the cached `prebuilts_clang_host_linux_x86` instead.

## Differences compared to building with the whole LineageOS ROM ##
- none (as far as I know)
