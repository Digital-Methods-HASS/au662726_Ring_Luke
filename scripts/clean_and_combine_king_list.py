###
# utility to remove kings from a csv that don't have an end year
###


import os
import pandas as pd

kings_rule = "data/king_list.csv"
kings_life = "data/king_birth_deaths.csv"

# if either file doesn't exist, exit
if not (os.path.isfile(kings_rule) or os.path.isfile(kings_life)):
    print("Files don't exist, exiting")
    exit(0)

# the kings_rule is the definitive list, we will join their birth and death dates to this list

# read the kings_rule file into a pandas dataframe

df_kings_rule = pd.read_csv(kings_rule, sep=";", dtype=str)

# df_kings_rule = df_kings_rule.iloc[::-1]

# remove the king "interregnum"
df_kings_rule = df_kings_rule[df_kings_rule["king"] != "Interregnum"]
# remove the king "Margrethe 2."
df_kings_rule = df_kings_rule[df_kings_rule["king"] != "Margrethe 2."]

# reverse the order of the rows
df_kings_rule = df_kings_rule.iloc[::-1]
# reset row indices
df_kings_rule = df_kings_rule.reset_index(drop=True)


# read the kings_life file into a pandas dataframe
df_kings_life = pd.read_csv(kings_life, sep=";", dtype=str)


# remove the king "Hardeknud  / (Knud 1.)"
df_kings_life = df_kings_life[df_kings_life["king"] != "Hardeknud  / (Knud 1.)"]
# remove the king "Knud 5."
df_kings_life = df_kings_life[df_kings_life["king"] != "Knud 5."]

# rename "king" to "name"
df_kings_life = df_kings_life.rename(columns={"king": "name"})


df_kings_life = df_kings_life.reset_index(drop=True)

# now switch the rows for Christoffer 2. and Valdemar 4. Atterdag
print(df_kings_life.index[df_kings_life["name"] == "Christoffer 2."])
print(df_kings_life.index[df_kings_life["name"] == "Valdemar 4."])

df_kings_all = pd.concat([df_kings_rule, df_kings_life], axis="columns")

print(df_kings_all[['name', 'king', 'end', 'death']])
# left join kings life to kings rule
# df_kings_life = df_kings_life.join(df_kings_life, on="ID", lsuffix="_life", rsuffix="_rule")
# print(df_kings_life.columns)

# print(df_kings_life[["birth_rule", "birth_life"]])

# print the dataframe
# print(df_kings_life)
