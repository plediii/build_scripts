#!/bin/bash
# Download and install golang

REPO=go
TARGET_DIR=${REPO}
REPO_LOCATION=https://go.googlecode.com/hg/

BUILD_TAG=golang
LOCAL_DIR=${HOME}/local
mkdir -p ${LOCAL_DIR}
BUILD_DIR=${HOME}/build_${BUILD_TAG}
TAG="BUILD${BUILD_TAG} -- "
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

hg &> /dev/null
if [ $? != 0 ]; then
    echo "${TAG} Mercurial is required but not installed."
    exit 1
fi

if [ ! -d ${TARGET_DIR} ]; then
    echo "${TAG} Cloning ${BUILD_TAG} in " `pwd`
    hg clone -u release ${REPO_LOCATION} ${REPO}
    if [ ! -e ${TARGET_DIR} ]; then
	echo "${TAG} Failed to clone from ${REPO_LOCATION}."
	exit 1
    fi
fi

mkdir -p ${LOCAL_DIR}

cp -r ${TARGET_DIR} ${LOCAL_DIR}

export GOROOT=${LOCAL_DIR}/${REPO}

cd ${GOROOT}/src

ALL_OUT=all.out
echo "${TAG} Building and testing... >& ${ALL_OUT}"
./all.bash >& ${ALL_OUT}


if [ $? != 0 ]; then
    tail ${ALL_OUT}
    echo "${TAG} Failed to install ${BUILD_TAG}."
    exit 3
fi
tail ${ALL_OUT}

echo "${TAG} Success."
