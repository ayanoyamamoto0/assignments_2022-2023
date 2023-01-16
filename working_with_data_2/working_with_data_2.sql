DROP TABLE call_rates;
DROP TABLE calls;
DROP TABLE calls_combined;
DROP TABLE calls_fact;
DROP TABLE contract_plans;
DROP TABLE customer_dimension;
DROP TABLE customer_service;
DROP TABLE customers;
DROP TABLE customers_errors;
DROP TABLE date_dimension;
DROP TABLE rate_dimension;
DROP TABLE rate_types;
DROP TABLE social_grade;
DROP TABLE voicemails;

-- Section A: Data Warehouse Modelling -----------------------------------------

-- (a) IMPORT DATA FROM 8 CSV FILES --------------------------------------------

-- 1. Create a table structure for importing 'call_rates.csv'
CREATE TABLE call_rates (
  call_type_id NUMBER(1) NOT NULL,
  plan_id NUMBER(1) NOT NULL,
  cost_per_minute NUMBER(3, 2) NOT NULL,
  CONSTRAINT unq_call_rates UNIQUE (call_type_id, plan_id)
); -- please import 'call_rates.csv' here

-- 2. Create a table structure for importing 'calls.csv'
CREATE TABLE calls (
    phone_number VARCHAR2(13) NOT NULL,
    call_time TIMESTAMP NOT NULL,
    duration NUMBER NOT NULL,
    connection_id CHAR(36) NOT NULL,
    is_international VARCHAR(5),
    is_roaming VARCHAR(5),
    CONSTRAINT pk_calls PRIMARY KEY (connection_id)
); -- please import 'calls.csv' here 

-- 3. Create a table structure for importing 'contract_plans.csv'
CREATE TABLE contract_plans (
  id NUMBER(1) NOT NULL,
  name VARCHAR2(12) NOT NULL,
  CONSTRAINT pk_contract_plans PRIMARY KEY (id)
); -- please import 'contract_plans.csv' here

-- 4. Create a table structure for importing 'customer_service.csv'
CREATE TABLE customer_service (
    phone_number VARCHAR2(13) NOT NULL,
    call_time TIMESTAMP NOT NULL,
    duration NUMBER NOT NULL,
    connection_id CHAR(36) NOT NULL,
    call_type_id NUMBER(1),
    CONSTRAINT pk_customer_service PRIMARY KEY (connection_id)
); -- please import 'customer_service.csv' here 

-- 5. Create a table structure for importing 'customers.csv'
CREATE TABLE customers (
  phone_number VARCHAR2(13) NOT NULL,
  contract_start_date DATE NOT NULL,
  plan_id NUMBER(1) NOT NULL,
  contract_end_date DATE,
  nrs VARCHAR2(2) NOT NULL,
  dob DATE NOT NULL
); -- please import 'customers.csv' here 

-- 6. Create a table structure for importing 'rate_types.csv'
CREATE TABLE rate_types (
  id NUMBER(1) NOT NULL,
  name VARCHAR2(16) NOT NULL,
  CONSTRAINT pk_rate_types PRIMARY KEY (id)
); -- please import 'rate_types.csv' here

-- 7. Create a table structure for importing 'social_grade.csv'
CREATE TABLE social_grade (
  grade VARCHAR2(2) NOT NULL,
  social_class VARCHAR2(21) NOT NULL,
  CONSTRAINT pk_social_grade PRIMARY KEY (grade)
); -- please import 'social_grade.csv' here

-- 8. Create a table structure for importing 'voicemails.csv'
CREATE TABLE voicemails (    
    phone_number VARCHAR2(13) NOT NULL,
    call_time TIMESTAMP NOT NULL,
    duration NUMBER NOT NULL,
    connection_id CHAR(36) NOT NULL,
    call_type_id NUMBER(1),
    CONSTRAINT pk_voicemails PRIMARY KEY (connection_id)
); -- please import 'voicemails.csv' here 


-- (c) TRANSFORM INTO DATA-WAREHOUSE -------------------------------------------

-- CREATING THE RATE DIMENSION TABLE -------------------------------------------

--Create the rate dimention table
CREATE TABLE rate_dimension AS
    SELECT cr.call_type_id, rt.name AS call_type_name, cr.plan_id, cp.name AS plan_name, cr.cost_per_minute
        FROM call_rates cr
        JOIN rate_types rt ON cr.call_type_id = rt.id
        JOIN contract_plans cp ON cr.plan_id = cp.id;
    
