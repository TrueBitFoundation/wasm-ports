FROM ubuntu:18.04
MAINTAINER Sami Mäkelä

SHELL ["/bin/bash", "-c"]

RUN apt-get  update \
 && apt-get install -y git cmake ninja-build g++ python wget ocaml opam libzarith-ocaml-dev m4 pkg-config zlib1g-dev apache2 psmisc sudo mongodb curl tmux nano \
 && opam init -y

RUN git clone https://github.com/juj/emsdk \
 && cd emsdk \
 && ./emsdk update-tags \
 && ./emsdk install sdk-1.37.36-64bit \
 && ./emsdk activate sdk-1.37.36-64bit \
 && ./emsdk install  binaryen-tag-1.37.36-64bit \
 && ./emsdk activate binaryen-tag-1.37.36-64bit

RUN cd bin \
 && wget https://github.com/ethereum/solidity/releases/download/v0.4.23/solc-static-linux \
 && mv solc-static-linux solc \
 && chmod 744 solc

RUN git clone https://github.com/llvm-mirror/llvm \
 && cd llvm/tools \
 && git clone https://github.com/llvm-mirror/clang \
 && git clone https://github.com/llvm-mirror/lld \
 && cd /llvm \
 && git checkout release_60 \
 && cd tools/clang \
 && git checkout release_60 \
 && cd ../lld \
 && git checkout release_60 \
 && mkdir /build \
 && cd /build \
 && cmake -G Ninja -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=/usr/ /llvm \
 && ninja \
 && ninja install \
 && cd / \
 && rm -rf build llvm

RUN sed -i 's|/emsdk/clang/e1.37.36_64bit|/usr/bin|' /root/.emscripten

RUN eval `opam config env` \
 && apt-get install libffi-dev \
 && opam update \
 && opam install cryptokit yojson ctypes ctypes-foreign -y \
 && git clone https://github.com/TrueBitFoundation/ocaml-offchain \
 && cd ocaml-offchain/interpreter \
 && make

RUN git clone https://github.com/TrueBitFoundation/emscripten-module-wrapper \
 && source /emsdk/emsdk_env.sh \
 && cd emscripten-module-wrapper \
 && npm install

RUN git clone https://github.com/TrueBitFoundation/wasm-ports \
 && source /emsdk/emsdk_env.sh \
 && export EMCC_WASM_BACKEND=1 \
 && cd wasm-ports \
 && apt-get install -y lzip autoconf libtool flex bison \
 && sh gmp.sh \
 && sh openssl.sh \
 && sh secp256k1.sh \
 && sh libff.sh \
 && sh boost.sh \
 && sh libpbc.sh


