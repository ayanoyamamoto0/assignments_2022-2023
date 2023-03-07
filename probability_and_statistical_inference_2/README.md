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
A Factor Analysis (FA) was conducted on the 30 items with Maximum Likelihood and orthogonal rotation (varimax). Bartlett’s test of sphericity, χ^2(435) = 3869.183, p < .001, indicated that correlations between items were sufficiently large for FA. An initial analysis was run to obtain eigenvalues for each component in the data. 3 components had eigenvalues over Kaiser’s criterion of 1, and in combination explained 39.13% of the variance (Kaiser, 1960). The scree plot showed inflexions that would justify retaining 4 factors.

<img src="https://github.com/ayanoyamamoto0/assignments_2022-2023/blob/main/probability_and_statistical_inference_2/scree_plot.png" width=40% height=40%>

Given the large sample size, 4 components were retained in the second analysis, of which one contained fewer than 3 items and has been eliminated from further consideration. Component 1 represents extroversion, component 2 is openness, and component 3 is agreeableness. All three components have acceptable reliability (extroversion, Cronbach’s α = 0.71; openness, Cronbach’s α = 0.79; agreeableness, Cronbach’s α = 0.76).

## Linear Regression
