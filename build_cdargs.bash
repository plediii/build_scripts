#!/bin/bash
# Download and install cdargs utility for bash.

CDARGS_VER=1.35
CDARGS_DIR=cdargs-${CDARGS_VER}
CDARGS_TGZ=${CDARGS_DIR}.tar.gz
LOCAL_DIR=${HOME}/local
BUILD_DIR=${HOME}/build_cdargs
TAG="BUILDCDARGS -- "
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

echo "${TAG} Downloading cdargs."
if [ ! -e ${CDARGS_TGZ} ]; then
    wget http://www.skamphausen.de/downloads/cdargs/${CDARGS_TGZ}
fi
if [ ! -e ${CDARGS_TGZ} ]; then
    echo "${TAG} Could not download ${CDARGS_TGZ}."
    exit 1
fi
echo "${TAG} Extracting cdargs."
tar -xzf ${CDARGS_TGZ}
echo "${TAG} Building cdargs"
cd ${CDARGS_DIR}
CONFIGURE_OUT=configure.out
echo "${TAG} ./configure >& ${CONFIGURE_OUT}"
./configure --prefix=${LOCAL_DIR} >& ${CONFIGURE_OUT} 
MAKE_OUT=make.out
echo "${TAG} make >& ${MAKE_OUT}"
make >& make.out
MAKE_INSTALL_OUT=make_install.out
echo "${TAG} make install >& ${MAKE_install_OUT}"
make install-strip >& ${MAKE_INSTALL_OUT}

if [ ! -e ${LOCAL_DIR}/bin/cdargs ]; then
    echo "Failed to build or install cdargs."
    exit 1
fi

echo "${TAG} Installing contrib."
cd contrib
cp -v cdargs-bash.sh ${LOCAL_DIR}/bin

SITE_LISP_DIR=${LOCAL_DIR}/share/emacs/site-lisp
if [ -d  ${SITE_LISP_DIR} ]; then
    cp -v cdargs.el ${SITE_LISP_DIR}
else
    echo "${TAG} cdargs.el was not installed because I don't know where to put it."
fi

echo "${TAG} cdargs successfully installed."





