#!/bin/bash

wget https://www.openssl.org/source/openssl-1.1.1g.tar.gz
tar xf openssl-1.1.1g.tar.gz
cd openssl-1.1.1g

bash_cv_wcwidth_broken=no
bash_cv_signal_vintage=posix
ac_cv_lib_util_openpty=no
ac_cv_lib_dir_opendir=no

emconfigure ./Configure linux-generic64 --prefix=$EMSCRIPTEN/system no-threads no-shared

sed -i 's|^CROSS_COMPILE.*$|CROSS_COMPILE=|g' Makefile

emmake make -j 12 build_generated libssl.a libcrypto.a
rm -rf $EMSCRIPTEN/system/include/openssl
cp -R include/openssl $EMSCRIPTEN/system/include
cp libcrypto.a libssl.a $EMSCRIPTEN/system/lib
cd ..
rm -rf openssl-1.1.0h*

