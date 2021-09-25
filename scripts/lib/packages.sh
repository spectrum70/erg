# erg lib - packages.sh

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

	unset pkg_makevars

	inf "package [${1}]: makeonly ..."

	export CC=${erg_cross}gcc
	export AR=${erg_cross}ar

	# Other packages may need this
	echo "CC=${erg_cross}gcc" >> Config
	echo "AR=${erg_cross}ar" >> Config
	echo "CFLAGS+= ${build_cflags}" >> Config
	echo "LDFLAGS+= ${build_ldlags}" >> Config

	make ARCH="${arch}" CROSS_COMPILE="${erg_cross}" CC=${erg_cross}gcc \
		CFLAGS="${build_cflags}" LDFLAGS="${build_ldflags}" \
		V=1 SKIP_STRIP="y" \
		PREFIX="${DIR_ERG}/targetfs/usr" \
		CONFIG_PREFIX="${DIR_ERG}/targetfs" \
		${pkg_makevars} install
}

function pkg_configure_classic {

	inf "package [${1}]: configuring ..."

	echo ${erg_cross}gcc

	export CC=${erg_cross}gcc
	export AR=${erg_cross}ar

	pkg_apply_patches ${1}

	CFLAGS+=" ${build_cflags}"
	export CFLAGS
	LDFLAGS+=" ${build_ldflags}"
        export LDFLAGS

	dbg "./configure --host=${target_host} \
			--target=${target_host} \
			--prefix=${DIR_ERG}/targetfs/usr \
			--exec-prefix=${DIR_ERG}/targetfs/usr \
			${arch_confpts} ${pkg_confopts}"

	./configure --host=${target_host} \
			--target=${target_host} \
			--prefix=${DIR_ERG}/targetfs/usr \
			--exec-prefix=${DIR_ERG}/targetfs/usr \
			${arch_confopts} ${pkg_confopts}

	# Other packages may need this
	echo "CC=${erg_cross}gcc" >> Config
	echo "AR=${erg_cross}ar" >> Config
	echo "CFLAGS+= ${build_cflags}" >> Config
	echo "LDFLAGS+= ${build_ldlags}" >> Config

	inf "package [${1}]: building ..."
	inf "package [${1}]: build_cflags  : ${build_cflags}"
	inf "package [${1}]: build_ldflags : ${build_ldflags}"

	make ARCH="${arch}" \
		CROSS_COMPILE="${erg_cross}" V=1 \
		${pkg_makevars} \
		CONFIG_PREFIX="${DIR_ERG}/targetfs"

	make ARCH="${arch}" \
		CROSS_COMPILE="${erg_cross}" V=1 \
		${pkg_makevars} \
		install
}

function pkg_select_build {

	if [ -e "autogen.sh" ]; then
		./autogen.sh ${pkg_autogen_opts}
	else
		if [ ! -e "configure" ] && [ -e "configure.ac" ]; then
			inf "autoreconf ..."
			autoreconf -fi
		fi
	fi
	if { [ -e "Makefile" ] || [ -e "makefile" ]; } && [ ! -e "configure" ]; then
		pkg_build_makeonly $1
	else
		if [ -e "./configure" ]; then
			pkg_configure_classic $1
		fi
	fi
}

function pkg_check_and_build {
	pkg=$1

	# unset here all pkg-related involved exports
	unset pkg_cflags
	unset pkg_ldflags
	unset pkg_confopts
	unset pkg_makevars
	unset pkg_name_override

	source sources/${pkg}/pkg.info

	pkg_name=${pkg_url##*/}
	pkg_dir=${DIR_BUILD}/${pkg_name%.*.*}

	if [ -e ${pkg_dir} ]; then
		rm -rf ${pkg_dir}
	fi

	if [ "${pkg_url:0:4}" == "git@" ]; then
		if [ -e ${DIR_BUILD}/${pkg_name} ]; then
			rm -rf ${DIR_BUILD}/${pkg_name}
		fi
		git clone --branch ${pkg_git_branch} ${pkg_url} ${DIR_BUILD}/${pkg_name}
	else
		if [ ! -e ${DIR_DL}/${pkg_name} ]; then
			# wget ${pkg_url} --directory-prefix=${DIR_DL}
			curl --create-dirs -O --output-dir ${DIR_DL} -L ${pkg_url}
		fi

		inf "package [${pkg}]: extracting [${pkg_name}] ..."

		if [ ${pkg_name: -7} == ".tar.xz" ]; then
			tar -xxf ${DIR_DL}/${pkg_name} --directory ${DIR_BUILD}
		fi
		if [ ${pkg_name: -8} == ".tar.bz2" ]; then
			tar -jxf ${DIR_DL}/${pkg_name} --directory ${DIR_BUILD}
		fi
		if [ ${pkg_name: -7} == ".tar.gz" ]; then
			tar -zxf ${DIR_DL}/${pkg_name} --directory ${DIR_BUILD}
		fi
	fi

	build_cflags="${arch_cflags} ${dist_cflags} ${pkg_cflags}"
	build_ldflags="${arch_ldflags} ${dist_ldflags} ${pkg_ldflags}"

	if [ "x${pkg_name_override}" != "x" ]; then
		cd ${DIR_BUILD}/${pkg_name_override}
	else
		cd ${pkg_dir}
	fi

	# Some special packages as Busybox uses .config / menuconfig
	export TERM=vt100
	pkg_handle_menuconfig ${pkg} ${pkg_dir}

	pkg_select_build ${pkg}
	cd -
}

function pkg_build() {
	pkg_check_and_build ${1}
}

function pkg_populate_lists {
	while IFS= read -r line; do
		# Skip comments
		line=$(sed 's/#.*$//g' <<< ${line})
		if [ -n "${line}" ]; then
			IFS=$'\t ' read -r -a arr <<<"$line"
			list_name+=(${arr[0]})
			list_ver+=(${arr[1]})
		fi
	done < ${1}
}

function pkg_build_pkg_list {

	list_name=("")
	list_ver=("")

	pkg_populate_lists ${1}

	# A second loop for package processing is needed
	for i in ${!list_name[@]}; do
		export pkg_name=${list_name[i]}
		export pkg_ver=${list_ver[i]}
		if [ -n "${pkg_name}" ] && [ -n "${pkg_ver}" ]; then
			# printf "building %s:%s\n" "${pkg_name}" "${pkg_ver} ..."
			pkg_build ${pkg_name}
		fi
	done
}

function pkg_set {

	list_name=("")
	list_ver=("")

	pkg_populate_lists ${1}

	# A second loop for package processing is needed
	for i in ${!list_name[@]}; do
		if [ "x${list_name[i]}" == "x${2}" ]; then
			export pkg_name=${list_name[i]}
			export pkg_ver=${list_ver[i]}
			if [ -n "${pkg_name}" ] && [ -n "${pkg_ver}" ]; then
				# printf "building %s:%s\n" "${pkg_name}" "${pkg_ver} ..."
				pkg_build ${pkg_name}
			fi
			break
		fi
	done
}
