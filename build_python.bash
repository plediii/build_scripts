#!/bin/bash
#  Download and install PYTHON

VERSION=2.7.2 # Once numpy is updated: 2.7 
ARCHIVE_EXT=.tgz
ARCHIVE=Python-${VERSION}${ARCHIVE_EXT}
TARGET_DIR=`basename ${ARCHIVE} ${ARCHIVE_EXT}`
ARCHIVE_LOCATION=http://www.python.org/ftp/python/${VERSION}/${ARCHIVE}

BUILD_TAG=python${VERSION}
LOCAL_DIR=${HOME}/local
mkdir -p ${LOCAL_DIR}
BUILD_DIR=${HOME}/build_${BUILD_TAG}
TAG="BUILD${BUILD_TAG} -- "
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

SQLITE_DIR=${HOME}/local/include
OPENSSL_DIR=${HOME}/local/include/

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

#TODO: If sqlite3 is in local/lib, add '$HOME/local/include' to sqlite_inc_paths list in setup.py
# Maybe add set the 64 bit option by sed'ing the Makefile


if [ -e ${SQLITE_DIR}/sqlite3.h ]; then

    echo "${TAG} Configuring setup.py for local sqlite3."
    if [ ! -e setup.py.old ]; then
	cp setup.py setup.py.old
    fi

    sed=`which sed`
    cat <<EOF > configure_sqlite.sed
#!${sed} -f
# Created by build-${TAG}.bash
s!        sqlite_inc_paths = \[ '/usr/include',!        sqlite_inc_paths = \[ '${SQLITE_DIR}' !
s!                             '/usr/include/sqlite',!!
s!                             '/usr/include/sqlite3',!!
s!                             '/usr/local/include',!!
s!                             '/usr/local/include/sqlite',!!
s!                             '/usr/local/include/sqlite3',!!
EOF

chmod +x configure_sqlite.sed
cp setup.py tmp_setup.py
./configure_sqlite.sed < tmp_setup.py > setup.py
else
    echo "${TAG} Local sqlite3 does not exist." 
fi

if [ -e ${OPENSSL_DIR}/openssl/ssl.h ]; then

    echo "${TAG} Configuring setup.py for local openssl."

    sed=`which sed`
    cat <<EOF > configure_openssl.sed
#!${sed} -f
# Created by build-${TAG}.bash
s!        search_for_ssl_incs_in = \[!        search_for_ssl_incs_in = \[ '${OPENSSL_DIR}' !
s!                              '/usr/local/ssl/include',!!
s!                              '/usr/contrib/ssl/include/'!!
s!                                     \['/usr/local/ssl/lib',!                                     \[ '${LOCAL_DIR}/lib64/',!
EOF

    cat <<EOF

EOF

chmod +x configure_openssl.sed
cp setup.py tmp_setup.py
./configure_openssl.sed < tmp_setup.py > setup.py
else
    echo "${TAG} Local openssl does not exist." 
fi


CONFIGURE_OUT=configure.out
echo "${TAG} Configuring >& ${CONFIGURE_OUT}"
if [[ `uname -m` == "ppc64" ]]; then
    CC="gcc -m64"
else
    CC="gcc"
fi
CC="gcc -m64"


# For some reason I have to configure twice to get readline working
./configure --prefix=${LOCAL_DIR} --with-readline=yes --enable-unicode >& ${CONFIGURE_OUT}
if [ $? != 0 ]; then
    tail ${CONFIGURE_OUT}
    echo "${TAG} Failed to configure ${BUILD_TAG} (check ${CONFIGURE_OUT})"
    exit 3
fi
if [ -e ${LOCAL_DIR}/lib/libreadline.a ]; then
    echo "${TAG} Using local readline installation."
    echo "readline readline.c -I${LOCAL_DIR}/include -L${LOCAL_DIR}/lib -lreadline -ltermcap" >> Modules/Setup.local
    ./configure --prefix=${LOCAL_DIR} --with-readline=yes >& ${CONFIGURE_OUT}
    if [ $? != 0 ]; then
	tail ${CONFIGURE_OUT}
	echo "${TAG} Failed to configure ${BUILD_TAG} with readline (check ${CONFIGURE_OUT})"
	exit 3
    fi
fi

BUILD_OUT=make.out
echo "${TAG} Building python with ${CC}"
echo "${TAG} Building >& ${BUILD_OUT}"
env CC="${CC}" make >& ${BUILD_OUT}
if [ $? != 0 ]; then
    tail ${BUILD_OUT}
    echo "${TAG} Failed to build ${BUILD_TAG} (check ${BUILD_OUT})"
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

