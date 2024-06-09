import json
import os
import re
import requests
import time

from invoke import task

from card import Card

@task(help={
    "card_list": "Filename of card list as downloaded by inv cards.download",
    "out_dir": "Directory to write image to",
    "card_name": "Download images for specific card name",
    "card_set": "Download images for specific card set",
    "img_type": "Image type: small|normal|large|png|art_crop|border_crop",
    "verbose": "More output"
})
def download(ctx, card_list, out_dir, card_name=None, card_set=None, img_type="border_crop", verbose=False):
    """
    Download Card Images from ScryFall
    """
    print("=> Parsing Card List ...")
    card_data = __parse_card_list(card_list)

    print("=> Analyzing ...")
    # card_data = card_data[0:2]
    card_count = len(card_data)
    count = 0
    for idx, card_obj in enumerate(card_data):
        card = __parse_card(card_obj)

        # Apply Filters
        # -- SET --
        if card_set and card_set != card.set_code:
            continue

        # -- NAME --
        if card_name and card_name != card.name:
            continue

        for img in card.images(img_type):
            img_file = img.get("file_name")
            img_path = f"{out_dir}/{img_file}"
            img_url = img.get("uri")

            if not img_url:
                print(f"    ...not image URL for {card.name}!")
                continue

            print(f"  -> {card.name} ... {idx}/{card_count}")

            if not os.path.exists(img_path):
                print(f"    ...fetching {img_url} as {img_file}...")
                resp = requests.get(img_url, timeout=120)
                with open(img_path, "wb") as fptr:
                    fptr.write(resp.content)
                count += 1
                # Be kind, don't overwhelm the site
                time.sleep(.25)

    print(f"\nDownloaded {count} images!")


def __parse_card(card_obj):
    name = card_obj.get("name")
    image_uris = card_obj.get("image_uris")
    set_code = card_obj.get("set")
    type_line = card_obj.get("type_line")
    faces = card_obj.get("card_faces")

    return Card(name, set_code, type_line, image_uris, faces)


def __parse_card_list(filename):
    card_data = None
    with open(filename, "r") as fptr:
        card_data = json.load(fptr)

    return card_data