ALTER TABLE rate_dimension ADD
    CONSTRAINT unq_rate_dimension UNIQUE (call_type_id, plan_id);


-- CREATING THE CUSTOMER DIMENSION TABLE ---------------------------------------

-- Check for duplicate phone numbers in customers
SELECT * FROM customers WHERE phone_number = (
    SELECT phone_number FROM customers
        GROUP BY phone_number HAVING COUNT (phone_number) > 1
); -- '01 495 7529' is in two rows

-- Create the customer dimension table
CREATE TABLE customer_dimension AS
    SELECT c.phone_number, c.contract_start_date, c.plan_id, c.contract_end_date, sg.social_class, c.dob
        FROM customers c
        JOIN social_grade sg ON c.nrs = sg.grade;

-- Delete the record with a later contract_start_date
DELETE FROM customer_dimension WHERE
    phone_number = '01 495 7529'
        AND contract_start_date = (
            SELECT MAX(contract_start_date) FROM customers
                WHERE phone_number = '01 495 7529'
);

-- Add columns to the customer dimension table
ALTER TABLE customer_dimension ADD (
    contract_years NUMBER,
    contract_terminated VARCHAR2(5),
    age NUMBER(3),
    CONSTRAINT pk_customer_dimension PRIMARY KEY (phone_number)
);

-- Fill the newly added columns
UPDATE customer_dimension SET 
    contract_years = 
        CASE WHEN contract_end_date IS NULL THEN ROUND(MONTHS_BETWEEN(sysdate, contract_start_date) / 12, 1)
             ELSE ROUND(MONTHS_BETWEEN(contract_end_date, contract_start_date) / 12, 1)
             END,
    contract_terminated =
        CASE WHEN contract_end_date IS NULL THEN 'FALSE'
             ELSE 'TRUE'
             END,
    age = FLOOR(MONTHS_BETWEEN(sysdate, dob) / 12);
    
-- Check for errors in contract_months
SELECT COUNT(contract_years) FROM customer_dimension
    WHERE contract_years < 0; -- 32 rows have contract_end_date before contract_start_date

-- Create a table or customer records with errors in contract_months
CREATE TABLE customers_errors AS
    SELECT * FROM customer_dimension WHERE contract_years < 0;

-- Drop 32 rows where contract_end_date is before contract_start_date
DELETE FROM customer_dimension WHERE
    contract_years < 0;


-- CREATING THE DATE DIMENSION TABLE -------------------------------------------

-- Check the oldest date from the calls, customer_service, and voicemails
SELECT MIN(call_time) AS oldest_date FROM calls
    JOIN customer_service USING (call_time)
    JOIN voicemails USING (call_time); -- the oldest date is 2021-01-01

-- Create the date dimension table of 5 years from 2021-01-01
CREATE TABLE date_dimension AS 
    SELECT DATE'2021-01-01' + LEVEL - 1 date_key FROM DUAL
        CONNECT BY LEVEL <= (
            DATE'2025-12-31' - DATE'2021-01-01' + 1
);

-- Add columns to the date dimension table
ALTER TABLE date_dimension ADD (
    year NUMBER(4),
    quarter NUMBER(1),
    yearmonth NUMBER(6),
    month NUMBER(2),
    week NUMBER(2),
    day NUMBER(2),
    day_of_week VARCHAR2(3),
    CONSTRAINT pk_dates PRIMARY KEY (date_key)
);

-- Populate the date dimension table
UPDATE date_dimension SET
    year = TO_CHAR(date_key, 'RRRR'),
    quarter = TO_CHAR(date_key, 'Q'),
    yearmonth = TO_CHAR(date_key, 'RRRRMM'),
    month = TO_CHAR(date_key, 'MM'),
    day = TO_CHAR(date_key, 'DD'),
    week = TO_CHAR(date_key, 'WW'),
    day_of_week = TO_CHAR(date_key, 'DY');


--CREATING THE CALLS FACT TABLE ------------------------------------------------

-- Create calls_combined table from calls
CREATE TABLE calls_combined AS 
    SELECT * FROM calls;

-- Add call_type_id column to calls_combined
ALTER TABLE calls_combined ADD 
    call_type_id NUMBER(1);

