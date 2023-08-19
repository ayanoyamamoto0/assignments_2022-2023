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

## Data Wrangling
* Hospital beds data: Removed years where there are no data for Ireland, dropped countries that are missing more than 30% of the years, and restructured the dataframe.
* Nurses wage data: Filtered the dataframe, dropped unnecessary columns, and renamed columns.
* Nurses wage data alternative visualisation: Merged the nurses wage data with average wage data.
* Hospital waiting list data: Converted data formats, filtered the dataframe, dropped unnecessary columns. Merged it with hospital geolocation data, and converted the latitude/longitude coordinate system to the Irish Transverse Mercator (ITM) coordinate system (IRENET95).
* Shapefile of Ireland: Filtered the dataframe to County Dublin and Dublin city to create maps with increased zoom.

## Visualisations
#### Decline of Hospital Beds per 1,000 People
<img src="https://github.com/ayanoyamamoto0/assignments_2022-2023/blob/main/data_visualisation_2/hospital_beds_per_1000.png" width=40% height=40%>

#### Comparison of Nurses' Wages and Average Wages
<img src="https://github.com/ayanoyamamoto0/assignments_2022-2023/blob/main/data_visualisation_2/income_per_average_wage.png" width=40% height=40%>

#### Map of Inpatient/Day Case Waiting Lists
<img src="https://github.com/ayanoyamamoto0/assignments_2022-2023/blob/main/data_visualisation_2/hospital_waiting_list.png" width=40% height=40%>

