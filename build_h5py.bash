#!/bin/bash
#  Download and install h5py


BUILD_TAG=h5py
VERSION=2.0.1
ARCHIVE_EXT=.tar.gz
TARFLAG=z
ARCHIVE=${BUILD_TAG}-${VERSION}${ARCHIVE_EXT}
TARGET_DIR=`basename ${ARCHIVE} ${ARCHIVE_EXT}`
MIRROR=cdnetworks-us-1
ARCHIVE_LOCATION=http://h5py.googlecode.com/files/${ARCHIVE}


LOCAL_DIR=${HOME}/local
mkdir -p ${LOCAL_DIR}
BUILD_DIR=${HOME}/build_${BUILD_TAG}
TAG="BUILD${BUILD_TAG} -- "

if [ ! -e  ${LOCAL_DIR}/lib/libhdf5.a ]; then
    echo "${TAG} hdf5 does not appear to be installed."
    exit 1
fi

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

CONFIGURE_OUT=setup.out
echo "${TAG} Configuring and building >& ${CONFIGURE_OUT}"
python setup.py build --hdf5=${LOCAL_DIR} >& ${CONFIGURE_OUT}
if [ $? != 0 ]; then
    tail ${CONFIGURE_OUT}
    echo "${TAG} Failed to configure or install ${BUILD_TAG}(check ${CONFIGURE_OUT})"
    exit 3
fi

INSTALL_OUT=install.out
echo "${TAG} Installing >& ${INSTALL_OUT}"
python setup.py install
if [ $? != 0 ]; then
    tail ${INSTALL_OUT}
    echo "${TAG} Failed to install ${BUILD_TAG}(check ${INSTALL_OUT})"
    exit 3
fi

echo "${TAG} Successfully installed ${BUILD_TAG}."