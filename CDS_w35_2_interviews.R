library(tidyverse)

# check if dirs exist if not create them
project_dirs <- c("data", "output", "figures")

for (dir in project_dirs) {
  if (!dir.exists(dir)) {
    dir.create(dir)
  }
}

# download CSV file if it's not already present
safi_data_file <- "data/SAFI_clean.csv"

if (!file.exists(safi_data_file)) {
  download.file(
    "https://ndownloader.figshare.com/files/11492171",
    "data/SAFI_clean.csv",
    mode = "wb")
}

interviews <- read_csv(safi_data_file)

n_interviews <- nrow(interviews)

interviews_100 <- interviews[100, ]

interviews_last <- interviews[n_interviews, ]

interviews_last == tail(interviews, 1)

interviews_middle <- interviews[floor(n_interviews / 2), ]

head(interviews, 5) == interviews[1:5, ]

