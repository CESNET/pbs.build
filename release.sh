#!/bin/bash

# BASE CONFIGURATION
export LC_ALL=C
export LANG=C

# Cleanup
rm -f debian
autoreconf -ivf

# Determine System & it's version

# This is debian/ubuntu
os=
os_version=
os_codename=""
if [ -r /etc/debian_version ]; then
	os="debian"
	major_ver=`cat /etc/debian_version | cut -d. -f1`;
	
	# debian 7
	if [ "$major_ver" == "6" ]; then
		os_version=6;
	elif [ "$major_ver" == "7" ]; then
		os_version=7;
	elif [ "$major_ver" == "8" ]; then
		os_version=8;
	elif [ "$major_ver" == "9" ]; then
		os_version=9;
	elif [ "$major_ver" == "10" ]; then
		os_version=10;
	elif [ "$major_ver" == "buster/sid" ]; then
		os_codename="$(lsb_release -c | awk '{print $2}')";
		os_version=0;
	fi
fi

if [ -z os ] || [ -z os_version ]; then
	echo "ERROR: Unsupported system detected.";
	exit 1
fi

BUILDDIR=$(mktemp -d);
cp pbspro.build/* ${BUILDDIR}
if [ $os_version -eq 7 ]; then
	mv ${BUILDDIR}/control.deb7 ${BUILDDIR}/control
	sed -i -- 's/DEBIAN_VERSION/deb7/g' ${BUILDDIR}/changelog
elif [ $os_version -eq 8 ]; then
	mv ${BUILDDIR}/control.deb8 ${BUILDDIR}/control
	sed -i -- 's/DEBIAN_VERSION/deb8/g' ${BUILDDIR}/changelog
elif [ $os_version -eq 9 ]; then
	mv ${BUILDDIR}/control.deb9 ${BUILDDIR}/control
	sed -i -- 's/DEBIAN_VERSION/deb9/g' ${BUILDDIR}/changelog
elif [ $os_version -eq 10 ]; then
	mv ${BUILDDIR}/control.deb10 ${BUILDDIR}/control
	sed -i -- 's/DEBIAN_VERSION/deb10/g' ${BUILDDIR}/changelog
fi

if [ "x$os_codename" == "xbionic" ]; then
	mv ${BUILDDIR}/control.bionic ${BUILDDIR}/control
	sed -i -- 's/+DEBIAN_VERSION//g' ${BUILDDIR}/changelog
fi

ln -s ${BUILDDIR} debian
DEB_BUILD_OPTIONS="nostrip noopt" fakeroot ./debian/rules clean
DEB_BUILD_OPTIONS="nostrip noopt" fakeroot ./debian/rules binary


exit 0
