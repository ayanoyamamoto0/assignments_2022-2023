# :hospital: Factors Driving Nurse Emigration: Project Overview
* Created explanatory visualisations of factors related to a trend of Irish-trained nurses emigrating abroad
* Collected and wrangled data sources on hospital beds, nurses' wages, and waiting lists

## Code and Resources Used
* Environment: R kernel on Jupyter notebook
* R Version: 4.2.1
* Packages: dplyr, tidyverse, ggplot2, countrycode, zoo, ggrepel, reshape2, here, maps, mapproj, sf
* [Hospital beds (per 1,000 people) dataset](https://data.worldbank.org/indicator/SH.MED.BEDS.ZS?end=2019&start=1960)
* [Remuneration of health professionals dataset](https://stats.oecd.org/index.aspx?queryid=30025)
* [Average annual wages dataset](https://stats.oecd.org/Index.aspx?QueryId=25148#)
* [Waiting list by hospital dataset](https://data.ehealthireland.ie/dataset/inpatient-day-case-waiting-list/resource/bacaa1aa-5415-4ffa-afa8-f8717981cfbe)
* [Shapefile of Ireland](https://data.gov.ie/en_GB/dataset/administrative-areas-osi-national-statutory-boundaries-2019-generalised-20m)
* Relevant Article 1: [*Why we emigrated: Irish healthcare professionals on what pushed them to leave*](https://www.thejournal.ie/nurses-doctors-emigrating-ireland-australia-pay-work-conditions-5760900-May2022/)
* Relevant Article 2: [*'This stops now' – Simon Harris promises 'revolutionary' new training courses will stem exodus of young nurses to UK*](https://www.independent.ie/irish-news/education/this-stops-now-simon-harris-promises-revolutionary-new-training-courses-will-stem-exodus-of-young-nurses-to-uk/42427622.html)

## Data Cleaning
* Removed the variables where missing data represent more than 10% of the total
* Removed the countries with missing fixed variables, or where missing data represent more than 10% of daily updated variables
* Removed observations from dates before 2020-04-01 and after 2022-10-18
* The rest of the missing data were imputated using LOCF (last observation carried forward) and NOCB (next observation carried backward)
* Analysed that the mergning and cleaning steps have introduced a sampling bias to under-represent countries with smaller populations and slightly lower GDP per capita

## Data Analysis
* There is a moderate correlation between the yearly total sunshine duration in a country and their total confirmed cases
* Government Response Stringency Index on the other hand has no effect on the country's total confirmed cases
* Cross-correlation between two different time series, monthly sunshine duration and monthly confirmed cases, show that 30.89% of countries have high correlation, 55.28% of countries have medium correlation, and 13.82% of countries have low correlation. None of the countries were found to have no correlation.
* When looking at this cross-correlation by continents, countries in Europe have the highest correlation between monthly sunshine duration and monthly confirmed cases.
* Sunshine duration could potentially be useful to predict COVID cases in the future, especially for countries with moderate to high correlations.

#### Categorised correlations grouped by continents
<img src="https://github.com/ayanoyamamoto0/assignments_2022-2023/blob/main/working_with_data_1/correlation_bar.png" width=40% height=40%>

#### Highest correlation: Czech Republic
<img src="https://github.com/ayanoyamamoto0/assignments_2022-2023/blob/main/working_with_data_1/czech_republic_cross_correlation.png" width=40% height=40%>

#### Lowest correlation: Venezuela
<img src="https://github.com/ayanoyamamoto0/assignments_2022-2023/blob/main/working_with_data_1/venezuela_cross_correlation.png" width=40% height=40%>

