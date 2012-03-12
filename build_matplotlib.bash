#!/bin/bash
# Download and install arpack++

TAG_NAME=matplotlib
TAR_DIR=${TAG_NAME}
VERSION=1.1.0
TGZ=${TAR_DIR}-${VERSION}.tar.gz
LOCATION='http://downloads.sourceforge.net/project/matplotlib/matplotlib/matplotlib-'${VERSION}'/'${TGZ}"?"'use_mirror=voxel'
TAR_DIR=${TAG_NAME}-${VERSION}

LOCAL_DIR=${HOME}/local
BUILD_DIR=${HOME}/build_${TAG_NAME}
TAG="BUILD"${TAG_NAME}" -- "

mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

echo "${TAG} Downloading..."
if [ ! -e ${TGZ} ]; then
    wget ${LOCATION}
fi
if [ ! -e ${TGZ} ]; then
    echo "${TAG} Could not download ${TGZ}."
    exit 1
fi

if [ ! -e ${TAR_DIR} ]; then
    echo "${TAG} Extracting..."
    tar -xzf ${TGZ}
else 
    echo "${TAG} Already extracted."
fi

if [ ! -e ${TAR_DIR} ]; then
    echo "${TAG} Expected directory does not exist after extraction: ${TAR_DIR}"
    exit 1
fi

cd ${TAR_DIR}

BUILD_OUT=build.out
echo "${TAG} python setup.py build >& ${BUILD_OUT}..."
python setup.py build >& ${BUILD_OUT}

if [ $? != 0 ]; then
    tail ${BUILD_OUT}
    echo "${TAG} Failed."
    exit 1
fi

tail ${BUILD_OUT}

INSTALL_OUT=install.out
echo "${TAG} python setup.py install >& ${INSTALL_OUT}..."
python setup.py install >& ${INSTALL_OUT}

if [ $? != 0 ]; then
    tail ${INSTALL_OUT}
    echo "${TAG} Failed."
    exit 1
fi

tail ${INSTALL_OUT}

echo "${TAG} Done."


