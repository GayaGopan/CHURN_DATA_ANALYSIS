use Final_Project
select * from churn_modelling
rename table churn_modelling to churn_Data;

-- 1. Retrieve all columns for all customers.

SELECT * FROM churn_Data;

-- 2. Retrieving Count the number of customers who have exited.

SELECT COUNT(*) AS Exited_Customers_Count FROM churn_Data WHERE Exited = 1;
SELECT COUNT(*) AS Not_Exited_Customers_Count FROM churn_Data WHERE Exited = 0;

-- 3 Calculate the average balance by Geography.

SELECT Geography, AVG(Balance) AS Avg_Balance FROM churn_Data GROUP BY Geography;

-- 4. Find customers with a credit score above the average credit score.(subQuery)

SELECT * FROM churn_Data
WHERE CreditScore > (SELECT AVG(CreditScore) FROM churn_Data);

-- 5. Retrieve customers who are active members and have more than two products.
-- (Conditional Retrieval)

SELECT * FROM churn_Data
WHERE IsActiveMember = 1 AND NumOfProducts > 2;

-- 6. Determine the average balance and estimated salary for different age groups.

SELECT 
    CASE
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age >= 30 AND Age < 40 THEN '30-39'
        WHEN Age >= 40 AND Age < 50 THEN '40-49'
        ELSE '50 and over'
    END AS AgeGroup,
    AVG(Balance) AS Avg_Balance,
    AVG(EstimatedSalary) AS Avg_Salary
FROM churn_Data
GROUP BY AgeGroup
ORDER BY AgeGroup;

-- 7. Calculate the churn rate (percentage of customers who have exited) and analyze churn behavior based on various factors.
SELECT
    Geography,
    AVG(Exited) AS ChurnRate,
    AVG(CreditScore) AS AvgCreditScore,
    AVG(Balance) AS AvgBalance
FROM churn_Data
GROUP BY Geography
ORDER BY ChurnRate DESC;

-- 8. Implement dynamic segmentation based on real-time updates in customer behavior, such as changes in balance or product ownership.
-- Example using window functions for dynamic segmentation
SELECT
    CustomerId,
    Balance,
    NumOfProducts,
    ROW_NUMBER() OVER (PARTITION BY CustomerId ORDER BY Balance DESC) AS Segment
FROM churn_Data;

-- 9. Calculate the CLV for each customer based on their tenure, average balance, and estimated salary.
SELECT
    CustomerId,
    SUM(Balance) AS TotalBalance,
    AVG(EstimatedSalary) AS AvgSalary,
    Tenure,
    (SUM(Balance) / Tenure) * AVG(EstimatedSalary) AS CLV
FROM churn_Data
GROUP BY CustomerId, Tenure
ORDER BY CLV DESC;

-- 10. Identify opportunities for cross-selling and up-selling by analyzing product ownership and balance distribution.
SELECT
    NumOfProducts,
    AVG(Balance) AS AvgBalance,
    COUNT(*) AS CustomerCount
FROM churn_Data
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
FROM churn_Data;

-- 12. Explore Customer Demographics and Churn
-- Objective: Investigate the relationship between customer demographics (gender, age) and churn.
WITH DemographicsChurn AS (
    SELECT 
        Gender,
        Age,
        AVG(Exited) * 100 AS ChurnRatePercentage
    FROM churn_Data
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
    FROM churn_Data
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
    FROM churn_Data
    GROUP BY AgeGroup
)

SELECT AgeGroup, CustomerCount
FROM AgeDistribution
ORDER BY AgeGroup;

-- 15.How many customers having a credit score between 600 and 700 are male and female? 
#And also tell what is the average salary of male customers and female customers in that Credit Score bracket?

select count(distinct CustomerId) from churn_data;

select Gender,count(CustomerId) as No_of_customers,round(avg(EstimatedSalary),2) as Average_Salary from churn_data
where CreditScore between 600 and 700
group by Gender;

-- 16.#How many male and female customers have been churned out in different Countries in different age brackets?
# age is between 18 and 30 .....Young
# age is bweteen 30 to 45.....Adults
# age is between 45 to 60.....MiddlE_Aged
#>60..........................Senior_Citizens

with ABC as
(select *, 
case when Age>=18 and Age<30 then "Young"
     when Age>=30 and Age<45 then "Adult"
     when Age>=45 and Age<60 then "Middle_Aged"
     else "Senior_Citizen"
     end as Age_bracket
     from churn_data)
select Gender,Geography,Exited,count(CustomerID) as Churned_customers from ABC
group by Gender,Geography,Exited
having Exited = 1
order by Gender Geography;

 
