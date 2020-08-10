#!/bin/bash
wget http://www.shoup.net/ntl/ntl-10.5.0.tar.gz
tar xf ntl-10.5.0.tar.gz
cd ntl-10.5.0
cd src
emconfigure ./configure DEF_PREFIX=${HOME}/opt NTL_GMP_LIP=on
patch < makefile.ntl.patch
make -j 6
make install
