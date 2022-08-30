###
# utility to remove kings from a csv that don't have an end year
###

import csv
import os

kings_csv = "data/king_list.csv"

# open the csv file and read it into a list of lists
with open(kings_csv, "r", encoding="utf8") as f:
    reader = csv.reader(f, delimiter=";")
    king_list = list(reader)

# remove kings with an empty end year
king_list = [king for king in king_list if king[2] != '']

# write the list to the csv file with _clean suffix
with open("data/king_list_clean.csv", "w", encoding="utf8", newline='') as f:
    writer = csv.writer(f, delimiter=";")
    writer.writerows(king_list)
print("Done")