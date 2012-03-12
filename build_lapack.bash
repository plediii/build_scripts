#!/bin/bash
#  Download and install hdf5



BUILD_TAG=lapack
VERSION=3.3.1
ARCHIVE_EXT=.tgz
TARGET_DIR=${BUILD_TAG}-${VERSION}
ARCHIVE=${TARGET_DIR}${ARCHIVE_EXT}
ARCHIVE_LOCATION=http://www.netlib.org/lapack/${ARCHIVE}


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

if [ ! -e Makefile.old ]; then
    cp Makefile Makefile.old
fi

sed=`which sed`

echo "${TAG} Configuring"
cat <<EOF > configure_Makefile.sed
# Created by $0.bash
s!lib: lapacklib tmglib!#lib: lapacklib tmglib!
s!#lib: blaslib variants lapacklib tmglib!lib: blaslib variants lapacklib tmglib!
EOF
sed -f configure_Makefile.sed < Makefile.old > Makefile


cat <<EOF > configure_make_inc.sed
# Created by $0.bash
s!OPTS     = -O3 !OPTS     = -O3 -fPIC !
s!NOOPT    = -O3 -fltconsistency -fp_port !NOOPT    = -O3 -fltconsistency -fp_port -fPIC!
EOF
sed -f configure_make_inc.sed < INSTALL/make.inc.ifort > make.inc

BUILD_OUT=make.out
echo "${TAG} Building >& ${BUILD_OUT}"
make >& ${BUILD_OUT}
if [ $? != 0 ]; then
    tail ${BUILD_OUT}
    echo "${TAG} Failed to build or ${BUILD_TAG} (check ${BUILD_OUT})"
    exit 3
fi


echo "${TAG} Installing >& ${INSTALL_OUT}"
cp -v lapack_LINUX.a ${LOCAL_DIR}/lib/liblapack.a
cp -v blas_LINUX.a ${LOCAL_DIR}/lib/libblas.a
# cp -v *.a ${LOCAL_DIR}/lib

echo "${TAG} Success."

