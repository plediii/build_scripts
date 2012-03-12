#!/bin/bash
#  Download and install emacs

VERSION=23.3a
ARCHIVE_EXT=a.tar.gz   # use basname with this to obtain the name of the directory we expect to see extracted
ARCHIVE=emacs-${VERSION}.tar.gz
ARCHIVE_LOCATION=http://ftp.gnu.org/pub/gnu/emacs/${ARCHIVE}
TARGET_DIR=`basename ${ARCHIVE} ${ARCHIVE_EXT}`

BUILD_TAG=emacs${VERSION}
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

echo "${TAG} Downloading and installing ${BUILD_TAG} in ${LOCAL_DIR}"

configure_cmd="./configure --prefix=${LOCAL_DIR} --without-makeinfo"
if [ `uname` == "Darwin" ]; then
    configure_cmd="./configure --with-ns"
fi

CONFIGURE_OUT=configure.out
echo "${TAG} Configuring >& ${CONFIGURE_OUT}"
${configure_cmd} >& ${CONFIGURE_OUT}
if [ $? != 0 ]; then
    add_opt=`tail -n 2 ${CONFIGURE_OUT} | head -n 1`
    echo "${TAG} Failed to configure.  Retrying with ${add_opt}."
    ${configure_cmd} ${add_opt} >& ${CONFIGURE_OUT}
    if [ $? != 0 ]; then
	echo "${TAG} Failed to configure."
	exit
    fi 
fi
BOOTSTRAP_OUT=bootstrap.out
echo "${TAG} make bootstrap >& ${BOOTSTRAP_OUT}"
make bootstrap >& ${BOOTSTRAP_OUT}
BUILD_OUT=make.out
echo "${TAG} Building >& ${BUILD_OUT}"
make >& ${BUILD_OUT}
if [ $? != 0 ]; then
    echo "${TAG} Failed to build:"
    tail ${BUILD_OUT}
    exit
fi 
INSTALL_OUT=make_install.out
echo "${TAG} Installing >& ${INSTALL_OUT}"
make install >& ${INSTALL_OUT}
if [ $? != 0 ]; then
    echo "${TAG} Failed to install:"
    tail ${INSTALL_OUT}
    exit
fi 

if [ `uname` == "Darwin" ]; then
    echo "Follow this with: sudo cp -r BUILD_DIR=${HOME}/build_${BUILD_TAG}/emacs/nextstep/Emacs.app /Applications/Emacs.app
"
fi