-- Populate call_type_id in calls_combined
UPDATE calls_combined SET call_type_id = 
    CASE WHEN is_international = 'TRUE' THEN 3
         WHEN is_roaming = 'TRUE' THEN 4
         WHEN (TO_CHAR(call_time, 'D') BETWEEN 1 AND 5)
            AND (TO_CHAR(call_time, 'HH24:MI')
                BETWEEN TO_CHAR(TO_DATE('9:00', 'HH24:MI'), 'HH24:MI')
                    AND TO_CHAR(TO_DATE('18:00', 'HH24:MI'), 'HH24:MI')) THEN 1
         ELSE 2
    END;

-- Drop is_international and is_roaming columns
ALTER TABLE calls_combined DROP (is_international, is_roaming);

-- Merge customer_service into calls_combined
MERGE INTO calls_combined cc
    USING customer_service cs 
    ON (cc.connection_id = cs.connection_id)
    WHEN NOT MATCHED
        THEN INSERT (connection_id, phone_number, call_time, duration, call_type_id)
        VALUES (cs.connection_id, cs.phone_number, cs.call_time, cs.duration, cs.call_type_id);

-- Merge voicemails into calls_combined
MERGE INTO calls_combined cc
    USING voicemails v
    ON (cc.connection_id = v.connection_id)
    WHEN NOT MATCHED
        THEN INSERT (connection_id, phone_number, call_time, duration, call_type_id)
        VALUES (v.connection_id, v.phone_number, v.call_time, v.duration, v.call_type_id);

-- Create the calls fact table
CREATE TABLE calls_fact AS
    SELECT cc.connection_id, 
           phone_number,
           TO_DATE(TO_CHAR(cc.call_time,'DD-MON-YY')) AS call_date,
           cc.duration, 
           cc.call_type_id, 
           cd.plan_id, 
           cc.duration * rd.cost_per_minute AS value
        FROM calls_combined cc
        LEFT JOIN customer_dimension cd USING (phone_number)
        LEFT JOIN rate_dimension rd ON cc.call_type_id = rd.call_type_id AND cd.plan_id = rd.plan_id
        ORDER BY cc.call_time ASC;

-- Check for phone numbers matching customers_errors (contract_end_date earlier than contract_start_date from "customers.csv")
SELECT COUNT(phone_number) FROM calls_fact
    WHERE phone_number IN (
        SELECT phone_number FROM customers_errors); -- 689 rows with phone numbers matching customers_errors
        
-- Drop 689 rows where phone numbers matches customers_errors
DELETE FROM calls_fact 
    WHERE phone_number IN (
        SELECT phone_number FROM customers_errors);
        
-- Check for call records before the contract_start_date
SELECT COUNT(connection_id) FROM calls_fact cf
    JOIN customer_dimension cd ON cf.phone_number = cd.phone_number
    WHERE cf.call_date < cd.contract_start_date; -- 5,690 rows with call_date preceding contract_start_date

-- Drop 5,690 rows where call time is before the contract start date
DELETE (
    SELECT cf.* FROM calls_fact cf
    JOIN customer_dimension cd ON cf.phone_number = cd.phone_number
    WHERE cf.call_date < cd.contract_start_date);

-- Check for call records after the contract_end_date
SELECT COUNT(connection_id) FROM calls_fact cf
    JOIN customer_dimension cd ON cf.phone_number = cd.phone_number
    WHERE cf.call_date > cd.contract_end_date; -- 0 calls after the end of contract

-- Add constraints to the calls fact table
ALTER TABLE calls_fact ADD(
    CONSTRAINT pk_calls_fact PRIMARY KEY (connection_id),
    CONSTRAINT fk_customer FOREIGN KEY (phone_number) REFERENCES customer_dimension(phone_number),
    CONSTRAINT fk_rate FOREIGN KEY (call_type_id, plan_id) REFERENCES rate_dimension(call_type_id, plan_id),
    CONSTRAINT fk_date FOREIGN KEY (call_date) REFERENCES date_dimension(date_key),
    CONSTRAINT not_null_call_date CHECK (call_date IS NOT NULL),
    CONSTRAINT not_null_call_type_id CHECK (plan_id IS NOT NULL),
    CONSTRAINT not_null_value CHECK (value IS NOT NULL)
);


-- Section B: Data Analysis and Queries Using SQL ------------------------------

-- a) DATA ANALYSIS ------------------------------------------------------------

-- Descriptive statistics for calls_fact table ---------------------------------

