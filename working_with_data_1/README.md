# :sun_behind_small_cloud: Sunshine Duration and Covid Cases: Project Overview
* Analysed the correlation between new Covid cases and the sunshine duration.

## Code and Resources Used
* R Version: 4.2.1
* Packages: tidyverse, data.table, rvest, countrycode, zoo, gridExtra, ggpubr
* Covid-19 Dataset: https://github.com/owid/covid-19-data/tree/master/public/data
* List of Cities by Sunshine Duration: https://en.wikipedia.org/wiki/List_of_cities_by_sunshine_duration
* Relevant Article: https://www.nature.com/articles/s41598-021-81419-w

## Data Cleaning
* Removed the variables where missing data represent more than 10% of the total
* Removed the countries with missing fixed variables
* Removed the counrtries where missing data represent more than 10% of daily updated variables.
