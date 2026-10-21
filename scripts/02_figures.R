# ============================================================
# Title:   Report Figures
# Purpose: Produce the five figures that tell the story in README.md
# Inputs:  data/Life-Expectancy-Data-Updated.csv (via scripts/00_clean.R)
# Outputs: PNG files written to figures/
# ============================================================

# 1. SETUP ---------------------------------------------------------------

if (!require("pacman", quietly = TRUE)) {
  install.packages("pacman")
  library(pacman)
}

p_load(tidyverse, scales, ggrepel, ragg)

source("scripts/00_clean.R")
source("scripts/theme.R")

dir.create("figures", showWarnings = FALSE)

font          <- pick_font()
group_colours <- c("Africa" = col_africa, "Rest of world" = col_rest)

note_source <- sprintf("Source: WHO, via Kaggle (%d countries).", n_distinct(data_clean$country))
note_mean   <- paste(note_source, "Averages are unweighted.")

save_fig <- function(plot, file, height = 5) {
  ggsave(
    file.path("figures", file), plot,
    width = 8, height = height, dpi = 200, device = ragg::agg_png
  )
}

# 2. FIGURES ---------------------------------------------------------------

# 2.1 Almost every country gained years ---------------------------------------

world_trend <- data_clean |>
  summarise(life_expectancy = mean(life_expectancy), .by = year)

world_2000 <- world_trend$life_expectancy[world_trend$year == 2000]
world_2015 <- world_trend$life_expectancy[world_trend$year == 2015]

gain_paths <- data_clean |>
  mutate(gain = life_expectancy - life_expectancy[year == 2000], .by = country)

group_paths <- gain_paths |>
  summarise(gain = mean(gain), .by = c(africa_group, year))

final_gain <- gain_paths |>
  filter(year == 2015)

end_labels <- bind_rows(
  slice_max(final_gain, gain) |>
    transmute(africa_group, gain, label = sprintf("%s +%.1f", country, gain)),
  group_paths |>
    filter(year == 2015) |>
    transmute(africa_group, gain, label = sprintf("%s +%.1f", africa_group, gain)),
  slice_min(final_gain, gain) |>
    transmute(
      africa_group, gain,
      label = sprintf("%s −%.1f", str_replace(country, "Syrian Arab Republic", "Syria"), abs(gain))
    )
) |>
  mutate(year = 2015)

p_trend <- gain_paths |>
  ggplot(aes(x = year, y = gain, colour = africa_group)) +
  geom_hline(yintercept = 0, colour = col_ink, linewidth = 0.4) +
  geom_line(aes(group = country), linewidth = 0.35, alpha = 0.35) +
  geom_line(data = group_paths, linewidth = 2) +
  geom_text_repel(
    data = end_labels, aes(label = label),
    hjust = 0, nudge_x = 0.4, direction = "y", fontface = "bold", size = 4.2,
    segment.colour = NA, seed = 1, family = font
  ) +
  scale_colour_manual(values = group_colours, guide = "none") +
  scale_x_continuous(
    breaks = c(2000, 2005, 2010, 2015),
    expand = expansion(mult = c(0.02, 0.3))
  ) +
  scale_y_continuous(
    breaks = seq(0, 15, 5),
    labels = label_number(style_positive = "plus", style_negative = "minus")
  ) +
  coord_cartesian(clip = "off") +
  labs(
    title    = sprintf("Life expectancy rose in %d of %d countries", sum(final_gain$gain > 0), nrow(final_gain)),
    subtitle = sprintf("Years gained since 2000, one line per country. The average country gained %.1f years.", world_2015 - world_2000),
    x        = NULL,
    y        = NULL,
    caption  = note_mean
  ) +
  my_theme()

save_fig(p_trend, "01_years_gained.png")

# 2.2 Africa gained the most --------------------------------------------------

