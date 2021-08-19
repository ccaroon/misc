#!/usr/bin/env python

import time

PROGRESS_START='|'
PROGRESS_MARK='='
PROGRESS_END='|'

PREFIX_START='['
PREFIX_END=']'


PROGRESS=['🕛', '🕐', '🕑', '🕒', '🕓', '🕔', '🕕', '🕖', '🕗', '🕘', '🕙', '🕚']

REPORT_EVERY=1

count = 0
prefix = None
output = ''
try:
    while True:
        count += 1
        mins = int(count / 60)
        secs = count % 60
        prefix = F" {PREFIX_START}{mins:02d}m{secs:02d}s{PREFIX_END}{PROGRESS_START}{PROGRESS[count % 12]}|"
        output += PROGRESS_MARK
        end_mark = '>'
        # end_mark = PROGRESS[count % 12]
        if count % REPORT_EVERY == 0:
            print(F"{prefix}{output}{end_mark}", end='\r', flush=True)
        
        if count % 60 == 0:
            print(F"{prefix}{output}{PROGRESS_END}", flush=True)
            output = ""

        time.sleep(1)
except KeyboardInterrupt:
    print(PROGRESS_END)
    mins = 0
    secs = count % 60
    if count >= 60:
        mins = int(count / 60)

    print(F"Elapsed Time: {mins}m {secs}s")
