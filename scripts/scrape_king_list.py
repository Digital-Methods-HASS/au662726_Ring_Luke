###
# Utility to get the list of danish kings and the years they ruled
###

import requests, html, os

kings_csv = "data/king_list.csv"

# if the csv exists just exit
if (os.path.isfile(kings_csv)):
    print("File exists, exiting")
    exit(0)

print("Downloading list of kings")
king_url = "https://www.kongehuset.dk/monarkiet-i-danmark/kongerakken"

response = requests.get(king_url)
raw_html = response.text

# now the kings name is in element h2.royal-line__monarch__item__content__title
# and the years they ruled is in element div.royal-line__monarch__item__content__period

king_list = []
year_list = []

print("Parsing html")

for line in raw_html.split("\n"):
    if "h2 class=\"royal-line__monarch__item__content__title\"" in line:
        king = line.split("\">")[1].split("<")[0]
        king_list.append(html.unescape(king))
    if "div class=\"royal-line__monarch__item__content__period\"" in line:
        years = line.split("\">")[1].split("<")[0]
        if "-" in years:
            start, end = years.split("-")
        else:
            start = html.unescape(years)
            end = ''
        year_list.append((start, end))

king_rules = dict(zip(king_list, year_list))
print("Writing to csv")
# now save as a csv file in data/king_list.csv
with open(kings_csv, "w", encoding="utf8") as f:
    # write header
    f.write("king;start;end\n")
    for king, (start, end) in king_rules.items():
        f.write(king + ";" + start + ";" + end + "\n")
print("Done")