-- Call date
SELECT MIN(call_date) AS minimum_date,
       MAX(call_date) AS maximum_date,
       STATS_MODE(call_date) AS mode_date
       FROM calls_fact;

-- Duration
SELECT ROUND(MIN(duration), 2) AS minimum_duration, 
       ROUND(MAX(duration), 2) AS maximum_duration, 
       ROUND(AVG(duration), 2) AS mean_duratoin,
       ROUND(MEDIAN(duration), 2) AS median_duration
       FROM calls_fact;

-- Call type
SELECT cf.call_type_id,
       rd.call_type_name,
       COUNT(cf.call_type_id) AS count_of_call_type_id, 
       ROUND((100 * RATIO_TO_REPORT(COUNT(cf.call_type_id)) OVER()), 2) || '%' percentage
       FROM calls_fact cf
       JOIN rate_dimension rd ON cf.call_type_id = rd.call_type_id AND cf.plan_id = rd.plan_id
       GROUP BY cf.call_type_id, rd.call_type_name
       ORDER BY count_of_call_type_id DESC;

-- Plan
SELECT cf.plan_id,
       rd.plan_name,
       COUNT(cf.plan_id) AS count_of_plan_id, 
       ROUND((100 * RATIO_TO_REPORT(COUNT(cf.plan_id)) OVER()), 2) || '%' percentage
       FROM calls_fact cf
       JOIN rate_dimension rd ON cf.call_type_id = rd.call_type_id AND cf.plan_id = rd.plan_id
       GROUP BY cf.plan_id, rd.plan_name
       ORDER BY count_of_plan_id DESC;

-- Value
SELECT ROUND(MIN(value), 2) AS minimum_value, 
       ROUND(MAX(value), 2) AS maximum_value, 
       ROUND(AVG(value), 2) AS mean_value,
       ROUND(MEDIAN(value), 2) AS median_value
       FROM calls_fact;

-- Descriptive statistics for customer_dimension table -------------------------

-- Plan
SELECT cd.plan_id,
       rd.plan_name,
       COUNT(cd.plan_id) AS count_of_plan_id, 
       ROUND((100 * RATIO_TO_REPORT(COUNT(cd.plan_id)) OVER()), 2) || '%' percentage
       FROM customer_dimension cd
       JOIN rate_dimension rd ON cd.plan_id = rd.plan_id
       GROUP BY cd.plan_id, rd.plan_name
       ORDER BY count_of_plan_id DESC;

-- Social class
SELECT social_class,
       COUNT(social_class) AS count_of_social_class, 
       ROUND((100 * RATIO_TO_REPORT(COUNT(social_class)) OVER()), 2) || '%' percentage
       FROM customer_dimension
       GROUP BY social_class
       ORDER BY count_of_social_class DESC;

-- Contract years
SELECT ROUND(MIN(contract_years), 2) AS minimum_contract_years, 
       ROUND(MAX(contract_years), 2) AS maximum_contract_years, 
       ROUND(AVG(contract_years), 2) AS mean_contract_years,
       ROUND(MEDIAN(contract_years), 2) AS median_contract_years
       FROM customer_dimension;

-- Contract terminated boolean
SELECT contract_terminated,
       COUNT(contract_terminated) AS count_of_contract_terminated, 
       ROUND((100 * RATIO_TO_REPORT(COUNT(contract_terminated)) OVER()), 2) || '%' percentage
       FROM customer_dimension
       GROUP BY contract_terminated
       ORDER BY count_of_contract_terminated DESC;

-- Age
SELECT ROUND(MIN(age), 2) AS minimum_age, 
       ROUND(MAX(age), 2) AS maximum_age, 
       ROUND(AVG(age), 2) AS mean_age,
       ROUND(MEDIAN(age), 2) AS median_age
       FROM customer_dimension;

-- Cross-table analysis --------------------------------------------------------------------

-- Total value per call type and their percentage of overall revenue
SELECT rd.call_type_name,
       ROUND(SUM(cf.value), 2) AS total_value,
       ROUND((100 * RATIO_TO_REPORT(SUM(cf.value)) OVER()), 2) || '%' percentage_revenue
       FROM calls_fact cf
       JOIN rate_dimension rd ON cf.call_type_id = rd.call_type_id AND cf.plan_id = rd.plan_id
       GROUP BY rd.call_type_name
       ORDER BY total_value DESC;

