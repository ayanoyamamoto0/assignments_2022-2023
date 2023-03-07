# :chart_with_upwards_trend: Dimension Reduction and Regression Models

* Reverse-code answers from negatively worded questions of the IPIP Big-Five 50 item Questionnaire, assess the suitability of the dataset and conduct a dimension reduction
* Build a linear regression model from the Bike Sharing dataset and assess its fit and usefulness
* Build a binary logistic regression model from the Bike Sharing dataset  and assess its fit and usefulness
* Remove one predictor from the linear regression model and compare results
* [Report explaining the results](https://github.com/ayanoyamamoto0/assignments_2022-2023/blob/main/probability_and_statistical_inference_2/probability_and_statistical_inference_2.pdf)

## Code and Resources Used
* Environment: R kernel on Jupyter notebook
* R Version: 4.2.1
* Packages: tidyverse, naniar, missMethods, psych, GPArotation, rstatix, stargazer, car, effectsize, Epi, regclass, DescTools, arm, generalhoslem, visreg

## Dimension Reduction
A Factor Analysis (FA) was conducted on the 30 items with Maximum Likelihood and orthogonal rotation (varimax).

Bartlett’s test of sphericity, χ^2(435) = 3869.183, p < .001, indicated that correlations between items were sufficiently large for FA. An initial analysis was run to obtain eigenvalues for each component in the data. 3 components had eigenvalues over Kaiser’s criterion of 1, and in combination explained 39.13% of the variance (Kaiser, 1960). The scree plot showed inflexions that would justify retaining 4 factors.

<img src="https://github.com/ayanoyamamoto0/assignments_2022-2023/blob/main/probability_and_statistical_inference_2/scree_plot.png" width=40% height=40%>

Given the large sample size, 4 components were retained in the second analysis, of which one contained fewer than 3 items and has been eliminated from further consideration. Component 1 represents extroversion, component 2 is openness, and component 3 is agreeableness. All three components have acceptable reliability (extroversion, Cronbach’s α = 0.71; openness, Cronbach’s α = 0.79; agreeableness, Cronbach’s α = 0.76).

## Linear Regression
A multiple regression analysis was conducted to determine if the temperature (actual), the weather situation, and the level of humidity could predict the number of bikes hired per day. The fitted regression model was:

cnt = 2239. 7 + 6551. 3 * temp − 368. 8 * weathersit2 − 2106. 0 * weathersit3 − 1262. 7 * hum

The regression model explains 45.39% of the variance and is statistically significant (Adjusted R^2 = 0.4539, F(4, 725) = 152.5, p < .001).

Having a higher temperature (actual) has a positive effect (β = 6551.3, p < .001) on the number of bikes hired per day.

Having the weather situation of 2 has a negative differential effect (β = -368.8, p = .00872) compared to having the weather situation of 1. Having the weather situation of 3 also has a negative differential effect (β = -2106.0, p < .001) compared to having the weather situation of 1, and the effect is larger than the weather situation of 2.

Having a higher level of humidity has a negative effect (β = -1262.7, p = 0.01119) on the number of bikes hired per day.

## Binary Logistic Regression
