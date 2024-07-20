
-- 1. Retrieve all columns for all customers.
SELECT * FROM churn_project.churn_modelling;

-- 2. Retrieving Count the number of customers who have exited.
SELECT COUNT(*) AS ExitedCustomersCount FROM churn_project.churn_modelling WHERE Exited = 1;

-- 3 Calculate the average balance by Geography.
SELECT Geography, AVG(Balance) AS AvgBalance FROM churn_project.churn_modelling GROUP BY Geography;

-- 4. Find customers with a credit score above the average credit score.(subuery)
SELECT * FROM churn_project.churn_modelling
WHERE CreditScore > (SELECT AVG(CreditScore) FROM churn_project.churn_modelling);

-- 5. Retrieve customers who are active members and have more than two products.
-- (Conditional Retrieval)

SELECT * FROM churn_project.churn_modelling
WHERE IsActiveMember = 1 AND NumOfProducts > 2;

-- 6. Determine the average balance and estimated salary for different age groups.
SELECT 
    CASE
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age >= 30 AND Age < 40 THEN '30-39'
        WHEN Age >= 40 AND Age < 50 THEN '40-49'
        ELSE '50 and over'
    END AS AgeGroup,
    AVG(Balance) AS AvgBalance,
    AVG(EstimatedSalary) AS AvgSalary
FROM churn_project.churn_modelling
GROUP BY AgeGroup
ORDER BY AgeGroup;

-- 7. Calculate the churn rate (percentage of customers who have exited) and analyze churn behavior based on various factors.
SELECT
    Geography,
    AVG(Exited) AS ChurnRate,
    AVG(CreditScore) AS AvgCreditScore,
    AVG(Balance) AS AvgBalance
FROM churn_project.churn_modelling
GROUP BY Geography
ORDER BY ChurnRate DESC;

-- 8. Implement dynamic segmentation based on real-time updates in customer behavior, such as changes in balance or product ownership.
-- Example using window functions for dynamic segmentation
SELECT
    CustomerId,
    Balance,
    NumOfProducts,
    ROW_NUMBER() OVER (PARTITION BY CustomerId ORDER BY Balance DESC) AS Segment
FROM churn_project.churn_modelling;

-- 9. Calculate the CLV for each customer based on their tenure, average balance, and estimated salary.
SELECT
    CustomerId,
    SUM(Balance) AS TotalBalance,
    AVG(EstimatedSalary) AS AvgSalary,
    Tenure,
    (SUM(Balance) / Tenure) * AVG(EstimatedSalary) AS CLV
FROM churn_project.churn_modelling
GROUP BY CustomerId, Tenure
ORDER BY CLV DESC;

-- 10. Identify opportunities for cross-selling and up-selling by analyzing product ownership and balance distribution.
SELECT
    NumOfProducts,
    AVG(Balance) AS AvgBalance,
    COUNT(*) AS CustomerCount
FROM churn_project.churn_modelling
GROUP BY NumOfProducts
ORDER BY NumOfProducts;

-- 11. Check if Customer has Credit Card
-- Create a UDF to convert the HasCrCard column (which is likely a bit or boolean) into a more readable format.

DELIMITER //

CREATE FUNCTION HasCreditCard(hasCrCard BIT)
RETURNS VARCHAR(3)
BEGIN
    DECLARE result VARCHAR(3);
    SET result = CASE WHEN hasCrCard = 1 THEN 'Yes' ELSE 'No' END;
    RETURN result;
END//

DELIMITER ;
SELECT CustomerId, Surname, HasCrCard, HasCreditCard(HasCrCard) AS HasCreditCard
FROM churn_project.churn_modelling;

-- 12. Explore Customer Demographics and Churn
-- Objective: Investigate the relationship between customer demographics (gender, age) and churn.
WITH DemographicsChurn AS (
    SELECT 
        Gender,
        Age,
        AVG(Exited) * 100 AS ChurnRatePercentage
    FROM churn_project.churn_modelling
    GROUP BY Gender, Age
)

SELECT Gender, Age, ChurnRatePercentage
FROM DemographicsChurn
ORDER BY Gender, Age;

-- 13. Determine Customer Tenure and Estimated Salary Trends
-- Objective: Analyze the relationship between customer tenure and estimated salary.

WITH TenureSalaryAnalysis AS (
    SELECT 
        Tenure,
        AVG(EstimatedSalary) AS AvgEstimatedSalary
    FROM churn_project.churn_modelling
    GROUP BY Tenure
)

SELECT Tenure, AvgEstimatedSalary
FROM TenureSalaryAnalysis
ORDER BY Tenure;

-- 14. Analyze Customer Age Distribution
-- Objective: Calculate the count of customers in different age groups.

WITH AgeDistribution AS (
    SELECT 
        CASE 
            WHEN Age < 30 THEN 'Under 30'
            WHEN Age >= 30 AND Age < 40 THEN '30-39'
            WHEN Age >= 40 AND Age < 50 THEN '40-49'
            ELSE '50 and over'
        END AS AgeGroup,
        COUNT(*) AS CustomerCount
    FROM churn_project.churn_modelling
    GROUP BY AgeGroup
)

SELECT AgeGroup, CustomerCount
FROM AgeDistribution
ORDER BY AgeGroup;
