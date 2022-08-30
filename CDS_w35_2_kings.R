library(tidyverse)

# make sure danish characters load correctly
loc <- locale(encoding = "ISO-8859-15")

# read in data
king_data <- read_csv2("data/kings.csv", locale = loc,
  col_types = c(
   "c",
   "i",
   "i",
   "c" # has the word "unknown"
  ))

# filter NA values
king_data <- king_data[!is.na(king_data$Start_date), ]
king_data <- king_data[!is.na(king_data$End_date), ]

# now that the unknowns have gone, convert to numeric
king_data$Yearasruler <- as.numeric(king_data$Yearasruler)
# caluclate mean and median ruling time
mean_years_ruling <- mean(king_data$Yearasruler)
median_years_ruling <- median(king_data$Yearasruler)

mean_years_ruling
median_years_ruling

# find the top 3 kings with the most years ruling
top_3_ruling <-
  king_data[
    order(
      king_data$Yearasruler,
      decreasing = TRUE)[1:3], ]

paste(
  top_3_ruling$Kings, ", ",
  top_3_ruling$Yearasruler, " years",
  collapse = "; ")

top_3_ruling

# convert start date to a date type
top_3_ruling$Start_date <- as.Date(
  paste0(
    top_3_ruling$Start_date,
    "-01-01"),
  format = "%Y-%m-%d")

# convert end date to a date type
top_3_ruling$End_date <- as.Date(
  paste0(
    top_3_ruling$End_date,
    "-01-01"),
  format = "%Y-%m-%d")

# calculate the days spent ruling
days_ruling <- difftime(
  top_3_ruling$End_date,
  top_3_ruling$Start_date,
  units = "days")

# add the top three kings' ruling days together
total_days_ruling <- sum(days_ruling)

total_days_ruling
