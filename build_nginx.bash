#!/bin/bash
#  Download and install nginx


BUILD_TAG=nginx
VERSION=1.8.0
ARCHIVE_EXT=.tar.gz
ARCHIVE=${BUILD_TAG}-${VERSION}${ARCHIVE_EXT}
TARGET_DIR=`basename ${ARCHIVE} ${ARCHIVE_EXT}`
ARCHIVE_LOCATION=http://nginx.org/download/${ARCHIVE}

LOCAL_DIR=${HOME}/local/nginx
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

CONFIGURE_OUT=configure.out
echo "${TAG} ./configure >& ${CONFIGURE_OUT}"
./configure --prefix=${LOCAL_DIR} --user=www-data --group=www-data --with-http_ssl_module --with-http_realip_module  --with-http_gzip_static_module --with-http_secure_link_module --with-http_degradation_module --with-http_sub_module --with-http_mp4_module  --with-http_stub_status_module  --with-http_random_index_module   --with-http_addition_module  >& ${CONFIGURE_OUT} 

mkdir -p ${LOCAL_DIR}

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
make PREFIX=${LOCAL_DIR} install
if [ $? != 0 ]; then
    tail ${INSTALL_OUT}
    echo "${TAG} Failed to install ${BUILD_TAG} (check ${INSTALL_OUT})"
    exit 3
fi

echo "${TAG} Success."

