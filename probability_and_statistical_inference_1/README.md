# :bicyclist: Statistical Tests on Bike Sharing Dataset: Project Overview

* Select the right statistical test to determine whether a predictor variable has a statistically significant relationship with an outcome variable
* [Report explaining the results](https://github.com/ayanoyamamoto0/assignments_2022-2023/blob/main/probability_and_statistical_inference_1/probability_and_statistical_inference_1.pdf)

## Code and Resources Used
* Environment: R kernel on Jupyter notebook
* R Version: 4.2.1
* Packages: tidyverse, cowplot, ggpubr, semTools, FSA, e1071, psych, car, effectsize, gmodels, sjstats

## Results
* A strong positive relationship was found between the temperature (actual) and the total number of bikes hired per day (Pearson correlation test)
* A weak negative correlation was found between the level of humidity and the total number of bikes hired per day (Pearson correlation test)
* No relationship was found between the total number of bikes hired per day and whether a day is a regular weekday or a weekend (independent-samples t-test)
* No relationship was found between the total number of bikes hired per day and the day of the week (ANOVA)
* A relationship was found between the weather situation and the season (Chi-square test)