-- Average age per social class and total value spent
SELECT cd.social_class,
       ROUND(AVG(cd.age), 2) AS mean_age,
       ROUND(SUM(cf.value), 2) AS total_value,
       ROUND((100 * RATIO_TO_REPORT(SUM(cf.value)) OVER()), 2) || '%' percentage_revenue
       FROM customer_dimension cd
       JOIN calls_fact cf ON cd.phone_number = cf.phone_number
       GROUP BY cd.social_class
       ORDER BY total_value DESC;
       
-- Most popular plan per age bracket
SELECT DISTINCT
       age_brackets,
       FIRST_VALUE(plan_name) OVER (PARTITION BY age_brackets ORDER BY count_of_plan_id DESC) AS most_popualr_plan,
       MAX(count_of_plan_id) OVER (PARTITION BY age_brackets) AS count
       FROM (
            SELECT (CASE WHEN cd.age BETWEEN 21 AND 40 THEN 'adult'
                        WHEN cd.age BETWEEN 41 AND 60 THEN 'middle age adult'
                        ELSE 'older adult' END) AS age_brackets,
                   rd.plan_name,
                   COUNT(cd.plan_id) AS count_of_plan_id
                   FROM customer_dimension cd
                   JOIN rate_dimension rd ON cd.plan_id = rd.plan_id
                   GROUP BY 
                       (CASE WHEN cd.age BETWEEN 21 AND 40 THEN 'adult'
                            WHEN cd.age BETWEEN 41 AND 60 THEN 'middle age adult'
                            ELSE 'older adult' END), rd.plan_name
            )          
       GROUP BY age_brackets, count_of_plan_id, plan_name;


-- b) SQL Queries --------------------------------------------------------------

-- Historical value of a customer
SELECT * FROM (
        SELECT phone_number,
               ROUND(SUM(value), 2) AS total_value,
               ROUND(PERCENT_RANK() OVER (ORDER BY SUM(value) DESC) * 100, 2) || '%' AS percent_rank
               FROM calls_fact
               GROUP BY phone_number)
        WHERE phone_number = '&phone_number';
 
-- Value of a customer from the most recent month (April 2021)
SELECT * FROM (
    SELECT cf.phone_number,
           ROUND(SUM(cf.value), 2) AS apr21_total_value,
           ROUND(PERCENT_RANK() OVER (ORDER BY SUM(cf.value) DESC) * 100, 2) || '%' percent_rank
           FROM calls_fact cf
           JOIN date_dimension dd ON cf.call_date = dd.date_key
           WHERE dd.yearmonth = 202104
           GROUP BY phone_number)
    WHERE phone_number = '&phone_number';


-- Customer profile
SELECT UNIQUE(cd.phone_number),
       rd.plan_name,
       cd.age,
       cd.social_class,
       cd.contract_years,
       cd.contract_terminated
       FROM customer_dimension cd
       JOIN rate_dimension rd ON cd.plan_id = rd.plan_id
       WHERE cd.phone_number = '&phone_number';

-- Type of calls customer makes, average duration & total value
SELECT cf.phone_number, 
       rd.call_type_name,
       COUNT(cf.call_type_id) AS call_type_count,
       ROUND(AVG(cf.duration), 2) AS avg_duration,
       ROUND(SUM(cf.value), 2) AS total_value
       FROM calls_fact cf
       JOIN rate_dimension rd ON cf.call_type_id = rd.call_type_id AND cf.plan_id = rd.plan_id
       WHERE cf.phone_number = '&phone_number'
       GROUP BY cf.phone_number, rd.call_type_name
       ORDER BY call_type_count DESC;

-- Number of customer service calls per month
SELECT cf.phone_number, 
       dd.year,
       dd.month,
       COUNT(cf.call_type_id) AS cs_calls 
       FROM calls_fact cf
       JOIN date_dimension dd ON cf.call_date = dd.date_key
       WHERE cf.call_type_id = 6
            AND phone_number = '&phone_number'
       GROUP BY cf.phone_number, dd.year, dd.month
       ORDER BY dd.year, dd.month ASC;

-- 3 months rolling average of monthly values
SELECT cf.phone_number,
       dd.year,
       dd.month,
       ROUND(SUM(value), 2) AS monthly_value,
       ROUND(AVG(SUM(value)) OVER
          (ORDER BY dd.month ROWS BETWEEN 3 PRECEDING AND CURRENT ROW),2) AS moving_average
       FROM calls_fact cf
       JOIN date_dimension dd ON cf.call_date = dd.date_key
       WHERE phone_number = '&phone_number'
       GROUP BY cf.phone_number, dd.year, dd.month
       ORDER BY dd.year, dd.month ASC;

