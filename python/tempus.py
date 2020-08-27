#!/usr/bin/env python
import arrow
import argparse
################################################################################
def format(args):
    date = arrow.get(args.epoch)
    print(date.format(args.format))

def parse(args):
    date = arrow.get(args.date_str)
    print(date.timestamp)

def humanize(args):
    date = arrow.get(args.date_str)
    print(date.humanize(granularity=[args.unit]))

def usage(args):
    args.app.print_help()
################################################################################
if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Tempus. Time manipulation for the masses.'
    )
    parser.set_defaults(func=usage, app=parser)
    subparsers = parser.add_subparsers()
    
    # FORMAT
    format_parser = subparsers.add_parser('format', help='Epoch to Date String')
    format_parser.add_argument("epoch", type=int)
    format_parser.add_argument("--format", type=str, default="YYYY-MM-DD HH:mm:ss", help="Desired Date/Time format")
    format_parser.set_defaults(func=format)
    
    # PARSE
    parse_parser = subparsers.add_parser('parse', help='Date String to Epoch')
    parse_parser.add_argument("date_str", type=str)
    parse_parser.set_defaults(func=parse)

    # HUMANIZE
    humanize_parser = subparsers.add_parser('humanize', help='Describe the date/time given in human readable form.')
    humanize_parser.add_argument("date_str", type=str)
    humanize_parser.add_argument("--unit", type=str, default="day", nargs='*', help="Time unit(s) to be used in describing the datetime.")
    humanize_parser.set_defaults(func=humanize)

    # Execute Action
    args = parser.parse_args()
    args.func(args)
