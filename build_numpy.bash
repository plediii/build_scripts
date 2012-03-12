#!/bin/bash
# Build and install numpy for python

# NOTE: to fix ifort issue, edit __init__.py in numpy/distutils/fcompiler, and fix get_version to return the ifort version string.

VERSION=1.6.1
ARCHIVE_EXT=.tar.gz
TARFLAG=z
ARCHIVE=numpy-${VERSION}${ARCHIVE_EXT}
TARGET_DIR=`basename ${ARCHIVE} ${ARCHIVE_EXT}`
MIRROR=iweb
ARCHIVE_LOCATION='http://downloads.sourceforge.net/project/numpy/NumPy/'${VERSION}'/'${ARCHIVE}"?"'use_mirror='${MIRROR}
BUILD_TAG=numpy

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

echo "${TAG} Downloading ${BUILD_TAG} version ${VERSION} in ${BUILD_DIR}"
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


cat <<EOF > intel_hack.patch
--- numpy/distutils/fcompiler/__init__.py.orig	2012-02-17 13:18:10.174853909 -0600
+++ numpy/distutils/fcompiler/__init__.py	2012-02-17 13:19:32.585780095 -0600
@@ -423,10 +423,7 @@
 
     def get_version(self, force=False, ok_status=[0]):
         assert self._is_customised
-        version = CCompiler.get_version(self, force=force, ok_status=ok_status)
-        if version is None:
-            raise CompilerNotFound()
-        return version
+        return "12.0.4" # this may not actually be the version, but it gets past the distutils machinery
 
     ############################################################
EOF

mkdir -p ${LOCAL_DIR}

if [ "x$FC" == "x" ]; then 
    echo "${TAG} Looking for fortran compiler..."
    if [ `which ifort` >& /dev/null ]; then
	echo "${TAG} Using ifort"
	if [ `which ifort | grep fce` ] || [ `which ifort | grep 64` ]; then
	    FC=intelem
	else
	    FC=intel
	fi

	patch -Nb numpy/distutils/fcompiler/__init__.py intel_hack.patch
    # xlf is failing to work on biou without serious patching by me.
    # elif [ `which xlf` >& /dev/null ]; then 
    # 	echo "${TAG} Using XLF."
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
echo python setup.py config_fc --fcompiler="${FC}" install
python setup.py config_fc --fcompiler="${FC}" install >& ${CONFIGURE_OUT}
if [ $? != 0 ]; then
    tail ${CONFIGURE_OUT}
    echo "${TAG} Failed to configure or install ${BUILD_TAG}(check ${CONFIGURE_OUT})"
    exit 3
fi

# Testing needs to be performed in any other directory, and also we need the nose library
# mkdir -p temp
# cd temp
# TEST_OUT=test.out
# echo "${TAG} Testing ${BUILD_TAG} >& ${TEST_OUT}"
# rm -f ${TEST_OUT}
# python -c 'import numpy; numpy.test()' >& ${TEST_OUT}
# if [ ! `grep OK ${TEST_OUT}` ]; then
#     echo "${TAG} numpy test failed.  check tmp/${TEST_OUT}"
#     exit 1
# fi

echo "${TAG} Success."


