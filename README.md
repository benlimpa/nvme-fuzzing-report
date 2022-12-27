# NVMe Fuzzing Report
This repository contains the code used to produce the results discussed in the NVMe Fuzzing Report.

## Command Enumeration with Bash Scripts
Basic command enumeration is performed using a set of bash scripts that call `nvme-cli` to issue read/write commands to the NVMe SSD. More information can be found here: https://github.com/dkminsoo/ssd-testing

## Black-box Fuzzing with SPDK
Black-box Fuzzing is performed using a modified version of the fuzzer included with the [SPDK library](https://spdk.io/).

### Reproducing Results
1. Clone the `spdk` submodule and build according to the instructions in `spdk/README.md`.
2. Enable IOMMU/VT for Direct I/O in the UEFI setup.
3. Enable the IOMMU kernel module:
   a. Edit `/etc/default/grub` and add `intel_iommu=on` to `GRUB_CMDLINE_LINUX`
   b. Run `sudo grub-mkconfig -o /boot/grub/grub.cfg` to regenerate the grub config
4. Unbind the linux NVMe driver and bind the SPDK driver by running `sudo scripts/setup.sh`
5. Build `nvme_fuzz` by running the following commands:
    - `cd spdk/test/app/fuzz/nvme_fuzz`
    - `make`
6. Identify the NVMe device using the provide example app:
    - `sudo ./spdk/build/examples/identify`
7. Run the fuzzer by calling the script provided: `./scripts/blackbox_fuzz.sh`
    - Adjust fuzzing options as desired in this script.
    - Possible flags that can be passed to the fuzzer include:
        - `-F "trtype=PCIe traddr=0000:01:00.0"` tells the fuzzer to fuzz the device/namespace add a particular address.
        - `-t 5` tells the fuzzer to fuzz for 5 seconds
        - `-S 12345` tells the fuzzer to use 12345 as the seed (note that the device state is not reset after the fuzzing run so this must be manually done to ensure fuzzing runs are reproducible)
        - `-a` tells the fuzzer to fuzz with admin commands (this is somewhat dangerous because it tends to cause the device to hang which the fuzzer does not gracefully handle (although it is supposed to be designed to handle?))

## Coverage-guided Fuzzing with AFLplusplus
0. NOTE: `nvme-cli` uses the Linux driver, not the SPDK driver. Ensure that the device is bound the the Linux driver by running:
    - `nvme list` which should list all connected NVMe devices.
1. Clone the `AFLplusplus` submodule and build it according to the instructions in `AFLplusplus/docs/INSTALL.md`.
    - NOTE: To compikle AFL++ in LLVM LTO mode, ensure that LLVM is at least version 14 and the following packages are installed: `sudo apt-get install -y lld llvm llvm-dev clang`
2. Compile `nvme-cli` using the script provided: `./scripts/build_with_afl_lto.sh`.
    - I recommend installing openssl development libraries: `sudo apt install libssl-dev`, so that the build script does not compile it as a subproject.
3. Run the fuzzer by calling the script provided: `./scripts/afl_fuzz.sh`
    - Adjust fuzzing options as desired in this script.

### Inspecting Crashing Inputs
AFL++ will store crashing inputs under `./data/afl/outputs/default/crashes/`. These files contain the parameters for NVMe commands interpretted by the fuzzing harness.

To decode these commands, use the provided Python script: `./scripts/decode_cmd.py`. This script requires Python 3.7 or newer.

To decode a command run:
```bash
python3 ./scripts/decode_cmd.py path/to/crashing/input/file
```

### Adding New Seed Inputs
The nvme-cli tool included in this repository has been modified with a fuzzing harness that interprets the parameters to an NVMe read/write command from standard input. To add a NVMe read/write command to the corpus of seed inputs, use the provided Python script: `./scripts/encode_cmd.py`. This script accepts the three paramters that determine the NVMe read/write address and outputs the encoded command to either standard output or to a file. To run this script, you need Python 3.7 or newer.

To see all the options available, run:
```bash
python3 ./scripts/encode_cmd.py --help
```
