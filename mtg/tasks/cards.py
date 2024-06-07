from invoke import task

import os
import requests


@task(help={
    "type": "Card list type: oracle-cards | unique-artwork | default-cards | all-cards | rulings"
})
def download(ctx, type="default-cards"):
    """
    Download Card List from ScryFall
    """
    print(f"=> Requesting Bulk Data Info for {type}...")
    resp = requests.get(f"https://api.scryfall.com/bulk-data/{type}")
    if resp.status_code != 200:
        raise RuntimeError(f"Bulk-Data Metadata Fetch Failed: {resp.status_code}")

    data = resp.json()
    download_uri = data.get("download_uri")

    file_name = os.path.basename(download_uri)

    if not os.path.exists(file_name):
        print(f"=> Requesting Bulk Data for {type} [{download_uri}]...")
        card_resp = requests.get(download_uri)
        if card_resp.status_code != 200:
            raise RuntimeError(f"Bulk-Data({type}) Fetch Failed: {card_resp.status_code}")

        with open(file_name, "w") as fptr:
            fptr.write(card_resp.text)

        print(f"=> Fetched {type} list: {file_name}")
    else:
        print(f"=> Already downloaded: {file_name}!")