region_change <- data_clean |>
  filter(year %in% c(2000, 2015)) |>
  summarise(life_expectancy = mean(life_expectancy), .by = c(region, year)) |>
  pivot_wider(
    names_from   = year,
    values_from  = life_expectancy,
    names_prefix = "le_"
  ) |>
  mutate(
    gain   = le_2015 - le_2000,
    group  = if_else(region == "Africa", "Africa", "Rest of world"),
    region = fct_reorder(region, le_2015)
  )

top_region    <- slice_max(region_change, le_2015)
africa_region <- filter(region_change, region == "Africa")
africa_gap    <- top_region$le_2015 - africa_region$le_2015
arrow_start   <- africa_region$le_2015 + 5.5

stopifnot(as.character(top_region$region) == "European Union")

p_regions <- region_change |>
  ggplot(aes(y = region, colour = group)) +
  geom_segment(
    aes(x = le_2000, xend = le_2015),
    linewidth = 3.2, lineend = "round", alpha = 0.3
  ) +
  geom_point(aes(x = le_2000), shape = 21, fill = "white", size = 4, stroke = 1.3) +
  geom_point(aes(x = le_2015), size = 5) +
  geom_text(
    aes(x = le_2015, label = sprintf("+%.1f", gain)),
    nudge_x = 1.2, hjust = 0, fontface = "bold", size = 4.4, family = font
  ) +
  annotate(
    "text", x = c(top_region$le_2000, top_region$le_2015),
    y = nlevels(region_change$region) + 0.65, label = c("2000", "2015"),
    colour = c(col_muted, col_ink), fontface = "bold", size = 3.8, family = font
  ) +
  annotate(
    "segment", x = arrow_start, xend = top_region$le_2015, y = 1, yend = 1,
    colour = col_ink, linewidth = 0.6,
    arrow = arrow(ends = "both", length = unit(0.08, "in"))
  ) +
  annotate(
    "text", x = (arrow_start + top_region$le_2015) / 2, y = 1.42,
    label = sprintf("%.0f years behind the EU", africa_gap),
    colour = col_ink, fontface = "bold", size = 4, family = font
  ) +
  scale_colour_manual(values = group_colours, guide = "none") +
  scale_x_continuous(limits = c(50, 86), breaks = seq(50, 85, 5)) +
  scale_y_discrete(labels = label_wrap(18), expand = expansion(add = c(0.6, 1))) +
  labs(
    title    = "Africa gained the most, but still trails the EU",
    subtitle = "Average life expectancy by region in 2000 and 2015. Labels show years gained.",
    x        = "Life expectancy (years)",
    y        = NULL,
    caption  = note_mean
  ) +
  my_theme() +
  theme(panel.grid.major.y = element_blank())

save_fig(p_regions, "02_region_gains.png")

# 2.3 Wealth buys years, but Africa trails at any income ----------------------

income_2015 <- data_clean |>
  filter(year == 2015)

income_fit <- lm(
  life_expectancy ~ log10(gdp_per_capita) + africa_group,
  data = income_2015
)

fit_lines <- income_2015 |>
  reframe(
    gdp_per_capita = 10^seq(log10(min(gdp_per_capita)), log10(max(gdp_per_capita)), length.out = 60),
    .by = africa_group
  ) |>
  mutate(life_expectancy = predict(income_fit, newdata = pick(gdp_per_capita, africa_group)))

gap_x <- 4000
gap_y <- predict(
  income_fit,
  newdata = tibble(
    gdp_per_capita = gap_x,
    africa_group   = factor(c("Africa", "Rest of world"), levels = levels(income_2015$africa_group))
  )
)

# Labelled countries; big bubbles (China, India) are nudged clear of their labels
label_spec <- tribble(
  ~country,        ~nudge_x, ~nudge_y,
  "China",            -0.12,      5.5,
  "India",             0.24,      0,
  "United States",     0,         0,
  "Japan",             0,         0,
  "Nigeria",           0,         0,
  "Bangladesh",        0,         0
)

income_labels <- income_2015 |>
  left_join(label_spec, by = "country") |>
  mutate(
    label    = if_else(is.na(nudge_x), "", country),
    nudge_x  = replace_na(nudge_x, 0),
    nudge_y  = replace_na(nudge_y, 0)
  )

