# ============================================================
# Title:   Data Import & Cleaning
# Purpose: Import the raw life expectancy data and produce a clean,
#          analysis-ready tibble (data_clean)
# Inputs:  data/Life-Expectancy-Data-Updated.csv
# Outputs: data_clean (tibble, in the calling environment)
# ============================================================

if (!require("pacman", quietly = TRUE)) {
  install.packages("pacman")
  library(pacman)
}

p_load(tidyverse, janitor)

data_path <- "data/Life-Expectancy-Data-Updated.csv"

if (!file.exists(data_path)) {
  stop(
    "Cannot find ", data_path, ".\n",
    "Download the dataset (see the Data section of README.md) and run the ",
    "scripts from the project root.",
    call. = FALSE
  )
}

data_raw <- read_csv(data_path, show_col_types = FALSE)

data_clean <- data_raw |>
  clean_names() |>
  mutate(
    economy_status = if_else(economy_status_developed == 1, "Developed", "Developing"),
    economy_status = factor(economy_status)
  ) |>
  select(-economy_status_developed, -economy_status_developing) |>
  mutate(
    africa_group = if_else(region == "Africa", "Africa", "Rest of world"),
    africa_group = factor(africa_group, levels = c("Africa", "Rest of world")),
    .after = region
  ) |>
  mutate(
    log_gdp = log(gdp_per_capita),
    .after = gdp_per_capita
  ) |>
  # Average coverage of the three vaccines (they move closely together)
  mutate(
    vaccination = (hepatitis_b + polio + diphtheria) / 3,
    .after = diphtheria
  ) |>
  mutate(
    bmi_category = case_when(
      bmi < 18.5             ~ "Underweight",
      bmi >= 18.5 & bmi < 25 ~ "Normal weight",
      bmi >= 25  & bmi < 30  ~ "Overweight",
      bmi >= 30              ~ "Obese"
    ),
    .after = bmi
  )
