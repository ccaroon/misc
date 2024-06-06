#!/usr/bin/env python
import argparse
import json
import os
import re
import requests
import time


def __parse_card_list(filename):
    card_data = None
    with open(filename, "r") as fptr:
        card_data = json.load(fptr)

    return card_data


def main(args):
    print("=> Parsing Card List ...")
    card_data = __parse_card_list(args.card_list)

    print("=> Analyzing ...")
    # card_data = card_data[0:2]
    card_count = len(card_data)
    for idx, object in enumerate(card_data):
        # name, image_uris.png, set, set_name, type_line
        name = object.get("name")
        image_uris = object.get("image_uris")
        set_code = object.get("set")
        # set_name = object.get("set_name")
        type_line = object.get("type_line")
        
        # if args.verbose:
        #     print(f"  -> {name} ... {idx}/{card_count}")
        # if idx % 100 == 0:
        #     print(f"    -> Progress {idx}/{card_count}")
        
        # Skip unwanted images by set
        if args.set and args.set != set_code:
            continue
        
        if args.card_name and args.card_name != name:
            continue

        img_ext = ".png" if args.img_type == "png" else ".jpg"
        img_name = re.sub(
            r"\W", "-", 
            f"{set_code}__{name}__{type_line}__{args.img_type}"
        ) + img_ext
        
        img_path = f"{args.out_dir}/{img_name}"

        print(f"  -> {name} ... {idx}/{card_count}")
        if image_uris:
            img_url = image_uris.get(args.img_type)
            if img_url:
                if not os.path.exists(img_path):
                    print(f"    ...fetching {img_url} as {img_name}...")
                    resp = requests.get(img_url)
                    with open(img_path, "wb") as fptr:
                        fptr.write(resp.content)
                    # Be kind, don't overwhelm the site
                    time.sleep(.25)
            else:
                print("--------------------------")
                print(image_uris)
                print(img_url)
                print(f"    ...{set_code}/{name} is missing image type [{args.img_type}]")
                print("--------------------------")
        else:
            # Look in `card_faces` instead
            print(f"    ...{set_code}/{name} appears to be a double-face card. Skipping!")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Fetch MTG Card Images from ScryFall")

    parser.add_argument("out_dir", help="Directory to store downloaded images.")
    parser.add_argument("card_list", help="Filename of the Card List file (JSON)")
    parser.add_argument("--card_name", help="Fetch image for the named card")
    parser.add_argument("--set", help="Fetch Images for MTG Set")
    parser.add_argument("--img_type", choices=["small", "normal", "large", "png", "art_crop", "border_crop"], default="normal")
    parser.add_argument("--verbose", action="store_true")
    args = parser.parse_args()

    main(args)
