#!/bin/bash
#  Download and install python setuptools


BUILD_TAG=setuptools
VERSION=0.6c11
PYVER=2.7
# ARCHIVE_EXT=.tar.gz
# TARFLAG=z
ARCHIVE=setuptools-${VERSION}-py${PYVER}.egg
TARGET_DIR=`basename ${ARCHIVE} ${ARCHIVE_EXT}`

ARCHIVE_LOCATION=http://pypi.python.org/packages/${PYVER}/${BUILD_TAG:0:1}/${BUILD_TAG}/${ARCHIVE}

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

echo "${TAG} Downloading ${BUILD_TAG}"
[ ! -e ${ARCHIVE} ] && wget ${ARCHIVE_LOCATION}
if [ ! -e ${ARCHIVE} ]; then
    echo "${TAG} Unable to download ${ARCHIVE} from ${ARCHIVE_LOCATION}"
    exit 1
fi
    # tar -x${TARFLAG}f ${ARCHIVE} 

# if [ ! -d ${TARGET_DIR} ]; then
#     echo "${TAG} Failed to extract ${ARCHIVE}"
#     exit 2
# fi

cd ${TARGET_DIR}

echo "${TAG} Building ${BUILD_TAG} in ${BUILD_DIR}"

mkdir -p ${LOCAL_DIR}

INSTALL_OUT=setup.out
echo "${TAG} Installing ${ARCHIVE} >& ${INSTALL_OUT}"
sh ${ARCHIVE} --prefix=${LOCAL_DIR}
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