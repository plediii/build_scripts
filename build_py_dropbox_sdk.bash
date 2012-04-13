#!/bin/bash
# dwonload python SDK for python

VERSION=1.4
ARCHIVE_EXT=.zip
TARGET_DIR=dropbox-python-sdk
ARCHIVE=${TARGET_DIR}-${VERSION}${ARCHIVE_EXT}
ARCHIVE_LOCATION=http://dropbox.com/static/developers/${ARCHIVE}
BUILD_TAG=pydropsdk

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
    [ ! -e ${ARCHIVE} ] && wget ${ARCHIVE_LOCATION}
    if [ ! -e ${ARCHIVE} ]; then
	echo "${TAG} Unable to download ${ARCHIVE} from ${ARCHIVE_LOCATION}"
	exit 2
    fi
    unzip ${ARCHIVE} 
    if [ $? != 0]; then
	echo "${TAG} Failed to extract archive."
	exit 3
    fi 
fi
if [ ! -d ${TARGET_DIR} ]; then
    echo "${TAG} Failed to extract ${ARCHIVE}"
    exit 4
fi

echo "${TAG} Downloaded to ${TARGET_DIR}."