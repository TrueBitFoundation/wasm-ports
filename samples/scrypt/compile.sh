#!/bin/sh

em++ -I $EMSCRIPTEN/system/include -c -std=c++11 scrypthash.cpp
em++ -I $EMSCRIPTEN/system/include -c -std=c++11 scrypt.cpp
em++ -o scrypt.js scrypthash.o scrypt.o -lcrypto -lssl

node ~/emscripten-module-wrapper/prepare.js scrypt.js --file input.data --file output.data --run --debug --out=stuff

