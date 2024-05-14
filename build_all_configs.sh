#!/bin/bash
set -e

### variables ###
export _workdir="${PWD}/build"

### colors ###
export NO_FORMAT="\033[0m"
export F_BOLD="\033[1m"
export C_WHITE="\033[38;5;15m"
export C_BLUE="\033[48;5;12m"

### fn ###
print_info() {
    echo -e "${F_BOLD}${C_WHITE}${C_BLUE}INFO:${NO_FORMAT}" "${1}"
}

### Quiet pushd & popd ###
pushd() { command pushd "$@" > /dev/null; }
popd() { command popd "$@" > /dev/null; }

### main ###
print_info "Building for all device configs in ${PWD}/device_configs/ ..."

pushd "${PWD}/device_configs/"
    for device_config in *; do
        print_info "Now building ${device_config} ..."
        cd ..
        ln -sf "../device_configs/${device_config}" "./include/device_config.sh"
        rm -rf "${_workdir}"
        ./lineageos_kernel_builder.sh download_sources
        ./lineageos_kernel_builder.sh make_kernel
        ./lineageos_kernel_builder.sh make_anykernel3_zip
    done
popd

print_info "Done!"
