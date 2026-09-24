#!/usr/bin/env python

"""The Perfect Cup of Coffee"""
import argparse

# Coffee Grounds to Water ratio
# RATIO = 1/16
WATER_IN_GRAMS = 29.57


def __compute_coffee_amt(water_amt:int, ratio):
    # (16*29.5)*ratio
    return (water_amt * WATER_IN_GRAMS) * ratio


def main(args):
    (coffee, water) = args.ratio.split(":", 1)
    ratio = int(coffee) / int(water)

    grams_of_coffee = __compute_coffee_amt(int(args.water_amt), ratio)
    grams_of_coffee = round(grams_of_coffee, 0)

    print(f"In order to brew the perfect {args.water_amt}oz Cup of Coffee, you will need {grams_of_coffee}g of Ground Coffee")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Compute amount of Coffee Grounds needed for Xoz of Water")

    parser.add_argument("water_amt", help="Water Amount in Ounces")
    parser.add_argument("--ratio", default="1:16", help="Ratio of Coffee to Water: 1:16 | 1:15 | 1:18")
    args = parser.parse_args()

    # print(args.water_amt, args.ratio)

    main(args)
