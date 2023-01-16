# :iphone: Telecom Customer Churn: Project Overview
* Designed and implemented a data warehouse for a telecom company
* Data analysis and queries using SQL
* Two machine learning models (Support Vector Machine and Generalised Linear Model) using SQL
* [Report explaining the design and implementation](https://github.com/ayanoyamamoto0/assignments_2022-2023/blob/main/working_with_data_2/working_with_data_2.pdf)

## Code and Resources Used
* Environment: Oracle SQL Developer on Docker image
* Oracle SQL Developer Version: 22.2.1.234.1810

## Data Cleaning
* Removed 1 row from `customers.csv` with duplicate phone number
* Removed 32 remaining rows where `contract_start_date` is later than `contract_end_date`
* Removed e 5,690 rows for calls where the `call_date` is earlier than `contract_start_date`

## Model Building
* Classification models used
  * Support Vector Machine
  * Generalised Linear Model
* Evaluation methods used
  * Confusion Matrix
  * F1 score
* Attempts to correct the data imbalance
  * Class weights tables with the best `class_weight` values

## Model Performance
Generalised Linear Model outperformed Support Vector Machine, although both models struggled with performance even after `class_weight` values were optimised. Further tuning and evaluation of the models' settings are required.
