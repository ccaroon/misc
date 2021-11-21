#!/bin/env python
# https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes

from translate import Translator

DEBUG = False

def __debug(msg):
    if DEBUG:
        print(msg)

def gg(msg, translators):
    new_msg = msg
    for tx in translators:
        tmp_msg = new_msg
        new_msg = tx.translate(new_msg)
        __debug(F"From {tx.from_lang}:{tmp_msg} to {tx.to_lang}:{new_msg}")

    return new_msg

# ------------------------------------------------------------------------------
if __name__ == "__main__":
    email = 'ghoti@fish.com'

    english = Translator(to_lang='en', from_lang='autodetect', email=email)
    german =  Translator(to_lang='de', from_lang='autodetect', email=email)
    spanish = Translator(to_lang='es', from_lang='autodetect', email=email)
    italian = Translator(to_lang='it', from_lang='autodetect', email=email)
    swedish = Translator(to_lang='sv', from_lang='autodetect', email=email)
    welsh =   Translator(to_lang='cy', from_lang='autodetect', email=email)

    msg = input("What? ")

    translation = gg(msg, (swedish, german, welsh, spanish, english))

    print(F"{msg} ==> {translation}")
