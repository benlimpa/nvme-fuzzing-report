#!/bin/bash

set -e

if [[ ! -e scripts/build_with_afl_lto.sh ]]; then
	echo >&2 "Please cd into the root of this repository (nvme-fuzzing-report/) before running any scripts."
    exit 1
fi

AFL_DIR=$(realpath "./AFLplusplus")
NVME_CLI_DIR=$(realpath "./nvme-cli")
BUILD_DIR="$NVME_CLI_DIR/build"
export CC="$AFL_DIR/afl-clang-lto"
export CXX="$AFL_DIR/afl-clang-lto++"
export LD="$AFL_DIR/afl-clang-lto"
export AFL_LLVM_LAF_ALL=1

# check to ensure all paths exist
if [[ ! -d $BUILD_DIR ]]; then
    echo >&2 "ERROR: The directory $BUILD_DIR does not exist."
    exit 1
fi
for REQ_FILE in "$CC" "$CXX" "$LD"; do
    if [[ ! -x $REQ_FILE ]]; then
        echo >&2 "ERROR: The executable $REQ_FILE does not exist. Please compile AFL++ first."
        exit 1
    fi
done

cd "$NVME_CLI_DIR"
meson "$BUILD_DIR"
ninja -C "$BUILD_DIR"
