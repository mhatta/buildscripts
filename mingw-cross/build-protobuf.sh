set -e

ROOT_SRC=`pwd`/src
ROOT_LIB=`pwd`/lib
BUILD_OUTPUT=`pwd`/output
test -e ${ROOT_SRC}

# Build dependencies
git submodule update --init
cd $ROOT_SRC

# Protobuf
cd protobuf
git submodule update --init
git clean -dfx .
git reset --hard
# Protobuf will rudely fetch this over HTTP if it isn't present..
if [ ! -e gmock ]; then
        git clone https://github.com/google/googlemock.git gmock
        cd gmock
        git checkout release-1.7.0
        cd ..
fi
if [ ! -e gtest ]; then
        git clone https://github.com/google/googletest.git gtest
        cd gtest
        git checkout release-1.7.0
        cd ..
fi
./autogen.sh
# Build native protobuf (for the protoc compiler)
./configure --prefix="${ROOT_LIB}/protobuf-native/" --disable-shared --without-zlib
make ${MAKEOPTS}
make install
# Build protobuf for target
make distclean
./configure --prefix="${ROOT_LIB}/protobuf/" --host=x86_64-w64-mingw32 --with-protoc="${ROOT_LIB}/protobuf-native/bin/protoc" --disable-shared --without-zlib
make ${MAKEOPTS}
make install
cd ..

cd ..
echo "build-protobuf: done"
