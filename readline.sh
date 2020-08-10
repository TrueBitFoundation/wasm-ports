#!/bin/bash
 wget ftp://ftp.gnu.org/gnu/readline/readline-8.0.tar.gz
tar xvf readline-8.0.tar.gz
cd readline-8.0

bash_cv_wcwidth_broken=no
bash_cv_signal_vintage=posix
ac_cv_lib_util_openpty=no
ac_cv_lib_dir_opendir=no

emconfigure ./configure --host none --prefix==$EMSCRIPTEN/system --disable-shared

echo '#define HAVE_MEMSET 1' >> config.h
echo '#define HAVE_STRNLEN 1' >> config.h
echo '#define HAVE_VSNPRINTF 1' >> config.h

emmake make
make install

cd ..
rm -rf readline-8.0
