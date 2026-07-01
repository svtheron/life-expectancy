# ============================================================
# Title:   Report Figures
# Purpose: Produce the small set of polished plots used in README.md
# Inputs:  data/Life-Expectancy-Data-Updated.csv (via scripts/00_clean.R)
# Outputs: PNG files written to figures/
# ============================================================

# 1. SETUP ---------------------------------------------------------------

if (!require("pacman", quietly = TRUE)) {
  install.packages("pacman")
  library(pacman)
}

p_load(tidyverse, scales)

source("scripts/00_clean.R")
source("scripts/theme.R")

dir.create("figures", showWarnings = FALSE)

accent_colour <- "#2c7fb8"

# 2. FIGURES ---------------------------------------------------------------

# 2.1 Global life expectancy over time (new) --------------------------------

p_global_trend <- data_clean |>
  summarise(avg_life_expectancy = mean(life_expectancy), .by = year) |>
  ggplot(aes(x = year, y = avg_life_expectancy)) +
  geom_line(colour = accent_colour, linewidth = 1) +
  geom_point(colour = accent_colour, size = 1.8) +
  scale_x_continuous(breaks = breaks_pretty(8)) +
  labs(
    title    = "Global life expectancy is rising",
    subtitle = "Average across all countries, 2000–2015",
    x        = NULL,
    y        = "Life expectancy (years)"
  ) +
  my_theme()

ggsave("figures/01_global_trend.png", p_global_trend, width = 8, height = 5, dpi = 300)

# 2.2 Average life expectancy by region, 2015 (new) -------------------------

p_region_bar <- data_clean |>
  filter(year == 2015) |>
  summarise(avg_life_expectancy = mean(life_expectancy), .by = region) |>
  ggplot(aes(
    x    = fct_reorder(region, avg_life_expectancy),
    y    = avg_life_expectancy,
    fill = region
  )) +
  geom_col() +
  coord_flip() +
  scale_fill_viridis_d() +
  labs(
    title    = "Where people live longest",
    subtitle = "Average life expectancy by region, 2015",
    x        = NULL,
    y        = "Life expectancy (years)"
  ) +
  my_theme() +
  theme(legend.position = "none")

ggsave("figures/02_region_bar.png", p_region_bar, width = 8, height = 5, dpi = 300)

# 2.3 Life expectancy: developed vs developing -------------------------------

p_density <- data_clean |>
  ggplot(aes(x = life_expectancy, fill = economy_status, colour = economy_status)) +
  geom_density(alpha = 0.4) +
  scale_fill_viridis_d() +
  scale_colour_viridis_d() +
  labs(
    title    = "Developed countries live longer, on average",
    subtitle = "Distribution of life expectancy, 2000–2015",
    x        = "Life expectancy (years)",
    y        = "Density",
    fill     = "Economy status",
    colour   = "Economy status"
  ) +
  my_theme()

ggsave("figures/03_developed_vs_developing.png", p_density, width = 8, height = 5, dpi = 300)

# 2.4 Life expectancy spread within each region -------------------------------

p_region_violin <- data_clean |>
  ggplot(aes(
    x    = fct_reorder(region, life_expectancy, .fun = median),
    y    = life_expectancy,
    fill = region
  )) +
  geom_violin(alpha = 0.6, trim = FALSE) +
  geom_boxplot(width = 0.15, fill = "white", outlier.shape = NA) +
  coord_flip() +
  scale_fill_viridis_d() +
  labs(
    title    = "Life expectancy gaps within regions",
    subtitle = "Distribution of life expectancy by region, 2000–2015",
    x        = NULL,
    y        = "Life expectancy (years)"
  ) +
  my_theme() +
  theme(legend.position = "none")

ggsave("figures/04_region_spread.png", p_region_violin, width = 8, height = 5, dpi = 300)

# 2.5 Wealth, population and life expectancy, 2015 ----------------------------

p_bubble <- data_clean |>
  filter(year == 2015) |>
  ggplot(aes(
    x      = log_gdp,
    y      = life_expectancy,
    size   = population_mln,
    colour = region
  )) +
  geom_point(alpha = 0.8) +
  scale_size_area(max_size = 12, guide = "none") +
  scale_colour_viridis_d() +
  labs(
    title    = "Richer countries tend to live longer",
    subtitle = "Wealth, population and life expectancy, 2015 (bubble size = population)",
    x        = "GDP per capita (log scale)",
    y        = "Life expectancy (years)",
    colour   = "Region"
  ) +
  my_theme()

ggsave("figures/05_wealth_bubble.png", p_bubble, width = 8, height = 5.5, dpi = 300)

# 2.6 Vaccination coverage vs life expectancy ----------------------------------

p_vaccine <- data_clean |>
  pivot_longer(
    cols      = c(hepatitis_b, polio, diphtheria),
    names_to  = "vaccine",
    values_to = "coverage"
  ) |>
  mutate(vaccine = str_to_title(str_replace(vaccine, "_", " "))) |>
  ggplot(aes(x = coverage, y = life_expectancy, colour = economy_status)) +
  geom_point(alpha = 0.15) +
  geom_smooth(method = "lm", se = FALSE) +
  facet_wrap(~vaccine) +
  scale_colour_viridis_d() +
  labs(
    title    = "Vaccinated countries tend to live longer",
    subtitle = "Childhood vaccination coverage vs life expectancy",
    x        = "Coverage (%)",
    y        = "Life expectancy (years)",
    colour   = "Economy status"
  ) +
  my_theme()

ggsave("figures/06_vaccination.png", p_vaccine, width = 9, height = 5, dpi = 300)
