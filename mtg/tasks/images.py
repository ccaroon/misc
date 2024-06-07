import json
import os
import re
import requests
import time

from invoke import task

@task(help={
    "card_list": "Filename of card list as downloaded by inv cards.download",
    "out_dir": "Directory to write image to",
    "card_name": "Download images for specific card name",
    "card_set": "Download images for specific card set",
    "img_type": "Image type: small|normal|large|png|art_crop|border_crop",
    "verbose": "More output"
})
def fetch(ctx, card_list, out_dir, card_name=None, card_set=None, img_type="normal", verbose=False):
    """
    Fetch Card Images from ScryFall
    """
    print("=> Parsing Card List ...")
    card_data = __parse_card_list(card_list)

    print("=> Analyzing ...")
    # card_data = card_data[0:2]
    card_count = len(card_data)
    count = 0
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
        if card_set and card_set != set_code:
            continue

        if card_name and card_name != name:
            continue

        img_ext = ".png" if img_type == "png" else ".jpg"
        img_name = re.sub(
            r"\W", "-",
            f"{set_code}__{name}__{type_line}__{img_type}"
        ) + img_ext

        img_path = f"{out_dir}/{img_name}"

        print(f"  -> {name} ... {idx}/{card_count}")
        if image_uris:
            img_url = image_uris.get(img_type)
            if img_url:
                if not os.path.exists(img_path):
                    print(f"    ...fetching {img_url} as {img_name}...")
                    resp = requests.get(img_url, timeout=120)
                    with open(img_path, "wb") as fptr:
                        fptr.write(resp.content)
                    count += 1
                    # Be kind, don't overwhelm the site
                    time.sleep(.25)
            else:
                print("--------------------------")
                print(image_uris)
                print(img_url)
                print(f"    ...{set_code}/{name} is missing image type [{img_type}]")
                print("--------------------------")
        else:
            # Look in `card_faces` instead
            print(f"    ...{set_code}/{name} appears to be a double-face card. Skipping!")

    print(f"\nDownloaded {count} images!")



def __parse_card_list(filename):
    card_data = None
    with open(filename, "r") as fptr:
        card_data = json.load(fptr)

    return card_data
