# wasm-ports
Scripts to install libraries compiled to WASM using emscripten

## Issues with compiling using emscripten

### Does not find the compiler

Seems like this is difficult, perhaps should use $CC or something.
Currently just have to `sed` the Makefile or something similar.

### Typed function calls

In WebAssembly, the function calls are typed, so there will be several issues.
For example configure scripts might not work.

### Stuff that is not implemented in openssl

stdatomic.h

### Always only use static libraries

