#!/bin/bash
#  Download and install h5py


BUILD_TAG=Cython
VERSION=0.15.1
ARCHIVE_EXT=.tar.gz
TARFLAG=z
ARCHIVE=${BUILD_TAG}-${VERSION}${ARCHIVE_EXT}
TARGET_DIR=`basename ${ARCHIVE} ${ARCHIVE_EXT}`
MIRROR=cdnetworks-us-1
ARCHIVE_LOCATION=http://cython.org/release/${ARCHIVE}


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

echo "${TAG} Downloading ${BUILD_TAG} in ${BUILD_DIR}"
if [ ! -d ${TARGET_DIR} ]; then
    echo "${TAG} Downloading ${BUILD_TAG}"
    [ ! -e ${ARCHIVE} ] && wget ${ARCHIVE_LOCATION}
    if [ ! -e ${ARCHIVE} ]; then
	echo "${TAG} Unable to download ${ARCHIVE} from ${ARCHIVE_LOCATION}"
	exit 1
    fi
    tar -x${TARFLAG}f ${ARCHIVE} 
fi
if [ ! -d ${TARGET_DIR} ]; then
    echo "${TAG} Failed to extract ${ARCHIVE}"
    exit 2
fi

cd ${TARGET_DIR}

echo "${TAG} Building ${BUILD_TAG} in ${BUILD_DIR}"

mkdir -p ${LOCAL_DIR}

INSTALL_OUT=setup.out
echo "${TAG} Configuring and building >& ${INSTALL_OUT}"
python setup.py install >& ${INSTALL_OUT}
if [ $? != 0 ]; then
    tail ${INSTALL_OUT}
    echo "${TAG} Failed to configure or install ${BUILD_TAG}(check ${INSTALL_OUT})"
    exit 3
fi

# INSTALL_OUT=install.out
# echo "${TAG} Installing >& ${INSTALL_OUT}"
# python setup.py install
# if [ $? != 0 ]; then
#     tail ${INSTALL_OUT}
#     echo "${TAG} Failed to install ${BUILD_TAG}(check ${INSTALL_OUT})"
#     exit 3
# fi
# 
echo "${TAG} Successfully installed ${BUILD_TAG}."