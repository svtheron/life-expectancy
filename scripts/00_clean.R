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

data <- read.csv("data/Life-Expectancy-Data-Updated.csv")

data_clean <- data |>
  clean_names() |>
  mutate(
    economy_status = if_else(economy_status_developed == 1, "Developed", "Developing"),
    economy_status = factor(economy_status)
  ) |>
  select(-economy_status_developed, -economy_status_developing) |>
  mutate(
    log_gdp = log(gdp_per_capita),
    .after = gdp_per_capita
  ) |>
  mutate(
    bmi_category = case_when(
      bmi < 18.5             ~ "Underweight",
      bmi >= 18.5 & bmi < 25 ~ "Normal weight",
      bmi >= 25  & bmi < 30  ~ "Overweight",
      bmi >= 30              ~ "Obese"
    ),
    .after = bmi
  ) |>
  as_tibble()
