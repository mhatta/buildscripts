set -e

ROOT_SRC=`pwd`/src
ROOT_LIB=`pwd`/lib
BUILD_OUTPUT=`pwd`/output
test -e ${ROOT_SRC}
mkdir ${BUILD_OUTPUT}

# Build dependencies
git submodule update --init
cd $ROOT_SRC

# Openssl
cd openssl
git clean -dfx .
git reset --hard
./Configure no-shared no-zlib no-capieng --prefix="${ROOT_LIB}/openssl/" --cross-compile-prefix=x86_64-w64-mingw32- mingw64
make -j1 depend
make -j1
make install
cd ..

# Libevent
cd libevent
git clean -dfx .
git reset --hard
./autogen.sh
./configure --prefix="${ROOT_LIB}/libevent" --host=x86_64-w64-mingw32
make ${MAKEOPTS}
make install
cd ..

# Tor
cd tor
git clean -dfx .
git reset --hard
./autogen.sh
./configure --prefix="${ROOT_LIB}/tor" --host=x86_64-w64-mingw32 --with-openssl-dir="${ROOT_LIB}/openssl/" --with-libevent-dir="${ROOT_LIB}/libevent/" --with-zlib-dir=`x86_64-w64-mingw32-pkg-config --variable=libdir zlib` --enable-static-tor --disable-asciidoc
make ${MAKEOPTS}
make install
cp ${ROOT_LIB}/tor/bin/tor.exe ${BUILD_OUTPUT}/
cd ..

cd ..
echo "build-tor: done"
