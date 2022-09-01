###
# get list of kings from: https://danmarkshistorien.dk/vis/materiale/kongeraekken
# and save to file
###

import csv
import requests, re
from bs4 import BeautifulSoup

r = requests.get("https://danmarkshistorien.dk/vis/materiale/kongeraekken")
r.encoding = 'UTF-8'

soup = BeautifulSoup(r.text, "html.parser")

table = soup.find("table", {"class": "contenttable"})

king_info_raw = []

for row in table.findAll("tr"):
    cells = row.findAll("td")
    if len(cells) == 2:
        king_info = cells[0].get_text(strip=True, separator=" ").strip().replace("\n", "").replace(u'\xa0', u' ')
        king_info_raw.append(king_info)

king_info = []
# regular expression to match king name and birth day and rule dates
king_regex = re.compile(r"^([^\(]+)(\(([^\)]+)\)([^\(]+))?\(([^\)]+)\)\s*(\[\d+\])?$")
# now a regex to match brith year, rule dates and death year
birth_regex = re.compile(r"^\s*f[^\s]+(\s+ca.)?\s*(ukendt|[\d]+)")
# now for rule
rule_regex = re.compile(r".*regent[^\d]+(\d+)( - (senest\s*)?(\d+))?(\s*og\s*(\d+) - (\d+))?")
# now for death
death_regex = re.compile(r".*død[^\d]+([\d]+)")

for king in king_info_raw:
    if king == "":
        continue
    king_match = king_regex.match(king)
    if king_match:
        #reset variables
        king_birth = ''
        king_rule = ''
        king_death = ''
        king_rule_start = None
        king_second_rule_start = None
        king_rule_end = None
        king_second_rule_end = None
        king_death = ''
        # match the name regex
        king_name = king_match.group(1)
        if king_match.group(2) is not None:
          king_name += king_match.group(2)
        king_name = king_name.strip()
        # if there's trailing info then we can look for the dates
        if king_match.group(5) is not None:
          # get the whole date string e.g. født ca. 1080, regent 1104 - 1107, død 1131
          king_dates_raw = king_match.group(5)
          # get the birth year
          birth_match = birth_regex.match(king_dates_raw)
          if birth_match:
            king_birth = birth_match.group(2)
            # if the birth year is unknown, just set it to empty (NA)
            if king_birth == 'ukendt':
                king_birth = ''
          # get the rule dates
          rule_match = rule_regex.match(king_dates_raw)
          if rule_match:
            king_rule_start = rule_match.group(1)
            king_rule_end = rule_match.group(4)
            
            if rule_match.group(6) is not None:
              king_second_rule_start = rule_match.group(6)
              king_second_rule_end = rule_match.group(7)
              # set the death the the end of rule by default
              if king_death == '':
                king_death = king_second_rule_end

            # set the death the the end of rule by default
            if king_death == '':
                king_death = king_rule_end
            
          # get the death year
          death_match = death_regex.match(king_dates_raw)
          if death_match:
            king_death = death_match.group(1)

          # now add all the info together

          # if the rule start is set but not end, this is actually the end date
          if king_rule_start is not None and king_rule_end is None:
            king_rule_end = king_rule_start
            king_rule_start = ''
          
          

          # if there's a second rule we need to add the king again with the new rule dates
          if king_second_rule_start is not None:
            king_info.append([king_name, king_second_rule_start, king_second_rule_end, king_birth, king_death])
          
          
          king_info.append([king_name, king_rule_start, king_rule_end, king_birth, king_death])
        

print("Writing to csv")
with open("data/king_birth_deaths.csv", "w", encoding="utf8", newline='') as f:
    writer = csv.writer(f, delimiter=";")
    writer.writerow(["king", "rule_start", "rule_end", "birth", "death"])
    writer.writerows(king_info)
print("Done")