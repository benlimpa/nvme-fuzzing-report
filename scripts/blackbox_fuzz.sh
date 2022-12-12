#!/bin/bash

set -e

if [[ ! -e scripts/blackbox_fuzz.sh ]]; then
	echo >&2 "Please cd into the root of this repository (nvme-fuzzing-report/) before running any scripts."
    exit 1
fi

SPDK_FUZZER=$(realpath ./spdk/test/app/fuzz/nvme_fuzz)
FUZZ_TIME=10

if [[ ! -x $SPDK_FUZZER ]]; then
	echo >&2 "ERROR: Could not find executable: $SPDK_FUZZER. Please compile spdk."
	exit 1
fi

sudo ./nvme_fuzz \
	-F "trtype=PCIe traddr=0000:01:00.0" \
	-t $FUZZ_TIME \
	-S 202212 \
	>"data/spdk/spdk_fuzz.log"