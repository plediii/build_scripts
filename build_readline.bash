#!/bin/bash
#  Download and install GNU readline

VERSION=5.2
ARCHIVE_EXT=.tar.gz
ARCHIVE=readline-${VERSION}${ARCHIVE_EXT}
TARGET_DIR=`basename ${ARCHIVE} ${ARCHIVE_EXT}`
ARCHIVE_LOCATION=ftp://ftp.cwru.edu/pub/bash/${ARCHIVE}

BUILD_TAG=readline
LOCAL_DIR=${HOME}/local
mkdir -p ${LOCAL_DIR}
BUILD_DIR=${HOME}/build_${BUILD_TAG}
TAG="BUILD${BUILD_TAG} -- "
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

if [ ! -d ${TARGET_DIR} ]; then
    echo "${TAG} Downloading ${BUILD_TAG}"
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

echo "${TAG} Downloading and installing ${BUILD_TAG} in ${LOCAL_DIR}"

CONFIGURE_OUT=configure.out
echo "${TAG} Configuring >& ${CONFIGURE_OUT}"
./configure --prefix=${LOCAL_DIR} >& ${CONFIGURE_OUT}
BUILD_OUT=make.out
echo "${TAG} Building >& ${BUILD_OUT}"
make >& ${BUILD_OUT}
INSTALL_OUT=make_install.out
echo "${TAG} Installing >& ${INSTALL_OUT}"
make install >& ${INSTALL_OUT}
if [ `grep "Error 1" ${INSTALL_OUT} | wc -l` != `grep "Error 1 (ignored)" ${INSTALL_OUT} | wc -l` ]; then
    echo "${TAG} Installation failed."
    exit 1
fi

