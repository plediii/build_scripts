#!/bin/bash
#  Download and install glasgow haskell compiler


BUILD_TAG=ghc
VERSION=7.6.2
ARCHIVE_EXT=.tar.bz2
TARGET_DIR=${BUILD_TAG}-${VERSION}
ARCHIVE=ghc-${VERSION}-x86_64-unknown-linux${ARCHIVE_EXT}
#ARCHIVE_LOCATION=http://www.hdfgroup.org/ftp/HDF5/current/src/${ARCHIVE}
ARCHIVE_LOCATION=http://www.haskell.org/ghc/dist/${VERSION}/${ARCHIVE}


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
    echo "${TAG} Extracting ${BUILD_TAG} in " `pwd`
    tar -xjf ${ARCHIVE}
fi
if [ ! -d ${TARGET_DIR} ]; then
    echo "${TAG} Failed to extract ${ARCHIVE}."
    exit 1
fi

cd ${TARGET_DIR}

mkdir -p ${LOCAL_DIR}

pwd

CONFIGURE_OUT=configure.out
echo "${TAG} Configuring >& ${CONFIGURE_OUT}"
# For some reason I have to configure twice to get readline working
./configure --prefix=${LOCAL_DIR} >& ${CONFIGURE_OUT}
if [ $? != 0 ]; then
    tail ${CONFIGURE_OUT}
    echo "${TAG} Failed to configure ${BUILD_TAG} (check ${CONFIGURE_OUT})"
fi

# BUILD_OUT=make.out
# echo "${TAG} Building >& ${BUILD_OUT}"
# make >& ${BUILD_OUT}
# if [ $? != 0 ]; then
#     tail ${BUILD_OUT}
#     echo "${TAG} Failed to build or ${BUILD_TAG} (check ${BUILD_OUT})"
#     exit 3
# fi


INSTALL_OUT=make_install.out
echo "${TAG} Building/Installing >& ${INSTALL_OUT}"
make install >& ${INSTALL_OUT}
if [ $? != 0 ]; then
    tail ${INSTALL_OUT}
    echo "${TAG} Failed to install ${BUILD_TAG} (check ${INSTALL_OUT})"
    exit 3
fi

echo "${TAG} Success."