-- Call plans which bring in the most revenue overall
SELECT rd.plan_name,
       ROUND(SUM(cf.value), 2) AS total_value,
       ROUND((100 * RATIO_TO_REPORT(SUM(cf.value)) OVER()), 2) || '%' percentage_revenue
       FROM calls_fact cf
       JOIN rate_dimension rd ON cf.call_type_id = rd.call_type_id AND cf.plan_id = rd.plan_id
       GROUP BY rd.plan_name
       ORDER BY total_value DESC;
       
-- Call plans which brought in the most revenue in April 2021
SELECT rd.plan_name,
       ROUND(SUM(cf.value), 2) AS total_value,
       ROUND((100 * RATIO_TO_REPORT(SUM(cf.value)) OVER()), 2) || '%' apr21_percentage_revenue
       FROM calls_fact cf
       JOIN rate_dimension rd ON cf.call_type_id = rd.call_type_id AND cf.plan_id = rd.plan_id
       JOIN date_dimension dd ON cf.call_date = dd.date_key
       WHERE dd.yearmonth = 202104
       GROUP BY rd.plan_name
       ORDER BY total_value DESC;
       

-- Section C: Machine Learning using SQL ---------------------------------------

-- a) CREATE CASE TABLE & TRAIN TEST SPLIT -------------------------------------

-- Create a case table as a view
CREATE OR REPLACE VIEW case_table AS
    SELECT CONCAT(CONCAT(cf.phone_number, '-'), dd.yearmonth) as id,
           dd.yearmonth,
           COUNT(cf.connection_id) AS total_calls,
           SUM(cf.duration) AS total_duration,
           SUM(cf.value) AS total_value,
           COUNT(CASE WHEN cf.call_type_id = 1 THEN 1 END) AS peak_calls,
           COUNT(CASE WHEN cf.call_type_id = 2 THEN 1 END) AS off_peak_calls,
           COUNT(CASE WHEN cf.call_type_id = 3 THEN 1 END) AS international_calls,
           COUNT(CASE WHEN cf.call_type_id = 4 THEN 1 END) AS roaming_calls,
           COUNT(CASE WHEN cf.call_type_id = 5 THEN 1 END) AS voicemail_calls,
           COUNT(CASE WHEN cf.call_type_id = 6 THEN 1 END) AS cs_calls,
           cd.plan_id,
           cd.social_class,
           cd.age,
           ROUND(MONTHS_BETWEEN(LAST_DAY(TO_DATE(dd.yearmonth, 'RRRRMM')), cd.contract_start_date), 2) AS contract_months,
           (CASE WHEN 
                cd.contract_end_date = 
                ADD_MONTHS(TO_DATE(dd.yearmonth, 'RRRRMM'), 1) THEN 1 ELSE 0 END) AS next_month_churn
           FROM calls_fact cf
           JOIN customer_dimension cd ON cf.phone_number = cd.phone_number
           JOIN date_dimension dd ON cf.call_date = dd.date_key
           GROUP BY cf.phone_number, dd.yearmonth, cd.plan_id, cd.social_class, cd.age, cd.contract_start_date, cd.contract_end_date
           ORDER BY cf.phone_number;

-- Check for imbalance
SELECT next_month_churn,
       COUNT(*) AS count,
       ROUND((100 * RATIO_TO_REPORT(COUNT(*)) OVER()), 2) || '%' percentage
       FROM case_table GROUP BY next_month_churn; -- There is a taget level imbalance in the dataset

-- Create a train table as a view that randomly contains 80% of rows from case_table
CREATE OR REPLACE VIEW train_table AS
    SELECT * FROM case_table
      WHERE ORA_HASH(id, 4, 0) BETWEEN 0 AND 3;

-- Create a test table as a view that contains remaining 20% of rows from case_table
CREATE OR REPLACE VIEW test_table AS
    SELECT * FROM case_table
      WHERE ORA_HASH(id, 4, 0) = 4;

-- Visualise the target level distribution
SELECT 'train_table' AS table_name,
       next_month_churn,
       COUNT(*) AS count,
       ROUND((100 * RATIO_TO_REPORT(COUNT(*)) OVER()), 2) || '%' percentage
       FROM train_table GROUP BY next_month_churn
