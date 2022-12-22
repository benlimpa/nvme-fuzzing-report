import os
import sys
from argparse import ArgumentParser

CMD_LEN = 1 + 4 * 3

if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("input_file", help="The file to decode the command from.")

    args = parser.parse_args()

    with open(args.input_file, "rb") as f:
        cmd_encoded = f.read()

    cmd_decoded = "nvme {cmd_type} -s {start_block} -c {block_count} -z {data_size}"

    if len(cmd_encoded) < CMD_LEN:
        raise RuntimeError(
            f"Expected encoded command to be {CMD_LEN} bytes long, but got {len(cmd_encoded)} instead"
        )
    if cmd_encoded[0] == 0:
        cmd_type = "read"
    elif cmd_encoded[0] == 1:
        cmd_type = "write"
    else:
        raise RuntimeError(f"Could not decode command type: {cmd_encoded[0]}")

    start_block = int.from_bytes(cmd_encoded[1 : 1 + 4], sys.byteorder)
    block_count = int.from_bytes(cmd_encoded[5 : 5 + 4], sys.byteorder)
    data_size = int.from_bytes(cmd_encoded[9 : 9 + 4], sys.byteorder)

    print(
        cmd_decoded.format(
            cmd_type=cmd_type,
            start_block=start_block,
            block_count=block_count,
            data_size=data_size,
        )
    )
