import json
import os
import requests
import time

from invoke import task

from card import Card

IMG_TYPES = ("small", "normal", "large", "png", "art_crop", "border_crop")

@task(
    help={
        "card-list": "Filename of card list as downloaded by inv cards.download",
        "out-dir": "Directory to write image to",
        "filter": "Filter downloads: 'PROPERTY' = 'VALUE'. Can be specified multiple times.",
        "img-type": f"Image type: {IMG_TYPES}",
        "dry-run": "Don't download images. Just print what would be done."
    },
    iterable=["filter"]
)
def download(ctx, card_list, out_dir, filter=[], img_type="border_crop", dry_run=False, dump_card=False):
    """
    Download Card Images from ScryFall
    """

    if img_type not in IMG_TYPES:
        raise ValueError(f"{img_type} is not a valid image type: {IMG_TYPES}")

    print("=> Parsing Card List ...")
    card_data = __parse_card_list(card_list)

    print("=> Analyzing ...")
    # card_data = card_data[0:2]
    card_count = len(card_data)
    count = 0
    for idx, card_obj in enumerate(card_data):
        card = Card(card_obj)

        # Apply Filters
        if __skip_card(card, filter):
            continue

        # Skip Foil-only cards b/c ...?
        if card.property("nonfoil") == False:
            continue
        
        for img in card.images(img_type):
            img_file = img.get("file_name")
            img_path = f"{out_dir}/{img_file}"
            img_url = img.get("uri")

            if not img_url:
                print(f"    ...no image URL for {card.name}!")
                continue

            print(f"  -> {card.name}: {card.set_code}/{card.set_number} ... {idx}/{card_count}")
            if dump_card:
                print(card.dump())

            if not os.path.exists(img_path):
                print(f"    ...fetching {img_url} as {img_file}...")
                if not dry_run:
                    resp = requests.get(img_url, timeout=120)
                    with open(img_path, "wb") as fptr:
                        fptr.write(resp.content)
                    count += 1
                    # Be kind, don't overwhelm the site
                    time.sleep(.25)

    print(f"\nDownloaded {count} images!")


def __skip_card(card, filters):
    skip = False
    
    for filter in filters:
        filter_name, filter_value = filter.split("=",2)
        prop_value = card.property(filter_name)

        if prop_value != filter_value:
            skip = True
            break

    return skip


def __parse_card_list(filename):
    card_data = None
    with open(filename, "r") as fptr:
        card_data = json.load(fptr)

    return card_data
