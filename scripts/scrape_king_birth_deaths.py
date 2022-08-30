###
# scrape table from wikipedia and save information from the table to a csv
###

import csv
import bs4
import requests

import os


kings_csv = "data/king_birth_deaths.csv"
if (os.path.isfile(kings_csv)):
    print("File exists, exiting")
    exit(0)


king_url = "https://da.wikipedia.org/wiki/Konger%C3%A6kken"


response = requests.get(king_url)
raw_html = response.text

soup = bs4.BeautifulSoup(raw_html, "html.parser")

tables = soup.findAll("table", {"class": "wikitable"})

king_list = []
year_list = []
for table in tables:
    for row in table.findAll("tr"):
        cells = row.findAll("td")
        if len(cells) == 7:
            king = cells[0].get_text(separator=" ").strip().replace("\n", "")
            start = cells[2].get_text(separator=" ").strip().replace("\n", "")
            end = cells[4].get_text(separator=" ").strip().replace("\n", "")
            king_list.append(king)
            year_list.append((start, end))

king_rules = dict(zip(king_list, year_list))

# now save to csv


print("Writing to csv")
with open("data/king_birth_deaths.csv", "w", encoding="utf8", newline='') as f:
    writer = csv.writer(f, delimiter=";")
    writer.writerow(["king", "birth", "death"])
    for king, (start, end) in king_rules.items():
        writer.writerow([king, start, end])
print("Done")
