#!/bin/sh

cargo build --target wasm32-unknown-emscripten
cp input.wasm target/wasm32-unknown-emscripten/debug
cd target/wasm32-unknown-emscripten/debug
touch output.wasm
node ~/emscripten-module-wrapper/prepare.js wasm_sample.js --run --file input.wasm --file output.wasm --asmjs --debug --analyze --out=stuff


