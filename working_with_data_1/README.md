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
* Removed the countries with missing fixed variables, or where missing data represent more than 10% of daily updated variables
* Removed observations from dates before 2020-04-01 and after 2022-10-18
* The rest of the missing data were imputated using LOCF (last observation carried forward) and NOCB (next observation carried backward)
* Analysed that the mergning and cleaning steps have introduced a sampling bias to under-represent countries with smaller populations and slightly lower GDP per capita

## Data Analysis
* There is a moderate correlation between the yearly total sunshine duration in a country and their total confirmed cases.
* Government Response Stringency Index on the other hand has no effect on the country's total confirmed cases.
* Cross-correlation between two different time series, monthly sunshine duration and monthly confirmed cases, show that 30.89% of countries have high correlation, 55.28% of countries have medium correlation, and 13.82% of countries have low correlation. None of the countries were found to have no correlation.
* When looking at this cross-correlation by continents, countries in Europe have the highest correlation between monthly sunshine duration and monthly confirmed cases.
* Sunshine duration could potentially be useful to predict COVID cases in the future, especially for countries with moderate to high correlations.

#### Categorised correlations grouped by continents
<img src="https://github.com/ayanoyamamoto0/assignments_2022-2023/blob/main/working_with_data_1/correlation_barchart.png" width=40% height=40%>

