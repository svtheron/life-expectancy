# ============================================================
# Title:   Life Expectancy — Exploratory Data Analysis
# Purpose: Explore the life expectancy panel dataset
# Inputs:  data/Life-Expectancy-Data-Updated.csv (via scripts/00_clean.R)
# Outputs: Console summaries and plots (interactive, not saved to disk)
# ============================================================

# 1. SETUP & IMPORT -----------------------------------------------------------

if (!require("pacman", quietly = TRUE)) {
  install.packages("pacman")
  library(pacman)
}

p_load(tidyverse, ggridges, ggthemes)

source("scripts/00_clean.R")
source("scripts/theme.R")

glimpse(data_clean)

# 2. EDA ------------------------------------------------------------------

# 2.1 Summary statistics and distributions ------------------------------------

summary(data_clean)

data_clean |>
  summarise(across(everything(), ~sum(is.na(.)))) |>
  glimpse()

data_clean |>
  ggplot(aes(x = life_expectancy)) +
  geom_density() +
  theme_classic() +
  labs(
    title = "Distribution of life expectancy",
    x = "Life expectancy",
    y = "Density"
  )

data_clean |>
  ggplot(aes(x = life_expectancy, colour = economy_status)) +
  geom_density() +
  theme_classic() +
  labs(
    title  = "Distribution of life expectancy by economy status",
    x      = "Life expectancy",
    y      = "Density",
    colour = "Economy status"
  )

data_clean |>
  ggplot(aes(x = region, y = life_expectancy, colour = region)) +
  geom_boxplot() +
  coord_flip() +
  labs(
    title = "Life expectancy by region",
    x     = "Region",
    y     = "Life expectancy"
  ) +
  theme_classic() +
  scale_colour_brewer(palette = "Set1")

# 2.2 Relationships between key predictors and life expectancy ----------------

