#!/bin/bash
#  Download and install openssl development lib

VERSION=1.0.0c
ARCHIVE_EXT=.tar.gz
ARCHIVE=openssl-${VERSION}${ARCHIVE_EXT}
TARGET_DIR=`basename ${ARCHIVE} ${ARCHIVE_EXT}`
ARCHIVE_LOCATION=http://www.openssl.org/source/${ARCHIVE}

BUILD_TAG=openssl${VERSION}
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

# For some reason I have to configure twice to get readline working
CONFIGURE_OUT=configure.out
./config --prefix=${LOCAL_DIR} -fPIC >& ${CONFIGURE_OUT}
if [ $? != 0 ]; then
    tail ${CONFIGURE_OUT}
    echo "${TAG} Failed to configure ${BUILD_TAG} (check ${CONFIGURE_OUT})"
    exit 3
fi

BUILD_OUT=make.out
echo "${TAG} Building >& ${BUILD_OUT}"
make >& ${BUILD_OUT}
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

