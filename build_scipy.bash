#!/bin/bash
#  Download and install scipy for python


VERSION=0.10.0
ARCHIVE_EXT=.tar.gz
TARFLAG=z
ARCHIVE=scipy-${VERSION}${ARCHIVE_EXT}
TARGET_DIR=`basename ${ARCHIVE} ${ARCHIVE_EXT}`
MIRROR=cdnetworks-us-1
ARCHIVE_LOCATION='http://downloads.sourceforge.net/project/scipy/scipy/'${VERSION}'/'${ARCHIVE}"?"'use_mirror='${MIRROR}
BUILD_TAG=scipy

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

if [ "x$FC" == "x" ]; then 
    echo "${TAG} Looking for fortran compiler..."
    if [ `which ifort` ]; then
	echo "${TAG} Using ifort"
	if [ `which ifort | grep fce` ] || [ `which ifort | grep 64` ]; then
	    FC=intelem
	else
	    FC=intel
	fi
    # xlf is failing to work on biou.  I haven't been able to patch it yet.
    # elif [ `which xlf` ]; then
    # 	echo "${TAG} Using XL Fortran"
    # 	FC=ibm
    else
	if [ ! `which gfortran` ]; then
	    echo "${TAG} Failed to find ifort or gfortran."
	    exit 1
	fi
	echo "${TAG} Using gfortran"
	FC=gfortran
    fi
fi
echo "${TAG} using --fcompiler=${FC}"
CONFIGURE_OUT=setup.out
echo "${TAG} Configuring and building >& ${CONFIGURE_OUT}"
echo python setup.py config_fc --fcompiler=${FC} install
python setup.py config_fc --fcompiler=${FC} install >& ${CONFIGURE_OUT}
if [ $? != 0 ]; then
    tail ${CONFIGURE_OUT}
    echo "${TAG} Failed to configure or install ${BUILD_TAG}(check ${CONFIGURE_OUT})"
    exit 3
fi

TEST_OUT=test.out
echo "${TAG} Testing ${BUILD_TAG} >& ${TEST_OUT}"
rm -f ${TEST_OUT}
python -c 'import numpy; numpy.test()' >& ${TEST_OUT}
if [ ! `grep OK ${TEST_OUT}` ]; then
    echo "${TAG} numpy test failed.  check ${TEST_OUT}"
fi

echo "${TAG} Successfully installed ${BUILD_TAG}."