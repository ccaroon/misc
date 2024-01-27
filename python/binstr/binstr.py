#!/usr/bin/env python
import argparse
import os

def encode(args):
    file_path = args.filename
    out_file = file_path + ".bstr"

    count = 1
    with open(file_path, "rb") as in_fptr:
        with open(out_file, "w") as out_fptr:
            bite = in_fptr.read(1)

            while bite:
                out_data = f"{int(bite.hex(),16):08b} "
                if count == 10:
                    out_data += "\n"
                    count = 0
                out_fptr.write(out_data)
                count += 1
                bite = in_fptr.read(1)

    return out_file

def decode(args):
    file_path = args.filename
    out_file = os.path.splitext(file_path)[0] + ".bin"

    with open(file_path, "r") as in_fptr:
        with open(out_file, "wb") as out_fptr:
            data = in_fptr.readline()
            while data:
                bites = data.split()

                out_data = []
                for bite in bites:
                    bt = int(f"0b{bite}", 2)
                    out_data.append(bt)

                out_fptr.write(bytes(out_data))

                data = in_fptr.readline()

    os.chmod(out_file, 0o755)

    return out_file

def usage(args):
    args.app.print_help()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='BinStr - Encode/Decode binary file to/from string repr of bits.'
    )
    parser.set_defaults(func=usage, app=parser)
    subparsers = parser.add_subparsers()

    # encode
    encode_parser = subparsers.add_parser('encode', help='Binary to String Repr of Bits')
    encode_parser.add_argument("filename", type=str)
    # encode_parser.add_argument("--tz", "-z", type=str, default="local", help="Format for a specific TimeZone. Default 'local'.")
    encode_parser.set_defaults(func=encode)

    # decode
    decode_parser = subparsers.add_parser('decode', help='Decode String Repr of Bits to Binary')
    decode_parser.add_argument("filename", type=str)
    # decode_parser.add_argument("--tz", "-z", type=str, default="local", help="Treat date as if in specified TimeZone. Default 'local'.")
    decode_parser.set_defaults(func=decode)


    # Execute Action
    args = parser.parse_args()
    outfile = args.func(args)

    print(f"{args.filename} -> {outfile}")
