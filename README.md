# Life Expectancy — Exploratory Data Analysis

## Overview

This project explores global life expectancy patterns using a country-year panel dataset spanning 2000–2015. It examines the relationships between life expectancy and health indicators, economic development, vaccination coverage, and regional trends. All analysis is conducted in R using the tidyverse ecosystem.

## Structure

```
life-expectancy/
├── README.md
├── .gitignore
├── scripts/
│   ├── 01_eda.R     # Main analysis: data cleaning, transformation, and all EDA plots
│   └── theme.R      # Custom ggplot2 theme (sourced by 01_eda.R)
└── data/            # Not included — see Data section below
```

## Data

Data is not included in this repository.

The analysis uses `Life-Expectancy-Data-Updated.csv`, an updated version of the WHO Life Expectancy dataset. It contains country-year observations with variables including life expectancy, adult and infant mortality rates, vaccination coverage (Hepatitis B, Polio, Diphtheria), BMI, alcohol consumption, GDP per capita, schooling years, population, and regional and development-status classifications.

The dataset is publicly available on Kaggle:
[https://www.kaggle.com/datasets/lashagoch/life-expectancy-who-updated](https://www.kaggle.com/datasets/lashagoch/life-expectancy-who-updated)

Place the downloaded file at `data/Life-Expectancy-Data-Updated.csv` before running the scripts.

## Usage

1. Download the dataset from Kaggle and place it at `data/Life-Expectancy-Data-Updated.csv`.
2. Open an R session with the project root as the working directory.
3. Run `scripts/01_eda.R` to reproduce all cleaning, transformation, and exploratory plots.
