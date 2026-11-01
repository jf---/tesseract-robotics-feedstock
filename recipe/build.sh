#!/bin/sh

set -e

mkdir -p src
tar xf source.tar.gz --strip-components=1 -C src

# conda's clang adds -fvisibility-inlines-hidden, hiding cereal's visibility("default")
# registration singleton; with Mach-O's two-level namespace each dylib gets its own registry
# and consumers throw "unregistered polymorphic type". Strip it so the registry is shared,
# as upstream's own conda recipe does. (rattler-build runs this script under bash.)
if [[ "$OSTYPE" == "darwin"* ]]; then
  export CXXFLAGS="${CXXFLAGS//-fvisibility-inlines-hidden/}"
fi

cmake -GNinja \
  ${CMAKE_ARGS} \
  -DBUILD_SHARED_LIBS=ON \
  -DTESSERACT_ENABLE_TESTING=OFF \
  -DTESSERACT_ENABLE_EXAMPLES=OFF \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -S src \
  -B build_dir

cmake --build build_dir --config Release -- -j$CPU_COUNT
cmake --build build_dir --config Release --target install
