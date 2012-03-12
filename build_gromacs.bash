#!/bin/bash
#  Download and install gromacs

VERSION=4.5.4
ARCHIVE_EXT=.tar.gz
TARGET_DIR=gromacs-${VERSION}
ARCHIVE=${TARGET_DIR}${ARCHIVE_EXT}
ARCHIVE_LOCATION=ftp://ftp.gromacs.org/pub/gromacs/${ARCHIVE}

BUILD_TAG=gromacs${VERSION}
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


if [ `hostname` == "biou1.rice.edu" ] || [ `hostname` == "biou2.rice.edu" ]; then
    echo "${TAG} Using options specific to biou."
    config_options="CC=xlc CXX=xlc++ F77=xlf FC=xlf90 --disable-shared --enable-static"
else
    config_options=""
fi



CONFIGURE_OUT=configure.out
echo "${TAG} Configuring >& ${CONFIGURE_OUT}"
# For some reason I have to configure twice to get readline working
./configure ${config_options} --prefix=${LOCAL_DIR} >& ${CONFIGURE_OUT}
if [ $? != 0 ]; then
    tail ${CONFIGURE_OUT}
    echo "${TAG} Failed to configure ${BUILD_TAG} (check ${CONFIGURE_OUT})"
    echo "${TAG} Failed to configure ${BUILD_TAG} retrying with --with-fft=fftpack"

    ./configure ${config_options} --prefix=${LOCAL_DIR} --with-fft=fftpack >& ${CONFIGURE_OUT}

    if [ $? != 0 ]; then
    	tail ${CONFIGURE_OUT}
    	echo "${TAG} Failed to configure ${BUILD_TAG} even with fftpack. (check ${CONFIGURE_OUT})"
    	exit 3
    fi

fi

BUILD_OUT=make.out
echo "${TAG} Building >& ${BUILD_OUT}"
make >& ${BUILD_OUT}
if [ $? != 0 ]; then
    tail ${BUILD_OUT}
    echo "${TAG} Failed to build or ${BUILD_TAG} (check ${BUILD_OUT})"
    exit 3
fi


INSTALL_OUT=make_install.out
echo "${TAG} Installing >& ${INSTALL_OUT}"
make install >& ${INSTALL_OUT}
if [ $? != 0 ]; then
    tail ${INSTALL_OUT}
    echo "${TAG} Failed to install ${BUILD_TAG} (check ${INSTALL_OUT})"
    exit 3
fi

echo "${TAG} Success."