p_wealth <- income_2015 |>
  ggplot(aes(x = gdp_per_capita, y = life_expectancy, colour = africa_group)) +
  geom_point(aes(size = population_mln), alpha = 0.65) +
  geom_line(data = fit_lines, linewidth = 1.2, show.legend = FALSE) +
  annotate(
    "segment", x = gap_x, xend = gap_x, y = gap_y[[1]], yend = gap_y[[2]],
    colour = col_ink, linewidth = 0.7,
    arrow = arrow(ends = "both", length = unit(0.09, "in"))
  ) +
  geom_text_repel(
    data = tibble(
      gdp_per_capita  = gap_x * 1.18,
      life_expectancy = mean(gap_y) + 1.2,
      label           = sprintf("about %.0f years", gap_y[[2]] - gap_y[[1]])
    ),
    aes(x = gdp_per_capita, y = life_expectancy, label = label),
    inherit.aes = FALSE, force = 0, hjust = 0,
    colour = col_ink, fontface = "bold", size = 4,
    bg.color = "white", bg.r = 0.2, seed = 1, family = font
  ) +
  geom_text_repel(
    data = income_labels, aes(label = label),
    nudge_x = income_labels$nudge_x, nudge_y = income_labels$nudge_y,
    colour = col_ink, size = 3.8, bg.color = "white", bg.r = 0.15,
    min.segment.length = 0.2, segment.colour = col_muted,
    box.padding = 0.6, max.overlaps = Inf, seed = 1, family = font
  ) +
  scale_size_area(max_size = 14, guide = "none") +
  scale_colour_manual(values = group_colours) +
  scale_x_log10(
    breaks = c(500, 1000, 2000, 5000, 10000, 20000, 50000, 100000),
    labels = label_dollar(scale_cut = cut_short_scale())
  ) +
  guides(colour = guide_legend(override.aes = list(size = 4, alpha = 1))) +
  labs(
    title    = "Wealth buys years, but Africa trails at any income",
    subtitle = "Life expectancy vs GDP per capita, 2015. Bubble size = population.",
    x        = "GDP per capita (log scale)",
    y        = "Life expectancy (years)",
    colour   = NULL,
    caption  = note_source
  ) +
  my_theme() +
  theme(legend.position = "top", legend.justification = "left")

save_fig(p_wealth, "03_wealth.png", height = 5.5)

# 2.4 Vaccination coverage goes with longer lives -----------------------------

vaccine_2015 <- data_clean |>
  filter(year == 2015) |>
  mutate(
    group = case_when(
      economy_status == "Developed" ~ "Developed",
      africa_group == "Africa"      ~ "Africa",
      .default                      = "Other developing"
    ),
    country = str_replace(country, "Syrian Arab Republic", "Syria")
  )

developing_2015 <- filter(vaccine_2015, economy_status == "Developing")
vaccine_slope   <- coef(lm(life_expectancy ~ vaccination, data = developing_2015))[["vaccination"]]

vaccine_colours <- c(
  "Africa"           = col_africa,
  "Other developing" = col_rest,
  "Developed"        = col_context
)

