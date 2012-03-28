#!/bin/bash
# install google app engine SDK for python

VERSION=1.6.4
ARCHIVE_EXT=.zip
TARGET_DIR=google_appengine
ARCHIVE=${TARGET_DIR}_${VERSION}${ARCHIVE_EXT}
ARCHIVE_LOCATION=http://googleappengine.googlecode.com/files/${ARCHIVE}
BUILD_TAG=pygae

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
	exit 2
    fi
    unzip ${ARCHIVE} 
    if [ $? != 0]; then
	echo "${TAG} Failed to extract archive."
	exit 3
    fi 
fi
if [ ! -d ${TARGET_DIR} ]; then
    echo "${TAG} Failed to extract ${ARCHIVE}"
    exit 4
fi

INSTALL_DIR=${LOCAL_DIR}/${TARGET_DIR}

# make sure parent directories exist
mkdir -p ${INSTALL_DIR}
rmdir ${INSTALL_DIR} 		

if [ $? != 0]; then
    echo "${TAG} Unable to remove ${INSTALL_DIR}."
    exit 5
fi

mv -v ${TARGET_DIR} ${INSTALL_DIR}

cd ${INSTALL_DIR}

function link ()
{
    target=$1
    here=`pwd`
    exe=$2
    if [ ! -e ${exe} ]; then
	echo "${TAG} WARNING: ${exe}.py does not exist here... skipping it."
	continue
    fi
    if [ -e ${target}/${exe} ]; then
	echo "${TAG} REPLACING: ${target}/${exe}"
	rm ${target}/${exe}
	if [ -e ${target}/${exe} ]; then
	    echo "${TAG} FAILED to replace: ${target}/${exe}."
	fi
	ln -fs ${here}/${exe} ${target}/${exe}
    else
	echo "${TAG} LINKING ${target}/${exe}"
	ln -fs ${here}/${exe} ${target}/${exe}
    fi
}

BINDIR=${LOCAL_DIR}/bin
echo 
echo "${TAG} Linking exes to ${BINDIR}..."

exes="dev_appserver.py"
for exe in ${exes}; do
    link ${BINDIR} ${exe}
done

echo "${TAG} Success."


