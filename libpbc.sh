#!/bin/sh

wget https://crypto.stanford.edu/pbc/files/pbc-0.5.14.tar.gz
tar xf pbc-0.5.14.tar.gz
cd pbc-0.5.14
CFLAGS="-L/usr/lib/ -L/usr/include/"
cp ../libpbc-configure.ac configure.ac
automake
autoconf
emconfigure ./configure --prefix=$EMSCRIPTEN/system --disable-sharedi --host none
emmake make
emmake make install

cd ..
rm -rf pbc-0.5.14*

