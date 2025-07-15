
-- Use the working database
USE MyDB;
GO

-- ==============================================
-- ?? STEP 1: Check for Missing Values in Key Columns
-- ==============================================

SELECT COUNT(*) AS Missing_customerID FROM CustomerData WHERE customerID IS NULL;
SELECT COUNT(*) AS Missing_gender FROM CustomerData WHERE gender IS NULL;
SELECT COUNT(*) AS Missing_SeniorCitizen FROM CustomerData WHERE SeniorCitizen IS NULL;
SELECT COUNT(*) AS Missing_Dependents FROM CustomerData WHERE Dependents IS NULL;
SELECT COUNT(*) AS Missing_tenure FROM CustomerData WHERE tenure IS NULL;
SELECT COUNT(*) AS Missing_PhoneService FROM CustomerData WHERE PhoneService IS NULL;
SELECT COUNT(*) AS Missing_TotalCharges FROM CustomerData WHERE TotalCharges IS NULL;


-- Replace NULL values in TotalCharges with 0 for cleaner analysis
-- Assumes these are new customers with no charges yet (tenure = 0)
UPDATE CustomerData
SET TotalCharges = 0
WHERE TotalCharges IS NULL AND tenure = 0;

-- ==============================================
-- ?? STEP 2: Summary Statistics for Numerical Columns
-- ==============================================

SELECT 
    -- Tenure stats
    MIN(tenure) AS MinTenure,
    MAX(tenure) AS MaxTenure,
    AVG(tenure) AS AvgTenure,
    STDEV(tenure) AS STDEVTenure,

    -- MonthlyCharges stats
    MIN(MonthlyCharges) AS MinMonthlyCharges,
    MAX(MonthlyCharges) AS MaxMonthlyCharges,
    AVG(MonthlyCharges) AS AvgMonthlyCharges,
    STDEV(MonthlyCharges) AS STDEVMonthlyCharges,

    -- TotalCharges stats
    MIN(TotalCharges) AS MinTotalCharges,
    MAX(TotalCharges) AS MaxTotalCharges,
    AVG(TotalCharges) AS AvgTotalCharges,
    STDEV(TotalCharges) AS STDEVTotalCharges

FROM CustomerData;

-- ==============================================
-- ?? STEP 3: Detect Outliers Using 3 * STDEV Rule
-- ==============================================

-- Outliers in TotalCharges
SELECT * FROM CustomerData
WHERE TotalCharges > (SELECT AVG(TotalCharges) + 3 * STDEV(TotalCharges) FROM CustomerData)
   OR TotalCharges < (SELECT AVG(TotalCharges) - 3 * STDEV(TotalCharges) FROM CustomerData);

-- Outliers in MonthlyCharges
SELECT * FROM CustomerData
WHERE MonthlyCharges > (SELECT AVG(MonthlyCharges) + 3 * STDEV(MonthlyCharges) FROM CustomerData)
   OR MonthlyCharges < (SELECT AVG(MonthlyCharges) - 3 * STDEV(MonthlyCharges) FROM CustomerData);

-- Outliers in tenure
SELECT * FROM CustomerData
WHERE tenure > (SELECT AVG(tenure) + 3 * STDEV(tenure) FROM CustomerData)
   OR tenure < (SELECT AVG(tenure) - 3 * STDEV(tenure) FROM CustomerData);

-- ==============================================
-- ?? STEP 4: Check Data Types
-- ==============================================

EXEC sp_help CustomerData;

-- Modify data type if needed (example)
ALTER TABLE CustomerData
ALTER COLUMN tenure INT;

-- ==============================================
-- ?? STEP 5: Check for Duplicate Rows
-- ==============================================

SELECT *, COUNT(*) AS DuplicateCount
FROM CustomerData
GROUP BY customerID, gender, SeniorCitizen, Partner, Dependents, tenure,
         PhoneService, MultipleLines, InternetService, OnlineSecurity,
         OnlineBackup, DeviceProtection, TechSupport, StreamingTV,
         StreamingMovies, Contract, PaperlessBilling, PaymentMethod,
         MonthlyCharges, TotalCharges, Churn
HAVING COUNT(*) > 1;

-- ==============================================
-- ?? STEP 6: Check Unique Values for Categorical Columns
-- ==============================================

SELECT DISTINCT gender FROM CustomerData;
SELECT DISTINCT Partner FROM CustomerData;
SELECT DISTINCT Dependents FROM CustomerData;
SELECT DISTINCT PhoneService FROM CustomerData;
SELECT DISTINCT MultipleLines FROM CustomerData;
SELECT DISTINCT InternetService FROM CustomerData;
SELECT DISTINCT OnlineSecurity FROM CustomerData;
SELECT DISTINCT OnlineBackup FROM CustomerData;
SELECT DISTINCT DeviceProtection FROM CustomerData;
SELECT DISTINCT TechSupport FROM CustomerData;
SELECT DISTINCT StreamingTV FROM CustomerData;
SELECT DISTINCT StreamingMovies FROM CustomerData;
SELECT DISTINCT Contract FROM CustomerData;
SELECT DISTINCT PaperlessBilling FROM CustomerData;
SELECT DISTINCT PaymentMethod FROM CustomerData;
SELECT DISTINCT Churn FROM CustomerData;

-- ==============================================
-- ?? STEP 7: Basic EDA - Customer Overview
-- ==============================================

-- Total customers
SELECT COUNT(*) AS TotalCustomers FROM CustomerData;

-- Customers who churned
SELECT COUNT(*) AS ChurnedCustomers FROM CustomerData
WHERE Churn = 'Yes';

-- Churn Rate (%)
SELECT 
  CAST(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS ChurnRate
FROM CustomerData;

-- Average tenure
SELECT AVG(tenure) AS AvgTenure FROM CustomerData;

-- Average monthly charges
SELECT AVG(MonthlyCharges) AS AvgMonthlyCharges FROM CustomerData;

-- Customers by gender
SELECT gender, COUNT(*) AS Total FROM CustomerData GROUP BY gender;

-- Customers by contract type
SELECT Contract, COUNT(*) AS Total FROM CustomerData GROUP BY Contract;

-- Churn Rate by contract type
SELECT Contract,
       COUNT(*) AS Total,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned,
       CAST(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS ChurnRate
FROM CustomerData
GROUP BY Contract;
