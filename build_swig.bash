
#!/bin/bash
# Download and install swig



VERSION=2.0.3
ARCHIVE=swig-${VERSION}.tar.gz
ARCHIVE_EXT=.tar.gz
TARGET_DIR=`basename ${ARCHIVE} ${ARCHIVE_EXT}`
ARCHIVE_LOCATION=http://prdownloads.sourceforge.net/swig/${ARCHIVE}

BUILD_TAG=swig${VERSION}
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

CONFIGURE_OUT=configure.out
echo "${TAG} Configuring >& ${CONFIGURE_OUT}"
./configure --prefix=${LOCAL_DIR} >& ${CONFIGURE_OUT}

if [ $? != 0 ];  then
    
    echo "${TAG} Need PCRE, building..."

    PCRE_ARCHIVE=pcre-8.12.tar.gz
    if [ ! -e ${PCRE_ARCHIVE} ]; then
	wget  ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${PCRE_ARCHIVE}
    fi

    Tools/pcre-build.sh --prefix=${LOCAL_DIR}
    if [ $? != 0 ];  then
	echo "${TAG} Unable to build PCRE"
	exit 1
    fi

    ./configure --prefix=${LOCAL_DIR} >& ${CONFIGURE_OUT}
    if [ $? != 0 ];  then
	echo "${TAG} Still unable to configure."
	exit 1
    fi


fi

BUILD_OUT=make.out
echo "${TAG} make  >& ${BUILD_OUT}"
make  >& ${BUILD_OUT}
if [ $? != 0 ]; then
    tail ${BUILD_OUT}
    echo "${TAG} Failed to build ${BUILD_TAG} (check ${BUILD_OUT})"
    # exit 3
fi

INSTALL_OUT=install.out
echo "${TAG} make install >& ${INSTALL_OUT}"
make install >& ${INSTALL_OUT}
if [ $? != 0 ]; then
    tail ${INSTALL_OUT}
    echo "${TAG} Failed to build ${INSTALL_TAG} (check ${INSTALL_OUT})"
    # exit 3
fi

echo "${TAG} Success."


