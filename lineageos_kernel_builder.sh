#!/bin/bash
set -e

### variables ###
export _workdir="${PWD}/build"
export _cachedir="${PWD}/cache"
export _outdir="${PWD}/out"

### include ###
source "$(dirname "${0}")"/include/config.sh
source "$(dirname "${0}")"/include/device_config.sh

### colors ###
export NO_FORMAT="\033[0m"
export F_BOLD="\033[1m"
export C_WHITE="\033[38;5;15m"
export C_RED="\033[48;5;9m"
export C_BLUE="\033[48;5;12m"

### fn ###
print_error() {
    echo -e "${F_BOLD}${C_WHITE}${C_RED}ERROR!${NO_FORMAT}" "${1}"
    exit 1
}

print_info() {
    echo -e "${F_BOLD}${C_WHITE}${C_BLUE}INFO:${NO_FORMAT}" "${1}"
}

print_help() {
	echo -e "${F_BOLD}${C_WHITE}${C_BLUE}Usage:${NO_FORMAT} ${0} {help|download_sources|make_defconfig|make_menuconfig|make_kernel|make_anykernel3_zip}"
	[[ -n "${1}" ]] && print_error "Invalid argument."
}

### Quiet pushd & popd ###
pushd() { command pushd "$@" > /dev/null; }
popd() { command popd "$@" > /dev/null; }

