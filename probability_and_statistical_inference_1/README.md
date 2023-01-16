# :bicyclist: Statistical Tests on Bike Sharing Dataset: Project Overview

* Select the right statistical test to determine whether a predictor variable has a statistically significant relationship with an outcome variable
* [Report explaining the results](https://github.com/ayanoyamamoto0/assignments_2022-2023/blob/main/probability_and_statistical_inference_1/probability_and_statistical_inference_1.pdf)

## Code and Resources Used
* Environment: R kernel on Jupyter notebook
* R Version: 4.2.1
* Packages: tidyverse, cowplot, ggpubr, semTools, FSA, e1071, psych, car, effectsize, gmodels, sjstats

## Results
* Using the Pearson correlation test, a strong positive relationship was found between the temperature (actual) and the total number of bikes hired per day
* Using the Pearson correlation test, a weak negative correlation was found between the level of humidity and the total number of bikes hired per day
* Using the independent-samples t-test, no relationship was found between the total number of bikes hired per day and whether a day is a regular weekday or a weekend
* Using the one-way between-groups analysis of variance (ANOVA), no relationship was found between the total number of bikes hired per day and the day of the week
* Using the Chi-square test, a relationship was found between the weather situation and the season
