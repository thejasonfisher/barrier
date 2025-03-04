#!/bin/sh
cd "$(dirname "$0")" || exit 1
# some environments have cmake v2 as 'cmake' and v3 as 'cmake3'
# check for cmake3 first then fallback to just cmake
B_CMAKE=`type cmake3 2>/dev/null`
if [ $? -eq 0 ]; then
    B_CMAKE=`echo "$B_CMAKE" | cut -d' ' -f3`
else
    B_CMAKE=cmake
fi
# default build configuration
B_BUILD_TYPE=${B_BUILD_TYPE:-Debug}
if [ "$(uname)" = "Darwin" ]; then
    # OSX needs a lot of extra help, poor thing
    # run the osx_environment.sh script to fix paths
    . ./osx_environment.sh

    # default to 12.0, fallback to 10.9
    OSX_DEPLOY_TARGET="12.0"
    [ ! "$OSTYPE" == "darwin21"* ] && OSX_DEPLOY_TARGET="10.9"

    # prefer newest MacOSX.sdk
    OSX_SYSROOT="$(xcode-select --print-path)/SDKs/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
    [ ! -d "$OSX_SYSROOT" ] && OSX_SYSROOT="$(xcode-select --print-path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"

    B_CMAKE_FLAGS="-DCMAKE_OSX_SYSROOT=$OSX_SYSROOT -DCMAKE_OSX_DEPLOYMENT_TARGET=$OSX_DEPLOY_TARGET $B_CMAKE_FLAGS"
fi
# allow local customizations to build environment
[ -r ./build_env.sh ] && . ./build_env.sh

# Initialise Git submodules
git submodule update --init --recursive

B_CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=$B_BUILD_TYPE $B_CMAKE_FLAGS"
rm -rf build
mkdir build || exit 1
cd build || exit 1
echo "Starting Barrier $B_BUILD_TYPE build..."
$B_CMAKE $B_CMAKE_FLAGS .. || exit 1
make || exit 1
echo "Build completed successfully"