UNION
SELECT 'test_table' AS table_name,
       next_month_churn,
       COUNT(*) AS count,
       ROUND((100 * RATIO_TO_REPORT(COUNT(*)) OVER()), 2) || '%' percentage
       FROM test_table GROUP BY next_month_churn; -- target level distribution in both table are similar to case_table
      
-- b) MACHINE LEARNING MODELS --------------------------------------------------

-- Support Vector Machine with class weights -----------------------------------
DROP VIEW case_table;
DROP VIEW test_table;
DROP VIEW train_table;

DROP TABLE svm_model_settings;
DROP TABLE svm_class_wt;
DROP VIEW svm_results;
DROP TABLE svm_confusion_matrix;
--SELECT * FROM all_mining_models;

BEGIN
  DBMS_DATA_MINING.DROP_MODEL(model_name => 'SVM');
END;
/

SET SERVEROUTPUT ON;

-- Create a settings table
CREATE TABLE svm_model_settings (
    setting_name VARCHAR2(30),
    setting_value VARCHAR2(30));

-- Create and populate a class weights table
CREATE TABLE svm_class_wt (
  target_value NUMBER,
  class_weight NUMBER);
INSERT INTO svm_class_wt VALUES (0, 0.099);
INSERT INTO svm_class_wt VALUES (1, 0.901);
    
-- Specify SVM, turn on Automatic Data Preparation, and add weights
BEGIN
    INSERT INTO svm_model_settings (setting_name, setting_value) 
        VALUES (dbms_data_mining.algo_name, dbms_data_mining.algo_support_vector_machines);
    INSERT INTO svm_model_settings (setting_name, setting_value) 
        VALUES (dbms_data_mining.clas_weights_table_name, 'svm_class_wt');
    INSERT INTO svm_model_settings (setting_name, setting_value) 
        VALUES (dbms_data_mining.prep_auto, dbms_data_mining.prep_auto_on);
COMMIT;
END;
/

-- Create a model using train_table
BEGIN
    DBMS_DATA_MINING.CREATE_MODEL(
    model_name => 'svm',
    mining_function => dbms_data_mining.classification,
    data_table_name => 'train_table',
    case_id_column_name => 'id',
    target_column_name => 'next_month_churn',
    settings_table_name => 'svm_model_settings');
END;
/

-- Check that the model was created
SELECT * FROM all_mining_models WHERE model_name = 'SVM';

-- Apply the model to the test data
CREATE OR REPLACE VIEW svm_results AS
    SELECT id,
    PREDICTION(svm USING *) predicted_value,
    PREDICTION_PROBABILITY(svm USING *) probability
    FROM test_table;

-- See the results
SELECT * FROM svm_results;

-- Create a Confusion Matrix
DECLARE
    svm_accuracy NUMBER;
BEGIN
    DBMS_DATA_MINING.COMPUTE_CONFUSION_MATRIX (
    accuracy => svm_accuracy,
    apply_result_table_name => 'svm_results',
    target_table_name => 'test_table',
    case_id_column_name => 'id',
    target_column_name => 'next_month_churn',
    confusion_matrix_table_name => 'svm_confusion_matrix',
    score_column_name => 'PREDICTED_VALUE',
    score_criterion_column_name => 'PROBABILITY',
    cost_matrix_table_name => null,
    apply_result_schema_name => null,
    target_schema_name => null,
    cost_matrix_schema_name => null,
    score_criterion_type => 'PROBABILITY');
    DBMS_OUTPUT.PUT_LINE('Model accuracy is ' || ROUND(svm_accuracy, 4));
END;
/ 
-- Accuracy .6634

-- View the confusion matrix
SELECT * FROM svm_confusion_matrix; -- 122 true positives

DECLARE
    tp NUMBER;
    fp NUMBER;
    fn NUMBER;
    precision NUMBER;
    recall NUMBER;
    f1 NUMBER;
BEGIN
    SELECT
        (SELECT value from svm_confusion_matrix WHERE actual_target_value = 1 AND predicted_target_value = 1),
        (SELECT value from svm_confusion_matrix WHERE actual_target_value = 0 AND predicted_target_value = 1),
        (SELECT value from svm_confusion_matrix WHERE actual_target_value = 1 AND predicted_target_value = 0)
        INTO tp, fp, fn
        FROM svm_confusion_matrix
        WHERE ROWNUM = 1;
    precision := tp / (tp + fp);
    recall := tp / (tp + fn);
    f1 := (2 * precision * recall) / (precision + recall);
        DBMS_OUTPUT.PUT_LINE('F1 score is ' || ROUND(f1, 4));
