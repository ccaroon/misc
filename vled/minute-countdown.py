#!/usr/bin/env python
import argparse
import time

import arrow
from led_matrix.color import Color
from led_matrix.glyph import Glyph
from led_matrix.program import Program

# PYGAME_HIDE_SUPPORT_PROMPT


class MinuteCountdown(Program):
    """
    Countdown to a specific date/time in minutes.
    """

    def __init__(self, start_dt, end_dt, **kwargs):
        super().__init__(**kwargs)

        self.__start_dt = start_dt
        self.__end_dt = end_dt

        self.__total_min = int((end_dt - start_dt).total_seconds() / 60)

        self.__color = Color.make(kwargs.get("color", "white"))

    def on_key_down(self, key_name, _):
        if key_name in ("q", "Q"):
            self.exit()

    def loop(self):
        """
        Update the countdown
        """
        now = arrow.now("US/Eastern")
        elapsed_min = int((now - self.__start_dt).total_seconds() / 60)
        remaining_min = self.__total_min - elapsed_min

        self.matrix.display_string(
            1,
            1,
            f"{remaining_min:,}",
            self.__color,
            spacing=1,
        )
        self.matrix.update()

        time.sleep(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Minute Countdown")
    parser.add_argument(
        "start_date",
        type=str,
        help="The start date/time of the event to count down from",
    )
    parser.add_argument(
        "end_date",
        type=str,
        help="The end date/time of the event to count down to",
    )
    parser.add_argument(
        "--color",
        "-c",
        type=str,
        default="chartreuse",
        help="The color of the digits. Default: Chartreuse",
    )
    parser.add_argument(
        "--size",
        "-s",
        type=int,
        default=10,
        help="LED Size. Default: 10",
    )
    args = parser.parse_args()

    start = arrow.get(f"{args.start_date} US/Eastern", "YYYY-MM-DD@HH:mm ZZZ")
    end = arrow.get(f"{args.end_date} US/Eastern", "YYYY-MM-DD@HH:mm ZZZ")

    total_min = int((end - start).total_seconds() / 60)

    width = Glyph.strlen(f"{total_min:,}", spacing=1) + 1
    height = Glyph.get("X").height + 2

    print("Press 'Q' to exit!")  # noqa: T201
    program = MinuteCountdown(
        start,
        end,
        width=width,
        height=height,
        title="Minute Countdown",
        noframe=True,
        led_size=args.size,
        led_shape="circle",
        led_spacing=1,
        color=args.color,
    )
    program.execute()
