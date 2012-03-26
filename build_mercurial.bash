#!/bin/bash
# Download and install mercurial

VERSION=2.1.1
ARCHIVE=mercurial-${VERSION}.tar.gz
ARCHIVE_EXT=.tar.gz
TARGET_DIR=`basename ${ARCHIVE} ${ARCHIVE_EXT}`
ARCHIVE_LOCATION=http://mercurial.selenic.com/release/${ARCHIVE}

BUILD_TAG=mercurial${VERSION}
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
echo "${TAG} Building..."
HOME=${LOCAL_DIR} make >& ${BUILD_OUT}
if [ $? != 0 ]; then
    tail ${BUILD_OUT}
    echo "${TAG} Failed to build ${BUILD_TAG} (check ${BUILD_OUT})"
    # exit 3
fi

INSTALL_OUT=install.out
echo "${TAG} make install >& ${INSTALL_OUT}"
HOME=${LOCAL_DIR} make install-home >& ${INSTALL_OUT}
if [ $? != 0 ]; then
    tail ${INSTALL_OUT}
    echo "${TAG} Failed to build ${INSTALL_TAG} (check ${INSTALL_OUT})"
    # exit 3
fi

TEST_OUT=test.out
echo "${TAG} hg debuginstall >& ${TEST_OUT}"
hg debuginstall >& ${TEST_OUT}

# Can't detect an installation error from here since it claims not setting a user name is an error.

# if [ $? != 0 ]; then
#     tail ${TEST_OUT}
#     echo "${TAG} Failed to build ${BUILD_TAG} (check ${TEST_OUT})"
#     exit 3
# fi

hg

if [ $? != 0 ]; then
    echo "${TAG} Failed to execute mercurial."
    exit 4
fi

echo "${TAG} Success."

