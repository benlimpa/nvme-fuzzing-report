import os
import sys
from argparse import ArgumentParser

if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument(
        "operation", choices=["read", "write"], help="The NVMe operation to encode."
    )
    parser.add_argument(
        "-s",
        "--start-block",
        default=0,
        type=int,
        help="The starting logical block of the SSD to read/write.",
    )
    parser.add_argument(
        "-c",
        "--block-count",
        default=0,
        type=int,
        help="The number of logical blocks to read/write.",
    )
    parser.add_argument(
        "-z",
        "--data-size",
        default=0,
        type=int,
        help="The number of bytes to read/write.",
    )
    parser.add_argument(
        "--save-to",
        help="The file to save the encoded command to. If none is provided, then it will output to standard output.",
    )

    args = parser.parse_args()

    if args.save_to is None:
        out_buffer = sys.stdout.buffer
    else:
        out_buffer = open(args.save_to, "wb")

    if args.operation == "read":
        out_buffer.write(b"\0")
    elif args.operation == "write":
        out_buffer.write(b"\1")

    out_buffer.write(args.start_block.to_bytes(4, sys.byteorder))
    out_buffer.write(args.block_count.to_bytes(4, sys.byteorder))
    out_buffer.write(args.data_size.to_bytes(4, sys.byteorder))
    if args.save_to is not None:
        out_buffer.close()