download_and_handle_tarball() {
    local extract_dir="${1}"
    local filename="${2}"
    local url="${3}"
    local content_dir="${4}"

    case $downloader in
        wget)
            local download_cmd="wget -q --show-progress -O ./${filename} ${url}"
        ;;

        wget2)
            local download_cmd="wget2 -q --force-progress -O ./${filename} ${url}"
        ;;

        *)
            print_error "Invalid \${downloader} variable."
        ;;
    esac

    if [ ! -d "${_workdir}/${extract_dir}" ]; then
        mkdir -p "${_workdir}/${extract_dir}"
        pushd "${_workdir}/${extract_dir}"
            ${download_cmd}
	        tar -xf ./"${filename}"
            if [ -n "${content_dir}" ]; then
                mv "${content_dir}"/* .
                rm -r "${content_dir}"
            fi
            rm ./"${filename}"
        popd
    else
        print_info "${_workdir}/${extract_dir} already exists, skipping..."
    fi
}

integrate_kernelsu() {
    if [ ! -d "${_workdir}/${kernel_dir}/KernelSU" ]; then
        pushd "${_workdir}/${kernel_dir}"
	    	print_info "Intergrating KernelSU into the kernel source code..."
	    	curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
	    popd
    fi

    pushd "${_workdir}/${kernel_dir}"
        print_info "Enabling kprobe (needed by KernelSU)..."
	    sed -i -e '/^CONFIG_KPROBES$/d' \
	    	-e '/^CONFIG_HAVE_KPROBES$/d' \
	    	-e '/^CONFIG_KPROBE_EVENTS$/d' \
            "${kernel_config_path}"
        cat >> "${kernel_config_path}" << EOF
CONFIG_KPROBES=y
CONFIG_HAVE_KPROBES=y
CONFIG_KPROBE_EVENTS=y
EOF

        if [ ${add_ksu_text} == "true" ]; then
            print_info "Adding -ksu to EXTRAVERSION in Makefile..."
            sed -i '/EXTRAVERSION =/c\EXTRAVERSION = -ksu' ./Makefile
	    fi
    popd

    print_info "You should backport path_umount from Linux 5.9 to fs/namespace.c"
    print_info "Read: https://kernelsu.org/guide/how-to-integrate-for-non-gki.html#how-to-backport-path-umount"
}

# Funtions to download source codes
source "$(dirname "${0}")"/include/download.sh

make_defconfig() {
    [ ! -d "${_workdir}/$kernel_dir" ] && print_error "Cannot find kernel source directory!"
    pushd "${_workdir}/$kernel_dir"
        print_info "Running make ${device_defconfig}..."
        [ ! -d ./"${kernel_build_out_prefix}" ] && mkdir -p ./"${kernel_build_out_prefix}"
        eval "${path_override}" \
        "${kernel_make_cmd}" \
        "${kernel_make_flags}" \
        O="${kernel_build_out_prefix}" \
        ARCH="${device_arch}" \
        CROSS_COMPILE="${kernel_cross_compile}" \
        CROSS_COMPILE_ARM32="${kernel_cross_compile_arm32}" \
        CROSS_COMPILE_COMPAT="${kernel_cross_compile_compat}" \
        CLANG_TRIPLE="${kernel_clang_triple}" \
        CC="${kernel_cc}" \
        "${device_defconfig}"
    popd
}

make_menuconfig() {
    [ ! -d "${_workdir}/$kernel_dir" ] && print_error "Cannot find kernel source directory!"
    pushd "${_workdir}/$kernel_dir"
        print_info "Running make menuconfig..."
        [ ! -d ./"${kernel_build_out_prefix}" ] && mkdir -p ./"${kernel_build_out_prefix}"
        eval "${path_override}" \
        "${kernel_make_cmd}" \
        "${kernel_make_flags}" \
        O="${kernel_build_out_prefix}" \
        ARCH="${device_arch}" \
        CROSS_COMPILE="${kernel_cross_compile}" \
        CROSS_COMPILE_ARM32="${kernel_cross_compile_arm32}" \
        CROSS_COMPILE_COMPAT="${kernel_cross_compile_compat}" \
        CLANG_TRIPLE="${kernel_clang_triple}" \
        CC="${kernel_cc}" \
        menuconfig
    popd
}

make_kernel() {
    [ ! -d "${_workdir}/$kernel_dir" ] && print_error "Cannot find kernel source directory!"
    pushd "${_workdir}/$kernel_dir"
        print_info "Running make..."
        [ ! -e ./.config ] && make_defconfig
        eval "${path_override}" \
        "${kernel_make_cmd}" \
        "${kernel_make_flags}" \
        O="${kernel_build_out_prefix}" \
        ARCH="${device_arch}" \
        CROSS_COMPILE="${kernel_cross_compile}" \
        CROSS_COMPILE_ARM32="${kernel_cross_compile_arm32}" \
        CROSS_COMPILE_COMPAT="${kernel_cross_compile_compat}" \
        CLANG_TRIPLE="${kernel_clang_triple}" \
        CC="${kernel_cc}"
    popd

    if [ "${enable_anykernel3_zip}" = "false" ]; then
        [ ! -d "${_outdir}" ] && mkdir -p "${_outdir}"
        cp "${kernel_image_path}" "${_outdir}"
    fi
}

make_anykernel3_zip() {
    if [ "${enable_anykernel3_zip}" = "false" ]; then
        print_error "You didn't enable Making AnyKernel3 zip support, check $(dirname "${0}")/include/device_config.sh"
    elif [ ! -f "${kernel_image_path}" ]; then
        print_error "Cannot find ${kernel_image_path}, have you run ${0} make_kernel ?"
    else
        [ ! -d "${_outdir}" ] && mkdir -p "${_outdir}"
        pushd "${_workdir}/AnyKernel3-${device_codename}"
            print_info "Making AnyKernel3 zip at ${_outdir}/${device_codename}-${kernel_version}-$(date +%F)-AnyKernel3.zip ..."
            cp "${kernel_image_path}" .
            zip -qr9 "${_outdir}/${device_codename}-${kernel_version}-$(date +%F)-AnyKernel3.zip" * -x .git .gitignore
        popd
    fi
}

### main ###
case "$1" in
    help)
        print_help
    ;;

    download_sources)
        download_sources
    ;;

    make_defconfig)
        make_defconfig
    ;;

    make_menuconfig)
        make_menuconfig
    ;;

    make_kernel)
        make_kernel
    ;;

    make_anykernel3_zip)
        make_anykernel3_zip
    ;;

    *)
        print_help "werr"
    ;;
esac
