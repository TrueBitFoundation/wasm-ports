#!/bin/sh

em++ pairing.cpp -s WASM=1 -lff -lgmp -I $EMSCRIPTEN/system/include -std=c++11 -o pairing.js
node ~/emscripten-module-wrapper/prepare.js pairing.js  --run --debug --out dist --file _dev_urandom --file input.data --file output.data