END;
/ 

-- F1 score .1811


-- Generalised Linear Model with class weights ---------------------------------
DROP TABLE glm_model_settings;
DROP TABLE glm_class_wt;
DROP VIEW glm_results;
DROP TABLE glm_confusion_matrix;
--SELECT * FROM all_mining_models;

BEGIN
  DBMS_DATA_MINING.DROP_MODEL(model_name => 'GLM');
END;
/

-- Create a settings table
CREATE TABLE glm_model_settings (
    setting_name VARCHAR2(30),
    setting_value VARCHAR2(30));

-- Create and populate a class weights table
CREATE TABLE glm_class_wt (
  target_value NUMBER,
  class_weight NUMBER);
INSERT INTO glm_class_wt VALUES (0, 0.09);
INSERT INTO glm_class_wt VALUES (1, 0.91);

-- Specify GLM, turn on Automatic Data Preparation, and add weights
BEGIN
    INSERT INTO glm_model_settings (setting_name, setting_value) 
        VALUES (dbms_data_mining.algo_name, dbms_data_mining.algo_generalized_linear_model);
    INSERT INTO glm_model_settings (setting_name, setting_value) 
        VALUES (dbms_data_mining.clas_weights_table_name, 'glm_class_wt');
    INSERT INTO glm_model_settings (setting_name, setting_value) 
        VALUES (dbms_data_mining.prep_auto, dbms_data_mining.prep_auto_on);
COMMIT;
END;
/

-- Create a model using train_table
BEGIN
    DBMS_DATA_MINING.CREATE_MODEL(
    model_name => 'glm',
    mining_function => dbms_data_mining.classification,
    data_table_name => 'train_table',
    case_id_column_name => 'id',
    target_column_name => 'next_month_churn',
    settings_table_name => 'glm_model_settings');
END;
/

-- Check that the model was created
SELECT * FROM all_mining_models WHERE model_name = 'GLM';

-- Apply the model to the test data
CREATE OR REPLACE VIEW glm_results AS
    SELECT id,
    PREDICTION(glm USING *) predicted_value,
    PREDICTION_PROBABILITY(glm USING *) probability
    FROM test_table;

-- See the results
SELECT * FROM glm_results;

-- Create a Confusion Matrix
DECLARE
    glm_accuracy NUMBER;
BEGIN
    DBMS_DATA_MINING.COMPUTE_CONFUSION_MATRIX (
    accuracy => glm_accuracy,
    apply_result_table_name => 'glm_results',
    target_table_name => 'test_table',
    case_id_column_name => 'id',
    target_column_name => 'next_month_churn',
    confusion_matrix_table_name => 'glm_confusion_matrix',
    score_column_name => 'PREDICTED_VALUE',
    score_criterion_column_name => 'PROBABILITY',
    cost_matrix_table_name => null,
    apply_result_schema_name => null,
    target_schema_name => null,
    cost_matrix_schema_name => null,
    score_criterion_type => 'PROBABILITY');
    DBMS_OUTPUT.PUT_LINE('Model accuracy is ' || ROUND(glm_accuracy, 4));
END;
/ 
-- Accuracy .4577

-- View the confusion matrix
SELECT * FROM glm_confusion_matrix; -- 212 true positives

DECLARE
    tp NUMBER;
    fp NUMBER;
    fn NUMBER;
    precision NUMBER;
    recall NUMBER;
    f1 NUMBER;
BEGIN
    SELECT
        (SELECT value from glm_confusion_matrix WHERE actual_target_value = 1 AND predicted_target_value = 1),
        (SELECT value from glm_confusion_matrix WHERE actual_target_value = 0 AND predicted_target_value = 1),
        (SELECT value from glm_confusion_matrix WHERE actual_target_value = 1 AND predicted_target_value = 0)
        INTO tp, fp, fn
        FROM glm_confusion_matrix
        WHERE ROWNUM = 1;
    precision := tp / (tp + fp);
    recall := tp / (tp + fn);
    f1 := (2 * precision * recall) / (precision + recall);
        DBMS_OUTPUT.PUT_LINE('F1 score is ' || ROUND(f1, 4));
END;
/ 

-- F1 score .1926

COMMIT;