data_clean |>
  ggplot(aes(x = log_gdp, y = life_expectancy, colour = economy_status)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", se = FALSE) +
  theme_classic()

data_clean |>
  ggplot(aes(x = log_gdp, y = life_expectancy, colour = region)) +
  geom_point(alpha = 0.6) +
  theme_classic() +
  scale_colour_brewer(palette = "Paired")

data_clean |>
  filter(bmi_category == "Obese") |>
  ggplot(aes(x = alcohol_consumption, y = adult_mortality, colour = bmi_category)) +
  geom_point() +
  theme_classic() +
  scale_colour_brewer(palette = "Paired")

# 2.3 Regional trends ---------------------------------------------------------

regional_trends <- data_clean |>
  summarise(
    avg_hep        = mean(hepatitis_b),
    avg_measles    = mean(measles),
    avg_polio      = mean(polio),
    avg_diphtheria = mean(diphtheria),
    avg_hiv        = mean(incidents_hiv),
    .by = c(region, year)
  )

regional_trends |>
  pivot_longer(
    cols      = starts_with("avg_"),
    names_to  = "indicator",
    values_to = "value"
  ) |>
  ggplot(aes(x = year, y = value, colour = region)) +
  geom_line() +
  facet_wrap(~indicator, scales = "free_y") +
  labs(
    title  = "Health Indicators Over Time by Region",
    x      = "Year",
    y      = NULL,
    colour = "Region"
  ) +
  theme_minimal()

outcome_trends <- data_clean |>
  summarise(
    avg_life_expec      = mean(life_expectancy),
    avg_schooling       = mean(schooling),
    avg_adult_mortality = mean(adult_mortality),
    avg_youth_mortality = mean(under_five_deaths),
    .by = c(region, year)
  ) |>
  pivot_longer(
    cols      = starts_with("avg_"),
    names_to  = "indicator",
    values_to = "value"
  )

outcome_trends |>
  ggplot(aes(x = year, y = value, colour = region)) +
  geom_line() +
  facet_wrap(~indicator, scales = "free_y") +
  labs(
    title  = "Health Outcomes Over Time by Region",
    x      = "Year",
    y      = NULL,
    colour = "Region"
  ) +
  theme_minimal()

# 2.4 Additional visualisations -----------------------------------------------

# Mortality by region and BMI category (heatmap)
data_clean |>
  filter(bmi_category != "Obese") |>
  summarise(
    avg_mortality = mean(adult_mortality, na.rm = TRUE),
    .by = c(region, bmi_category)
  ) |>
  ggplot(aes(x = bmi_category, y = region, fill = avg_mortality)) +
  geom_tile() +
  scale_fill_distiller(palette = "Reds", direction = 1) +
  labs(
    title = "Adult Mortality by Region and BMI Category",
    x     = "BMI Category",
    y     = NULL,
    fill  = "Avg Adult Mortality"
  ) +
  theme_minimal()

# GDP and adult mortality density
data_clean |>
  ggplot(aes(x = log_gdp, y = adult_mortality)) +
  geom_bin2d(bins = 40) +
  scale_fill_distiller(palette = "YlOrRd", direction = 1) +
  labs(
    title = "GDP & Adult Mortality: Observation Density",
    x     = "Log GDP",
    y     = "Adult mortality",
    fill  = "Count"
  ) +
  theme_minimal()

# Infant deaths by region
data_clean |>
  ggplot(aes(x = region, y = infant_deaths, colour = region)) +
  geom_jitter(alpha = 0.6, width = 0.4) +
  scale_colour_brewer(palette = "Set3") +
  coord_flip() +
  labs(title = "Infant deaths by region") +
  theme_minimal()

# Wealth, population, and life expectancy — Rosling-style bubble chart (2015)
data_clean |>
  filter(year == 2015) |>
  ggplot(aes(
    x      = log_gdp,
    y      = life_expectancy,
    size   = population_mln,
    colour = region
  )) +
  geom_point(alpha = 0.8) +
  scale_size_area(max_size = 10) +
  scale_colour_brewer(palette = "Set3") +
  labs(
    title  = "Wealth, Population and Life Expectancy (2015)",
    x      = "GDP per Capita (log)",
    y      = "Life Expectancy",
    size   = "Population (mln)",
    colour = "Region"
  ) +
  theme_hc(base_family = "Atkinson Hyperlegible")

# Schooling and adult mortality by region (2010–2015)
data_clean |>
  filter(year %in% 2010:2015) |>
  ggplot(aes(x = schooling, y = adult_mortality, colour = region)) +
  geom_point(alpha = 0.6) +
  geom_smooth(se = FALSE) +
  facet_wrap(~region) +
  theme_minimal()

# Vaccination coverage vs life expectancy
data_clean |>
  pivot_longer(
    cols      = c(hepatitis_b, polio, diphtheria),
    names_to  = "vaccine",
    values_to = "coverage"
  ) |>
  ggplot(aes(x = coverage, y = life_expectancy, colour = economy_status)) +
  geom_point(alpha = 0.2) +
  geom_smooth(method = "lm", se = FALSE) +
  facet_wrap(~vaccine) +
  scale_colour_brewer(palette = "Set2") +
  labs(
    title  = "Vaccination Coverage vs Life Expectancy",
    x      = "Coverage (%)",
    y      = "Life Expectancy",
    colour = "Economy Status"
  ) +
  theme_minimal()

# Mortality outcomes by GDP
data_clean |>
  pivot_longer(
    cols      = c(infant_deaths, under_five_deaths, adult_mortality),
    names_to  = "outcome",
    values_to = "value"
  ) |>
  ggplot(aes(x = log_gdp, y = value, colour = economy_status)) +
  geom_point(alpha = 0.4) +
  facet_wrap(~outcome) +
  scale_colour_brewer(palette = "Set2") +
  theme_minimal()

# Correlation heatmap of all numeric variables
cor_matrix <- data_clean |>
  select(where(is.numeric)) |>
  cor(use = "complete.obs")

cor_long <- cor_matrix |>
  as.data.frame() |>
  tibble::rownames_to_column("var1") |>
  pivot_longer(
    cols      = -var1,
    names_to  = "var2",
    values_to = "correlation"
  )

cor_long |>
  ggplot(aes(x = var1, y = var2, fill = correlation)) +
  geom_tile() +
  scale_fill_distiller(palette = "PiYG", direction = 1) +
  labs(
    title = "Correlation Heatmap of All Numeric Variables",
    fill  = "Correlation",
    x     = NULL,
    y     = NULL
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Life expectancy distribution by region — violin + boxplot overlay
data_clean |>
  ggplot(aes(
    x    = fct_reorder(region, life_expectancy, .fun = median),
    y    = life_expectancy,
    fill = region
  )) +
  geom_violin(alpha = 0.6, trim = FALSE) +
  geom_boxplot(width = 0.15, fill = "white", outlier.shape = NA) +
  coord_flip() +
  scale_fill_brewer(palette = "Set3") +
  labs(
    title = "Life Expectancy Distribution by Region",
    x     = NULL,
    y     = "Life Expectancy (years)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# Life expectancy distribution by region — ridge plot
data_clean |>
  ggplot(aes(
    x    = life_expectancy,
    y    = fct_reorder(region, life_expectancy, .fun = median),
    fill = after_stat(x)
  )) +
  geom_density_ridges_gradient(scale = 2, rel_min_height = 0.01) +
  scale_fill_viridis_c(option = "magma", direction = -1) +
  labs(
    title = "Life Expectancy Distribution by Region",
    x     = "Life Expectancy (years)",
    y     = NULL,
    fill  = "Life Expectancy"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# Regional distributions across key indicators — small multiples ridge plot
data_clean |>
  select(region, life_expectancy, alcohol_consumption,
         log_gdp, schooling, adult_mortality, infant_deaths) |>
  pivot_longer(
    cols      = -region,
    names_to  = "indicator",
    values_to = "value"
  ) |>
  ggplot(aes(
    x    = value,
    y    = fct_reorder(region, value, .fun = median),
    fill = after_stat(x)
  )) +
  geom_density_ridges_gradient(scale = 2, rel_min_height = 0.01) +
  scale_fill_viridis_c(option = "magma", direction = -1) +
  facet_wrap(~indicator, scales = "free_x") +
  labs(
    title = "Regional Distributions Across Key Indicators",
    x     = NULL,
    y     = NULL
  ) +
  theme_minimal() +
  theme(legend.position = "none", panel.grid = element_blank())
