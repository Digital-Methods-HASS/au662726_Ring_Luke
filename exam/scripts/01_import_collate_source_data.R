# Import EMDAT data and population data.
#
# Source: EM-DAT, CRED / UCLouvain, Brussels, Belgium – www.emdat.be
# https://public.emdat.be/data
#
# Data variables:
#
# See "EM-DAT Guidelines: Data Entry, Field Description/Definition" from
# https://public.emdat.be/about#panel1a-content
# 
# Archived version: https://web.archive.org/web/20221109081840/https://public.emdat.be/about
# Downloaded on 2023-01-04
# Data not included due to license restrictions, but is free for non-commercial use.
# (see the above page for license details)
#
# World population data from UN World Population Prospects 2022
# Population 1950-2021, 2022-2100
# United Nations, Department of Economic and Social Affairs, Population Division (2022). World Population Prospects 2022, Online Edition.
# https://population.un.org/wpp/Download/Standard/CSV/
#
# Licencse: CC BY 3.0 IGO
#
# Data Variables:
# - SortOrder (numeric): record counter
# - LocID (numeric): numeric code for the location; for countries and areas, it follows the ISO 3166-1 numeric standard
# - Notes (string): symbol linked to location notes file (available for download below)
# - ISO3_code (string): ISO 3166-1 alpha-3 location codes
# - ISO2_code (string): ISO 3166-1 alpha-2 location codes
# - SDMX_code (string): SDMX Global Registry, cross domain code list for geographical areas (version 2.0) represents a combination of reference area codes in M49 and ISO-3166 classification for international data exchange and interoperability https://sdmx.org/?page_id=3215 and https://registry.sdmx.org/ws/public/sdmxapi/rest/codelist/SDMX/CL_AREA/2.0
# - LocTypeID (numeric): code for location type
# - LocTypeName (string): type of location
# - ParentID (numeric): numeric code of the parent location
# - Location (string): name of the region, subregion, country or area
# - VarID (numeric): numeric code for the scenario
# - Variant (string): projection scenario name (Medium is the most used); for more information see Definition of Projection Scenarios
# - Time (numeric): year the data refers to
# - MidPeriod (numeric): numeric value identifying the mid period of the data, with the decimal representing the month (e.g. 1950.5 for July of 1950)
#
#
#
# GDP and additional data from World Bank
# https://databank.worldbank.org/source/world-development-indicators#
# Description of the data is available in the "data/source/WorldBank_Extract_World_Development_Indicators_Metadata.csv" file.
#
# License: CC BY 4.0
#


library(tidyverse)

# source files
emdat_file <- "data/source/emdat_public_2023_01_04.tsv"
un_population_file_1950 <- "data/source/WPP2022_TotalPopulationBySex.zip"
un_population_file_2022 <- "data/source/WPP2022_Population1JanuaryBySingleAgeSex_Medium_2022-2100.zip"
worldbank_file <- "data/source/WorldBank_Extract_World_Development_indicators_Data.csv"

# destination file
processed_data_file <- "data/processed/disasters_top_impacted_by_country.csv"

# read the data
EMDAT <- read_tsv(
    emdat_file,
    skip = 6,
    col_types = cols(
        `Dis No` = col_character(),
        Year = col_double(),
        Seq = col_character(),
        Glide = col_character(),
        `Disaster Group` = col_factor(),
        `Disaster Subgroup` = col_factor(),
        `Disaster Type` = col_factor(),
        `Disaster Subtype` = col_factor(),
        `Disaster Subsubtype` = col_factor(),
        `Event Name` = col_character(),
        Country = col_factor(),
        ISO = col_factor(),
        Region = col_factor(),
        Continent = col_factor(),
        Location = col_character(),
        Origin = col_character(),
        `Associated Dis` = col_character(),
        `Associated Dis2` = col_character(),
        `OFDA Response` = col_character(),
        Appeal = col_character(),
        Declaration = col_character(),
        `AID Contribution ('000 US$)` = col_double(),
        `Dis Mag Value` = col_double(),
        `Dis Mag Scale` = col_character(),
        Latitude = col_character(),
        Longitude = col_character(),
        `Local Time` = col_character(),
        `River Basin` = col_character(),
        `Start Year` = col_double(),
        `Start Month` = col_double(),
        `Start Day` = col_double(),
        `End Year` = col_double(),
        `End Month` = col_double(),
        `End Day` = col_double(),
        `Total Deaths` = col_double(),
        `No Injured` = col_double(),
        `No Affected` = col_double(),
        `No Homeless` = col_double(),
        `Total Affected` = col_double(),
        `Reconstruction Costs ('000 US$)` = col_double(),
        `Reconstruction Costs, Adjusted ('000 US$)` = col_double(),
        `Insured Damages ('000 US$)` = col_double(),
        `Insured Damages, Adjusted ('000 US$)` = col_double(),
        `Total Damages ('000 US$)` = col_double(),
        `Total Damages, Adjusted ('000 US$)` = col_double(),
        CPI = col_character(),
        `Adm Level` = col_character(),
        `Admin1 Code` = col_character(),
        `Admin2 Code` = col_character(),
        `Geo Locations` = col_character()
))

