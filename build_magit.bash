#!/bin/bash
# Download and install magit

NAME=magit
VERSION=1.2.0
ARCHIVE_EXT=.tar.gz
ARCHIVE=${NAME}-${VERSION}${ARCHIVE_EXT}
TARGET_DIR=`basename ${ARCHIVE} ${ARCHIVE_EXT}`
ARCHIVE_LOCATION=https://github.com/downloads/magit/magit/${ARCHIVE}

EMACSPLUGINS=${HOME}/.emacs.d/plug-ins

BUILD_TAG=${NAME}${VERSION}
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

BUILD_OUT=make.out
echo "${TAG} Building >& ${BUILD_OUT}"
if [ $? != 0 ]; then
    tail ${BUILD_OUT}
    echo "${TAG} Failed to build ${BUILD_TAG} (check ${BUILD_OUT})"
    exit 3
fi

INSTALL_OUT=make_install.out
echo "${TAG} Installing >& ${INSTALL_OUT}"
install *.el ${EMACSPLUGINS}

echo "${TAG} Success."

