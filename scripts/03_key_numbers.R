# ============================================================
# Title:   Key Numbers
# Purpose: Print every number quoted in README.md so each claim can be checked
# Inputs:  data/Life-Expectancy-Data-Updated.csv (via scripts/00_clean.R)
# Outputs: Console summary
# ============================================================

# 1. SETUP ---------------------------------------------------------------

source("scripts/00_clean.R")

heading <- function(x) cat("\n", x, "\n", strrep("-", nchar(x)), "\n", sep = "")

show <- function(label, value, digits = 1) {
  cat(sprintf("%-55s %s\n", label, format(round(value, digits), nsmall = digits)))
}

by_country <- data_clean |>
  filter(year %in% c(2000, 2015)) |>
  pivot_wider(
    id_cols      = c(country, region, africa_group),
    names_from   = year,
    values_from  = life_expectancy,
    names_prefix = "le_"
  ) |>
  mutate(gain = le_2015 - le_2000)

by_region <- by_country |>
  summarise(across(c(le_2000, le_2015, gain), mean), .by = region)

by_group <- by_country |>
  summarise(across(c(le_2000, le_2015, gain), mean), .by = africa_group)

# 2. NUMBERS ---------------------------------------------------------------

# 2.1 Almost everyone gained years --------------------------------------------

heading("1. Almost everyone gained years")
show("Average country, 2000 (years)", mean(by_country$le_2000))
show("Average country, 2015 (years)", mean(by_country$le_2015))
show("Average country, gain (years)", mean(by_country$gain))
show("Countries that gained", sum(by_country$gain > 0), 0)
show("Countries that fell or stayed flat", sum(by_country$gain <= 0), 0)
show("Countries in total", nrow(by_country), 0)

# 2.2 Africa gained the most --------------------------------------------------

africa <- filter(by_region, region == "Africa")
eu     <- filter(by_region, region == "European Union")
rest   <- filter(by_group, africa_group == "Rest of world")

heading("2. Africa gained the most")
show("Africa, 2000 (years)", africa$le_2000)
show("Africa, 2015 (years)", africa$le_2015)
show("Africa, gain (years)", africa$gain)
show("Rest of world, gain (years)", rest$gain)
show("Next-largest regional gain (years)", max(by_region$gain[by_region$region != "Africa"]))
show("EU minus Africa, 2000 (years)", eu$le_2000 - africa$le_2000)
show("EU minus Africa, 2015 (years)", eu$le_2015 - africa$le_2015)
show("Top 10 gainers that are in Africa", sum(slice_max(by_country, gain, n = 10)$region == "Africa"), 0)
show("Largest country gain (years)", max(by_country$gain))

# 2.3 Wealth buys years, but not equally --------------------------------------

income_2015 <- filter(data_clean, year == 2015)

income_fit <- lm(
  life_expectancy ~ log10(gdp_per_capita) + africa_group,
  data = income_2015
)

fifths <- income_2015 |>
  mutate(fifth = ntile(gdp_per_capita, 5)) |>
  summarise(life_expectancy = mean(life_expectancy), .by = fifth) |>
  arrange(fifth)

heading("3. Wealth buys years, but not equally")
show("Poorest fifth of countries, 2015 (years)", fifths$life_expectancy[1])
show("Richest fifth of countries, 2015 (years)", fifths$life_expectancy[5])
show("Africa gap at the same income (years)", unname(coef(income_fit)["africa_groupRest of world"]))

# 2.4 Vaccination goes with longer lives --------------------------------------

developing_2015 <- filter(income_2015, economy_status == "Developing")
developed_2015  <- filter(income_2015, economy_status == "Developed")
vaccine_fit     <- lm(life_expectancy ~ vaccination, data = developing_2015)

heading("4. Vaccination goes with longer lives")
show("Developing, years per +10 points of coverage", 10 * coef(vaccine_fit)[["vaccination"]])
show("Developing, correlation with life expectancy", cor(developing_2015$vaccination, developing_2015$life_expectancy), 2)
show("Developed, average coverage 2015 (%)", mean(developed_2015$vaccination))

# 2.5 What changed in Africa --------------------------------------------------

africa_change <- data_clean |>
  filter(region == "Africa", year %in% c(2000, 2015)) |>
  summarise(
    across(c(vaccination, under_five_deaths, incidents_hiv), mean),
    .by = year
  ) |>
  arrange(year)

pct_change <- function(x) 100 * (x[2] / x[1] - 1)

heading("5. What changed in Africa, 2000 to 2015")
show("Vaccination coverage, change (points)", diff(africa_change$vaccination))
show("Under-five deaths, change (%)", pct_change(africa_change$under_five_deaths), 0)
show("New HIV infections, change (%)", pct_change(africa_change$incidents_hiv), 0)
