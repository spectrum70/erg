# erg lib - packegess.sh

function pkg_apply_patches {
	sources_dir=${DIR_ERG}/sources/$1

	if [ -e ${sources_dir}/patches ]; then
		inf "package [${1}]: applying patches ..."
		while IFS= read -r patch; do
			echo "applying ${patch} ..."
			patch -p1 < ${sources_dir}/${patch}
		done < ${sources_dir}/patches
	fi
}

function pkg_handle_menuconfig {
	if [ "${1}" = "busybox" ]; then
		if [ -n "${busybox_reconf}" ]; then
			cp ${DIR_ERG}/${DIR_SRC_CFG}/${1}/.config \
 				${DIR_ERG}/${2}/.config
			make menuconfig
			cp .config ${DIR_ERG}/${DIR_SRC_CFG}/${1}/.config
		else
			if [ -e ${DIR_ERG}/${DIR_SRC_CFG}/${1}/.config ]; then
				cp ${DIR_ERG}/${DIR_SRC_CFG}/${1}/.config \
					${DIR_ERG}/${2}/.config
			else
				make menuconfig
			fi
		fi
	fi
}

# Packages as busybox
function pkg_build_makeonly {

	pkg_apply_patches ${1}

	inf "package [${1}]: building ..."

	export CC=${erg_cross}gcc
	export AR=${erg_cross}ar

	# Other packages may need this
	echo "CC=${erg_cross}gcc" >> Config
	echo "AR=${erg_cross}ar" >> Config
	echo "CFLAGS+=${build_cflags}" >> Config
	echo "LDFLAGS+=${build_cflags}" >> Config

	make ARCH="${arch}" CROSS_COMPILE="${erg_cross}" CC=${erg_cross}gcc \
		EXTRA_CFLAGS="${build_cflags}" EXTRA_LDFLAGS="${build_ldflags}" \
		V=1 SKIP_STRIP="y" \
		CONFIG_PREFIX="${DIR_ERG}/targetfs" ${MAKEVARS} install
}

function pkg_configure_classic {

	inf "package [${1}]: configuring ..."

	echo ${erg_cross}gcc

	export CC=${erg_cross}gcc
	export AR=${erg_cross}ar

	pkg_apply_patches ${1}

	./configure --host=${target_host} \
			--target=${target_host} \
			--prefix=${DIR_ERG}/targetfs/usr \
			${pkg_confopts}

	# Other packages may need this
	echo "CC=${erg_cross}gcc" >> Config
	echo "AR=${erg_cross}ar" >> Config
	echo "CFLAGS+=${build_cflags}" >> Config
	echo "LDFLAGS+=${build_cflags}" >> Config

	inf "package [${1}]: building ..."

	make ARCH="${arch}" \
		CROSS_COMPILE="${erg_cross}" V=1 \
		${MAKEVARS} \
		EXTRA_CFLAGS="${build_cflags}" \
		LDFLAGS="${build_ldflags}" \
		CONFIG_PREFIX="${DIR_ERG}/targetfs"

	make ARCH="${arch}" \
		CROSS_COMPILE="${erg_cross}" V=1 \
		${MAKEVARS} \
		EXTRA_CFLAGS="${build_cflags}" \
		LDFLAGS="${build_ldflags}" \
		CONFIG_PREFIX="${DIR_ERG}/targetfs" install
}

function pkg_select_build {

	if [ -e "Makefile" ] && [ ! -e "configure" ]; then
		pkg_build_makeonly $1
	else
		if [ -e "./configure" ]; then
			pkg_configure_classic $1
		fi
	fi
}

function pkg_check_and_build {
	pkg=$1

	source sources/${pkg}/pkg.info

	pkg_name=${pkg_url##*/}
	pkg_dir=${DIR_BUILD}/${pkg_name%.*.*}

	if [ ! -e ${DIR_DL}/${pkg_name} ]; then
		wget ${pkg_url} --directory-prefix=${DIR_DL}
	fi
	if [ -e ${pkg_dir} ]; then
		rm -rf ${pkg_dir}
	fi

	inf "package [${pkg}]: extracting ..."

	if [ ${pkg_name: -7} == ".tar.xz" ]; then
		tar -xxf ${DIR_DL}/${pkg_name} --directory ${DIR_BUILD}
	fi
	if [ ${pkg_name: -8} == ".tar.bz2" ]; then
		tar -jxf ${DIR_DL}/${pkg_name} --directory ${DIR_BUILD}
	fi
	if [ ${pkg_name: -7} == ".tar.gz" ]; then
		tar -zxf ${DIR_DL}/${pkg_name} --directory ${DIR_BUILD}
	fi

	build_cflags="${arch_cflags} ${dist_cflags} ${pkg_cflags}"
	build_ldflags="${build_cflags} ${pkg_ldflags}"

	# Some special packages as Busybox uses .config / menuconfig
	pkg_handle_menuconfig ${pkg} ${pkg_dir}

	cd ${pkg_dir}
	pkg_select_build ${pkg}
	cd -
}

function pkg_build() {
	pkg_check_and_build ${1}
}

function pkg_build_pkg_list {
	while IFS= read -r line; do
		# Skip comments
		line=$(sed 's/#.*$//g' <<< ${line})
		IFS=$'\t ' read -r -a arr <<<"$line"
		export pkg_name="${arr[0]}"
		export pkg_ver="${arr[1]}"
		if [ -n "${pkg_name}" ] && [ -n "${pkg_ver}" ]; then
			printf "%s:%s\n" "${pkg_name}" "${pkg_ver}"
			pkg_build ${pkg_name}
		fi
	done < ${1}
}
