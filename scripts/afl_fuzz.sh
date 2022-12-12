#!/bin/bash

set -e

if [[ ! -e scripts/build_with_afl_lto.sh ]]; then
	echo >&2 "Please cd into the root of this repository (nvme-fuzzing-report/) before running any scripts."
    exit 1
fi

AFL_FUZZ=$(realpath "./AFLplusplus/afl-fuzz")
NVME_CLI=$(realpath "./nvme-cli/build/nvme")
IN_DIR=$(realpath "./data/afl/inputs")
OUT_DIR=$(realpath "./data/afl/outputs")

if [[ ! -x $AFL_FUZZ ]]; then
    echo >&2 "ERROR: The executable $AFL_FUZZ does not exist. Please compile AFL++ first."
    exit 1
fi
if [[ ! -x $NVME_CLI ]]; then
    echo >&2 "ERROR: The executable $NVME_CLI does not exist. Please compile nvme-cli using ./scripts/build_with_afl_lto.sh first."
    exit 1
fi

sudo $AFL_FUZZ -D -i "$IN_DIR" -o "$OUT_DIR" -- "$NVME_CLI" --log $(realpath ./nvme_fuzz.log)
