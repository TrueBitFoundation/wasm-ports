FROM ubuntu:18.04
MAINTAINER Sami Mäkelä

SHELL ["/bin/bash", "-c"]

RUN apt-get  update \
 && apt-get install -y git cmake ninja-build g++ python wget ocaml opam libzarith-ocaml-dev m4 pkg-config zlib1g-dev apache2 psmisc sudo mongodb curl tmux nano \
 && opam init -y

RUN git clone https://github.com/juj/emsdk \
 && cd emsdk \
 && ./emsdk update-tags \
 && LLVM_CMAKE_ARGS="-DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly" ./emsdk install sdk-tag-1.37.36-64bit \
 && ./emsdk activate sdk-tag-1.37.36-64bit \
 && ./emsdk install  binaryen-tag-1.37.36-64bit \
 && ./emsdk activate binaryen-tag-1.37.36-64bit

RUN cd bin \
 && wget https://github.com/ethereum/solidity/releases/download/v0.4.23/solc-static-linux \
 && mv solc-static-linux solc \
 && chmod 744 solc

RUN wget http://d1h4xl4cr1h0mo.cloudfront.net/v1.10.1/x86_64-unknown-linux-gnu/parity_1.10.1_ubuntu_amd64.deb \
 && dpkg --install parity_1.10.1_ubuntu_amd64.deb \
 && (parity --chain dev &) \
 && sleep 10 \
 && killall parity

RUN wget https://dist.ipfs.io/go-ipfs/v0.4.11/go-ipfs_v0.4.11_linux-amd64.tar.gz \
 && tar xf go-ipfs_v0.4.11_linux-amd64.tar.gz \
 && cd go-ipfs \
 && ./install.sh \
 && ipfs init

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
 && cd wasm-ports \
 && apt-get install -y lzip autoconf libtool flex bison \
 && sh gmp.sh \
 && sh openssl.sh \
 && sh secp256k1.sh \
 && sh libff.sh \
 && sh boost.sh


