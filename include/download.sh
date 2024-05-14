download_clang() {
	download_and_handle_tarball \
		"prebuilts/clang/kernel/linux-x86/clang-${clang_version}" \
		"clang-${clang_branch}.tar.gz" \
		"https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-${clang_version}/archive/refs/heads/${clang_branch}.tar.gz" \
		"android_prebuilts_clang_kernel_linux-x86_clang-${clang_version}-${clang_branch}"
}

download_clang_host_linux_x86() {
	if [ ! -d "${_workdir}/prebuilts/clang/host/linux-x86" ] && [ -d "${_cachedir}/linux-x86" ]; then
		print_info "Found cached prebuilts/clang/host/linux-x86, using it instead..."
		mkdir -p "${_workdir}/prebuilts/clang/host/"
		cp -r "${_cachedir}/linux-x86" "${_workdir}/prebuilts/clang/host/"
	else
		download_and_handle_tarball \
			"prebuilts/clang/host/linux-x86" \
			"clang_host_linux_x86-${aosp_tag}.tar.gz" \
			"https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/tags/${aosp_tag}.tar.gz"
	fi
}

download_gcc_aarch64() {
	download_and_handle_tarball \
		"prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-${gcc_aarch64_version}" \
		"aarch64-linux-android-${gcc_aarch64_version}.tar.gz" \
		"https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-${gcc_aarch64_version}/archive/refs/heads/${gcc_aarch64_branch}.tar.gz" \
		"android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-${gcc_aarch64_version}-${gcc_aarch64_branch}"
}

download_gcc_arm() {
	download_and_handle_tarball \
		"prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-${gcc_arm_version}" \
		"arm-linux-androideabi-${gcc_arm_version}.tar.gz" \
		"https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-${gcc_arm_version}/archive/refs/heads/${gcc_arm_branch}.tar.gz" \
		"android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-${gcc_arm_version}-${gcc_arm_branch}"
}

download_tools_lineage() {
	download_and_handle_tarball \
		"prebuilts/tools-lineage" \
		"tools-lineage-${lineageos_branch}.tar.gz" \
		"https://github.com/LineageOS/android_prebuilts_tools-lineage/archive/refs/heads/${lineageos_branch}.tar.gz" \
		"android_prebuilts_tools-lineage-${lineageos_branch}"
}

download_build_tools() {
	download_and_handle_tarball \
		"prebuilts/build-tools" \
		"build-tools-${lineageos_branch}.tar.gz" \
		"https://github.com/LineageOS/android_prebuilts_build-tools/archive/refs/heads/${lineageos_branch}.tar.gz" \
		"android_prebuilts_build-tools-${lineageos_branch}"
}

download_misc() {
	download_and_handle_tarball \
		"prebuilts/misc" \
		"misc-${aosp_tag}.tar.gz" \
		"https://android.googlesource.com/platform/prebuilts/misc/+archive/refs/tags/${aosp_tag}.tar.gz"
}

download_kernel_build_tools() {
	download_and_handle_tarball \
		"prebuilts/kernel-build-tools" \
		"kernel-build-tools-${aosp_tag2}.tar.gz" \
		"https://android.googlesource.com/kernel/prebuilts/build-tools/+archive/refs/tags/${aosp_tag2}.tar.gz"
}

download_sources() {
    [ ! -d "${_workdir}" ] && mkdir -p "${_workdir}"

    [ "${download_clang}" = "true" ] && download_clang
    [ "${download_clang_host_linux_x86}" = "true" ] && download_clang_host_linux_x86
	[ "${download_gcc_aarch64}" = "true" ] && download_gcc_aarch64
	[ "${download_gcc_arm}" = "true" ] && download_gcc_arm
	[ "${download_tools_lineage}" = "true" ] && download_tools_lineage
	[ "${download_build_tools}" = "true" ] && download_build_tools
	[ "${download_misc}" = "true" ] && download_misc
	[ "${download_kernel_build_tools}" = "true" ] && download_kernel_build_tools
    download_kernel
    [ "${integrate_kernelsu}" = "true" ] && integrate_kernelsu
    [ "${enable_anykernel3_zip}" = "true" ] && download_anykernel3
}
