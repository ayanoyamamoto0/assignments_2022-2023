# :chart_with_upwards_trend: Dimension Reduction and Regression Models

* Reverse-code answers from negatively worded questions of the IPIP Big-Five 50 item Questionnaire, assess the suitability of the dataset and conduct a dimension reduction
* Build a linear regression model and assess its fit and usefulness
* Build a binary logistic regression model and assess its fit and usefulness
* Remove one predictor  from the linear regression model and compare results
* [Report explaining the results](https://github.com/ayanoyamamoto0/assignments_2022-2023/blob/main/probability_and_statistical_inference_2/probability_and_statistical_inference_2.pdf)

## Code and Resources Used
* Environment: R kernel on Jupyter notebook
* R Version: 4.2.1
* Packages: tidyverse, naniar, missMethods, psych, GPArotation, rstatix, stargazer, car, effectsize, Epi, regclass, DescTools, arm, generalhoslem, visreg

## Dimension Reduction
Bartlett’s test of sphericity, χ^2(435) = 3869.183, p < .001, indicated that correlations between items were sufficiently large.

An initial Factor Analysis was run to obtain eigenvalues for each component in the data. 3 components had eigenvalues over Kaiser’s criterion of 1, and in combination explained 39.13% of the variance. The scree plot showed inflexions that would justify retaining 4 factors. Given the large sample size, 4 components were retained in the second analysis.

<img src="https://github.com/ayanoyamamoto0/assignments_2022-2023/blob/main/probability_and_statistical_inference_2/scree_plot.png" width=40% height=40%>

After eliminating features based on loadings, communalities, and Cronbach’s α, the final components are extroversion (E2, E4, E6), openness (O2, O4, O7, O8, O9, O10), and agreeableness (A1, A3, A5, A7, A9). They all have acceptable reliability (extroversion, Cronbach’s α = 0.71; openness, Cronbach’s α = 0.79; agreeableness, Cronbach’s α = 0.76) as outlined in George &
Mallery (2010).

## Linear Regression
