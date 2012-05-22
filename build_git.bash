#!/bin/bash
# Download and install git

VERSION=1.7.10.2
ARCHIVE_EXT=.tar.gz
ARCHIVE=git-${VERSION}${ARCHIVE_EXT}
TARGET_DIR=`basename ${ARCHIVE} ${ARCHIVE_EXT}`
ARCHIVE_LOCATION=http://git-core.googlecode.com/files/${ARCHIVE}

BUILD_TAG=git${VERSION}
LOCAL_DIR=${HOME}/local
mkdir -p ${LOCAL_DIR}
BUILD_DIR=${HOME}/build_${BUILD_TAG}
TAG="BUILD${BUILD_TAG} -- "
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}


if [ ! -d ${TARGET_DIR} ]; then
    echo "${TAG} Downloading ${BUILD_TAG} in " `pwd`
    wget -c ${ARCHIVE_LOCATION}
    if [ ! -e ${ARCHIVE} ]; then
	echo "${TAG} Failed to download from ${ARCHIVE_LOCATION}."
	exit 1
    fi
    tar -xzf ${ARCHIVE}
fi
if [ ! -d ${TARGET_DIR} ]; then
    echo "${TAG} Failed to extract ${ARCHIVE}."
    exit 1
fi

cd ${TARGET_DIR}

mkdir -p ${LOCAL_DIR}

# Maybe add set the 64 bit option by sed'ing the Makefile

CONFIGURE_OUT=configure.out
echo "${TAG} Configuring >& ${CONFIGURE_OUT}"

# I have to set libcurl's prefix manually.  This isn't always the
# right location.  It should be configure's job to find it.  What's
# wrong?
CC=gcc ./configure --prefix=${LOCAL_DIR} --with-curl=/usr/lib64 >& ${CONFIGURE_OUT}
if [ $? != 0 ]; then
    tail ${CONFIGURE_OUT}
    echo "${TAG} Failed to configure ${BUILD_TAG} (check ${CONFIGURE_OUT})"
    exit 3
fi

BUILD_OUT=make.out
echo "${TAG} Building >& ${BUILD_OUT}"
if [ $? != 0 ]; then
    tail ${BUILD_OUT}
    echo "${TAG} Failed to build ${BUILD_TAG} (check ${BUILD_OUT})"
    exit 3
fi


INSTALL_OUT=make_install.out
echo "${TAG} Installing >& ${INSTALL_OUT}"
make install >& ${INSTALL_OUT}
if [ $? != 0 ]; then
    tail ${INSTALL_OUT}
    echo "${TAG} Failed to install ${BUILD_TAG} (check ${INSTALL_OUT})"
    exit 3
fi

echo "${TAG} Success."

