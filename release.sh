#!/bin/bash

# BASE CONFIGURATION
RELEASE_TAG_PREFIX="v"

export LC_ALL=C
export LANG=C

# Cleanup
rm -f debian
autoreconf -ivf

# Determine System & it's version

# This is debian
os=
os_version=
if [ -r /etc/debian_version ]; then
	os="debian"
	major_ver=`cat /etc/debian_version | cut -c1`;
	
	# debian 7
	if [ "$major_ver" == "6" ]; then
		os_version=6;
	elif [ "$major_ver" == "7" ]; then
		os_version=7;
	elif [ "$major_ver" == "8" ]; then
		os_version=8;
	elif [ "$major_ver" == "9" ]; then
		os_version=9;
	fi
fi

if [ -z os ] || [ -z os_version ]; then
	echo "ERROR: Unsupported system detected.";
	exit 1
fi

# Determine the last tagged release
#current_tag=$(git tag | grep "^$RELEASE_TAG_PREFIX" | sort -n -t. -k 3 | tail -n 1);
#current_tag_numeric=$(echo $current_tag | cut -b${#RELEASE_TAG_PREFIX} --complement);

#if [ -z current_tag ]; then
#	echo "ERROR: Could not detect the last tagged release.";
#	exit 2
#fi

# Verify that build configuration is up to date with last tagged release
#if [ "$(grep $current_tag_numeric CHANGELOG)" == "" ]; then
#	echo "ERROR: Last tagged release [${current_tag_numeric}] not found in CHANGELOG file.";
#	exit 2
#fi

#if [ "$(grep $current_tag_numeric pbspro.build/changelog)" == "" ]; then
#	echo "ERROR: Last tagged release [${current_tag_numeric}] not found in debian changelog";
#	exit 2
#fi

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
fi

ln -s ${BUILDDIR} debian
DEB_BUILD_OPTIONS="nostrip noopt" fakeroot ./debian/rules clean
DEB_BUILD_OPTIONS="nostrip noopt" fakeroot ./debian/rules binary


exit 0
