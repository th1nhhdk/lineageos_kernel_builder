### from LineageOS/android/default.xml ###
export lineageos_branch="lineage-21.0"
export aosp_tag="android-14.0.0_r67"
export aosp_tag2="android-14.0.0_r0.76"

### from LineageOS/android/snippets/lineage.xml ###
export clang_version="r416183b"
export clang_branch="lineage-20.0"
export gcc_aarch64_version="4.9"
export gcc_aarch64_branch="lineage-19.1"
export gcc_arm_version="4.9"
export gcc_arm_branch="lineage-19.1"

### We need these to build the Kernel ###
export download_clang="true"
export download_clang_host_linux_x86="true"
export download_gcc_aarch64="true"
export download_gcc_arm="true"
export download_tools_lineage="true"
export download_build_tools="true"
export download_misc="true" # from LineageOS/android_device_sony_sm8250-common/BoardConfigCommon.mk
export download_kernel_build_tools="true"

### Configuration options ###
export integrate_kernelsu="false" # KernelSU is already intergrated in kernel sources
export enable_anykernel3_zip="true" # Create a AnyKernel3 zip containing the built Kernel
export is_linux_4_9="false"
export backport_path_umount="false" # The patch is already intergrated in kernel sources

### Kernel configuration ###
export kernel_dir="android_kernel_sony_sm8250-kernelsu"
export kernel_branch="lineage-21"
export device_codename="pdx203"
export device_arch="arm64"
export device_defconfig="pdx203_defconfig"

# from LineageOS/android_kernel_sony_sm8250/arch/arm64/configs/pdx203_defconfig
if [ "${add_ksu_text}" = "true" ]; then
    export kernel_version="4.19.306-ksu-perf"
else
    export kernel_version="4.19.306-perf"
fi

export kernel_build_out_prefix="out"
export kernel_cross_compile="aarch64-linux-android-"
export kernel_cross_compile_arm32="${_workdir}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androidkernel-"
export kernel_cross_compile_compat="${kernel_cross_compile_arm32}"
export kernel_clang_triple="aarch64-linux-gnu-"
export kernel_cc="'ccache clang --cuda-path=/dev/null'" # Without '' errors will happen
export kernel_image_name="Image" # BOARD_KERNEL_IMAGE_NAME
export kernel_image_path="${_workdir}/${kernel_dir}/${kernel_build_out_prefix}/arch/${device_arch}/boot/${kernel_image_name}"
export kernel_config_path="./arch/${device_arch}/configs/${device_defconfig}"

download_kernel() {
    if [ "${shallow_clone}" = "true" ]; then
        local extra_git_arguments="--depth 1"
    else
        local extra_git_arguments=""
    fi

    if [ ! -d "${_workdir}/${kernel_dir}" ]; then
        git clone --recurse-submodules \
            -b "$kernel_branch" \
            ${extra_git_arguments} \
            "https://github.com/th1nhhdk/${kernel_dir}.git" \
            "${_workdir}/${kernel_dir}"
    else
        print_info "${_workdir}/${kernel_dir} already exists, skipping..."
    fi
}

# from LineageOS/android_vendor_lineage/build/tasks/kernel.mk
# and from LineageOS/android_vendor_lineage/config/BoardConfigKernel.mk
export path_override="PATH=${_workdir}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin:${_workdir}/prebuilts/clang/kernel/linux-x86/clang-r416183b/bin:${_workdir}/prebuilts/tools-lineage/linux-x86/bin:${_workdir}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin:$PATH \
    LD_LIBRARY_PATH=${_workdir}/prebuilts/clang/kernel/linux-x86/clang-r416183b/lib64:$LD_LIBRARY_PATH \
    PERL5LIB=${_workdir}/prebuilts/tools-lineage/common/perl-base \
    BISON_PKGDATADIR=${_workdir}/prebuilts/build-tools/common/bison"
export kernel_make_cmd="${_workdir}/prebuilts/build-tools/linux-x86/bin/make"

# from LineageOS/android_vendor_lineage/config/BoardConfigKernel.mk
# HOSTLDFLAGS without '' will cause errors
export kernel_make_flags="-j ${make_jobs} \
    CFLAGS_MODULE=-fno-pic \
    CPATH=/usr/include:/usr/include/x86_64-linux-gnu \
    HOSTLDFLAGS='-L/usr/lib/x86_64-linux-gnu -L/usr/lib64 -fuse-ld=lld' \
    HOSTCC=${_workdir}/prebuilts/clang/host/linux-x86/clang-r487747c/bin/clang \
    HOSTCXX=${_workdir}/prebuilts/clang/host/linux-x86/clang-r487747c/bin/clang++ \
    LZ4=${_workdir}/prebuilts/kernel-build-tools/linux-x86/bin/lz4 \
    LEX=${_workdir}/prebuilts/build-tools/linux-x86/bin/flex \
    YACC=${_workdir}/prebuilts/build-tools/linux-x86/bin/bison \
    M4=${_workdir}/prebuilts/build-tools/linux-x86/bin/m4 "

# from LineageOS/android_device_sony_sm8250-common/BoardConfigCommon.mk
kernel_make_flags+="DTC_EXT=${_workdir}/prebuilts/misc/linux-x86/dtc/dtc \
    DTC_OVERLAY_TEST_EXT=${_workdir}/prebuilts/misc/linux-x86/libufdt/ufdt_apply_overlay \
    LLVM=1 \
    LLVM_IAS=1"

### ${enable_anykernel3_zip} needs to be "true" for this to work ###
download_anykernel3() {
    download_and_handle_tarball \
        "AnyKernel3-${device_codename}" \
        "AnyKernel3-${device_codename}.tar.gz" \
        "https://github.com/th1nhhdk/AnyKernel3/archive/refs/heads/${device_codename}.tar.gz" \
        "AnyKernel3-${device_codename}"
}
