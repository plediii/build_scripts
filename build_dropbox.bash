#!/bin/bash
# download dropbox app and CLI script

VERSION=
ARCHIVE_EXT=.tgz
TARGET_DIR=.dropbox-dist
ARCHIVE=${TARGET_DIR}-${VERSION}${ARCHIVE_EXT}
ARCHIVE_LOCATION=http://dropbox.com/download?plat=lnx.x86_64
BUILD_TAG=dropbox

LOCAL_DIR=${HOME}/local
mkdir -p ${LOCAL_DIR}
BUILD_DIR=${HOME}/build_${BUILD_TAG}
TAG="BUILD${BUILD_TAG} -- "
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}


if [ ! `which python` ]; then
    echo "${TAG} python is not in PATH."
    exit 1
fi

echo "${TAG} Downloading ${BUILD_TAG} version ${VERSION} in ${BUILD_DIR}"
if [ ! -d ${TARGET_DIR} ]; then
    echo "${TAG} Downloading ${BUILD_TAG}"
    wget -c -O ${ARCHIVE} ${ARCHIVE_LOCATION}
    if [ ! -e ${ARCHIVE} ]; then
	echo "${TAG} Unable to download ${ARCHIVE} from ${ARCHIVE_LOCATION}"
	exit 2
    fi
    tar -xzf ${ARCHIVE}
    if [ $? != 0]; then
	echo "${TAG} Failed to extract archive."
	exit 3
    fi 
fi
if [ ! -d ${TARGET_DIR} ]; then
    echo "${TAG} Failed to extract ${ARCHIVE}"
    exit 4
fi

wget -c -O dropbox.py https://www.dropbox.com/download?dl=packages/dropbox.py


mkdir -p ${LOCAL_DIR}/bin
chmod +x dropbox.py

mv dropbox.py ${LOCAL_DIR}/bin

cp -r ${TARGET_DIR} ${HOME}

echo "${TAG} Execute ${HOME}/${TARGET_DIR}/dropboxd to start."

