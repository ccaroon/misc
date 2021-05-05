#!/usr/bin/env python
import arrow
import math
# ------------------------------------------------------------------------------
BIRTHDAY='2021-01-26'
# ------------------------------------------------------------------------------
birth_date = arrow.get(BIRTHDAY)
now = arrow.get()

age = now - birth_date
human_age = round(age.days / 30.416) # in months

# 1dm == 7hm
dog_age = human_age * 7 # in months

dog_years = math.floor(dog_age / 12)
dog_months = dog_age - (dog_years * 12)

print(F"Piper is {human_age} months old.")
print(F"That's {dog_age} dog months or {dog_years} years {dog_months} months.")