# now let's keep only the columns we need
# for ease of campiarison, we will use the
# adjusted values

EMDAT <- EMDAT %>%
    select(
        `Dis No`,
        Year,
        `Disaster Subgroup`,
        `Disaster Type`,
        `Disaster Subtype`,
        `Disaster Subsubtype`,
        `Event Name`,
        Country,
        ISO,
        Region,
        Continent,
        Location,
        Latitude,
        Longitude,
        `Start Year`,
        `Start Month`,
        `Start Day`,
        `End Year`,
        `End Month`,
        `End Day`,
        `Total Deaths`,
        `No Injured`,
        `No Affected`,
        `No Homeless`,
        `Total Affected`,
        `Reconstruction Costs, Adjusted ('000 US$)`,
        `Insured Damages, Adjusted ('000 US$)`,
        `Total Damages, Adjusted ('000 US$)`,
        CPI
    )

# we now need to attach the population data
# to the EMDAT data

# first load the population data, both the 1950-2021 and 2022-2100 (for 2022 only)
# we will use the 2022-2100 data for the 2022 population, and the 1950-2021 data
# for the 1950-2021 population

un_population_data_1950 <- read_csv(un_population_file_1950)
un_population_data_2022 <- read_csv(un_population_file_2022)
# only keep 2022 data from 2022-2100
un_population_data_2022 <- un_population_data_2022 %>%
    filter(Time == 2022)

# let's check that the ISO codes are the same in both datasets
em_iso <- unique(EMDAT$ISO)
un_iso <- unique(un_population_data_1950$ISO3_code)
contrast_iso <- setdiff(em_iso, un_iso)
print(paste("There are", length(contrast_iso), "ISO codes that are not in both datasets"))

# there are 11 codes that are not in both datasets
# "DFR" "AZO" "ANT" "CSK" "SUN" "SPI" "YMN" "YUG" "YMD" "DDR" "SCG"
# we will have to ignore them because there's data  missing and some
# like Yugoslavia which no longer exists

# now we need to merge the data
# we will use the ISO code and year / time as the key
# first, we need to rename the UN "Location" column to "PopulationLocation"

un_population_data <- bind_rows(un_population_data_1950, un_population_data_2022)

# clean up memory
rm(un_population_data_1950, un_population_data_2022)

# now join the data, inner join will keep only the data that is in both datasets
disasters_population <- EMDAT %>%
    inner_join(un_population_data, by = c("ISO" = "ISO3_code", "Year" = "Time"))

# remove unnecessary columns
disasters_population <- disasters_population %>%
    select(-PopFemale, -PopMale, -LocID, -LocTypeName, -ParentID)

# we have 217 countries and 73 years of data
n_years <- length(unique(disasters_population$Year))
n_countries <- length(unique(disasters_population$ISO))
print(paste0("We have ", n_years, " years of data and ", n_countries, " countries"))

# clean up memory
rm(n_years, n_countries, EMDAT, contrast_iso, em_iso, un_iso)


# Finally, we need to add on the WorldBank data

# first, we need to load the data
wb_data <- read_csv(worldbank_file)

# Now we should be able to join on `Country Code` to ISO
# and Time to Year