p_vaccine <- vaccine_2015 |>
  ggplot(aes(x = vaccination, y = life_expectancy, colour = group)) +
  geom_point(size = 2.8, alpha = 0.85) +
  geom_smooth(
    data = developing_2015, aes(group = 1),
    method = "lm", formula = y ~ x, se = FALSE,
    colour = col_ink, linewidth = 1
  ) +
  geom_text_repel(
    data = vaccine_2015,
    aes(label = if_else(country %in% c("Nigeria", "Syria", "Ukraine"), country, "")),
    colour = col_ink, size = 3.8, bg.color = "white", bg.r = 0.15,
    min.segment.length = 0.2, segment.colour = col_muted,
    box.padding = 0.5, max.overlaps = Inf, seed = 1, family = font
  ) +
  annotate(
    "text", x = 34, y = 82,
    label = sprintf("Developing countries:\neach +10 points of coverage\ngoes with ≈ +%.1f years", vaccine_slope * 10),
    colour = col_ink, hjust = 0, fontface = "bold", size = 4, lineheight = 0.95,
    family = font
  ) +
  scale_colour_manual(values = vaccine_colours, breaks = names(vaccine_colours)) +
  scale_x_continuous(limits = c(30, 100), labels = label_percent(scale = 1)) +
  labs(
    title    = "Higher vaccination coverage goes with longer lives",
    subtitle = "Average coverage of hepatitis B, polio and diphtheria vaccines, 2015",
    x        = "Vaccination coverage",
    y        = "Life expectancy (years)",
    colour   = NULL,
    caption  = note_source
  ) +
  my_theme() +
  theme(legend.position = "top", legend.justification = "left")

save_fig(p_vaccine, "04_vaccination.png")

# 2.5 What changed in Africa --------------------------------------------------

indicators <- c(
  "Life expectancy (years)",
  "Children vaccinated (%)",
  "Under-five deaths (per 1,000 births)",
  "New HIV infections (per 1,000 adults)"
)

drivers <- data_clean |>
  summarise(
    `Life expectancy (years)`               = mean(life_expectancy),
    `Children vaccinated (%)`               = mean(vaccination),
    `Under-five deaths (per 1,000 births)`  = mean(under_five_deaths),
    `New HIV infections (per 1,000 adults)` = mean(incidents_hiv),
    .by = c(africa_group, year)
  ) |>
  pivot_longer(
    cols      = all_of(indicators),
    names_to  = "indicator",
    values_to = "value"
  ) |>
  mutate(indicator = factor(indicator, levels = indicators))

africa_labels <- drivers |>
  filter(africa_group == "Africa", year %in% c(2000, 2015)) |>
  pivot_wider(names_from = year, values_from = value, names_prefix = "y") |>
  mutate(
    label = case_when(
      indicator == indicators[1] ~ sprintf("+%.1f yrs", y2015 - y2000),
      indicator == indicators[2] ~ sprintf("+%.0f pts", y2015 - y2000),
      .default                   = sprintf("%+.0f%%", 100 * (y2015 / y2000 - 1))
    ),
    label = str_replace(label, "-", "−")
  )

group_names <- drivers |>
  filter(indicator == indicators[1], year == 2000) |>
  mutate(
    label = as.character(africa_group),
    value = value + if_else(africa_group == "Africa", 2.4, -2.4)
  )

p_drivers <- drivers |>
  ggplot(aes(x = year, y = value, colour = africa_group)) +
  geom_line(linewidth = 1.4) +
  geom_blank(data = tibble(
    indicator    = factor(indicators[3:4], levels = indicators),
    year         = 2000,
    value        = 0,
    africa_group = "Africa"
  )) +
  geom_text(
    data = africa_labels, aes(x = 2015, y = y2015, label = label),
    hjust = -0.15, fontface = "bold", size = 4.2, family = font
  ) +
  geom_text(
    data = group_names, aes(label = label),
    hjust = 0, fontface = "bold", size = 4, family = font
  ) +
  facet_wrap(~indicator, scales = "free_y", ncol = 2) +
  scale_colour_manual(values = group_colours, guide = "none") +
  scale_x_continuous(
    breaks = c(2000, 2015),
    expand = expansion(mult = c(0.03, 0.3))
  ) +
  scale_y_continuous(expand = expansion(mult = c(0.05, 0.12))) +
  coord_cartesian(clip = "off") +
  labs(
    title    = "In Africa, lives got longer as child deaths fell",
    subtitle = "Vaccination rose while child deaths and new HIV infections fell (country averages).",
    x        = NULL,
    y        = NULL,
    caption  = note_mean
  ) +
  my_theme() +
  theme(panel.spacing = unit(1.4, "lines"))

save_fig(p_drivers, "05_africa_drivers.png", height = 5.5)