# first remove NAs and metadata rows
wb_data <- wb_data %>%
    filter(
        !is.na(Time) &
        Time != "Data from database: World Development Indicators" &
        Time != "Last Updated: 12/22/2022")

wb_data$Time <- as.numeric(wb_data$Time)

disasters_population_wb <- disasters_population %>%
    inner_join(wb_data, by = c("ISO" = "Country Code", "Year" = "Time"))

# clean up memory
rm(wb_data, disasters_population)

# Population numbers are in thousands, so we need to multiply by 1000
disasters_population_wb$Population <- disasters_population_wb$PopTotal * 1000

# let's calculate a % of population affected, and % population deaths

disasters_population_wb$`Affected_pct` <- disasters_population_wb$`Total Affected` / disasters_population_wb$PopTotal
disasters_population_wb$`Deaths_pct` <- disasters_population_wb$`Total Deaths` / disasters_population_wb$PopTotal

# now we can look at  the total affected, both by number and by percentage

# first, let's look at the total number of people affected (top 10)

top_10_affected <- disasters_population_wb %>%
    group_by(ISO) %>%
    summarise(`Total Affected` = sum(`Total Affected`, na.rm = TRUE), ISO = first(ISO)) %>%
    arrange(desc(`Total Affected`)) %>%
    head(10) %>%
    pull(ISO)

top_10_affected_pct <- disasters_population_wb %>%
    group_by(ISO) %>%
    summarise(`Affected_pct` = sum(`Affected_pct`, na.rm = TRUE), ISO = first(ISO)) %>%
    arrange(desc(`Affected_pct`)) %>%
    head(10) %>%
    pull(ISO)

top_10_deaths <- disasters_population_wb %>%
    group_by(ISO) %>%
    summarise(`Total Deaths` = sum(`Total Deaths`, na.rm = TRUE), ISO = first(ISO)) %>%
    arrange(desc(`Total Deaths`)) %>%
    head(10) %>%
    pull(ISO)

top_10_deaths_pct <- disasters_population_wb %>%
    group_by(ISO) %>%
    summarise(`Deaths_pct` = sum(`Deaths_pct`, na.rm = TRUE), ISO = first(ISO)) %>%
    arrange(desc(`Deaths_pct`)) %>%
    head(10) %>%
    pull(ISO)


# now let's plot all top 10s just to see what they look like

tmp <- data.frame(
    ISO = c(top_10_affected, top_10_affected_pct, top_10_deaths, top_10_deaths_pct),
    Type = c(rep("Total Affected", 10), rep("Affected_pct", 10), rep("Total Deaths", 10), rep("Deaths_pct", 10)),
    rank = c(rep(10:1, 4))
)

# calculate a simple weigted rank by summing the ranks by country
tmp$weighted_rank <- tmp %>%
    group_by(ISO) %>%
    mutate(weighted_rank = sum(rank)) %>%
    ungroup() %>%
    pull(weighted_rank)

tmp <- tmp %>%
    arrange(desc(weighted_rank), rank)

tmp$ISO <- factor(tmp$ISO, levels = unique(tmp$ISO[order(tmp$weighted_rank, decreasing = TRUE)]))
tmp %>%
    ggplot(aes(x = ISO, y = rank, fill = Type)) +
    geom_bar(stat = "identity", position = "dodge") +
    theme_minimal() +
    labs(x = "Country", y = "Rank", title = "Top 10 Countries by Total Affected, % Affected, Total Deaths, and % Deaths")

length(unique(tmp$ISO))

# now that we have this ranked list, we can take the top 20 countries
# which we will use for the rest of the analysis

top_n <- unique(tmp$ISO)


# now let's remove all the data except for the top 20 countries

disasters_population_wb <- disasters_population_wb %>%
    filter(ISO %in% top_n)

# clean up memory
rm(tmp, top_10_affected, top_10_affected_pct, top_10_deaths, top_10_deaths_pct, top_n)

# remove some final columns
disasters_population_wb <- disasters_population_wb %>%
    select(-AgeGrp, -AgeGrpStart, -AgeGrpSpan)


# save the data
write_csv(disasters_population_wb, processed_data_file)
