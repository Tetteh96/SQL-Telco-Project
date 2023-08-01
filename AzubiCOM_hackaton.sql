--Q1a
select TOP 3 region, SUM(RECHARGE_EVD_COUNT) AS Total_EVD_Recharge_count, SUM(RECHARGE_MOMO_COUNT) AS Total_Momo_Recharge_count from dbo.customers as dc
join dbo.location  as dl
on dl.CELL_ID=dl.CELL_ID
GROUP BY region
ORDER BY Total_EVD_Recharge_count DESC;

select TOP 3 region, SUM(RECHARGE_EVD_COUNT) AS Total_EVD_Recharge_count, SUM(RECHARGE_MOMO_COUNT) AS Total_Momo_Recharge_count from dbo.customers as dc
join dbo.location  as dl
on dl.CELL_ID=dl.CELL_ID
GROUP BY region
ORDER BY Total_EVD_Recharge_count ASC;


--Q1b
SELECT region, COUNT(DISTINCT Customer_ID) AS Subscribers_Count, SUM(TOTAL_RECHARGE_AMOUNT) AS Total_Recharge_Amount
FROM customers
JOIN [location] ON customers.Cell_ID = [location].CELL_ID
GROUP BY region;



--Q1c
SELECT
    region,
    SUM(CASE WHEN RECHARGE_EVD_COUNT > 0 THEN 1 ELSE 0 END) AS EVD_Recharge_Count,
    SUM(CASE WHEN RECHARGE_MOMO_COUNT > 0 THEN 1 ELSE 0 END) AS MoMo_Recharge_Count,
    SUM(TOTAL_RECHARGE_COUNT) AS Total_Recharge_Count,
    (SUM(CASE WHEN RECHARGE_EVD_COUNT > 0 THEN 1 ELSE 0 END) * 100.0) / SUM(TOTAL_RECHARGE_COUNT) AS EVD_Recharge_Percentage,
    (SUM(CASE WHEN RECHARGE_MOMO_COUNT > 0 THEN 1 ELSE 0 END) * 100.0) / SUM(TOTAL_RECHARGE_COUNT) AS MoMo_Recharge_Percentage
FROM customers
JOIN [location] ON customers.Cell_ID = [location].CELL_ID
GROUP BY region;




--Q2
SELECT Customer_ID, ACTIVATION_DATE
FROM customers
JOIN [location] ON customers.Cell_ID = [location].CELL_ID
WHERE region = 'Central Region' 
    AND Data_Vol_MB = 0
    AND ACTIVATION_DATE >= (SELECT MIN(ACTIVATION_DATE) FROM customers WHERE region = 'Central Region');




--Q3
SELECT COUNT(DISTINCT Customer_ID) AS Num_Customers
FROM customers
WHERE Data_Vol_MB BETWEEN 500 AND 7000
    AND Tenure >= 84; -- Assuming 12 months make up a year, so 7 years = 84 months




--Q4
--customers who have used more than a certain threshold of data can be considered as "Heavy Data Users"
--those who have used below the threshold can be considered "Light Data Users."

--Customers with higher voice call durations can be categorized as "Heavy Voice Users"
--those with lower call durations can be considered "Light Voice Users."

--SELECT
--     Customer_ID,
--     CASE WHEN Data_Vol_MB >= 5000 THEN 'Heavy Data Users'
--          WHEN Data_Vol_MB >= 1000 AND Data_Vol_MB < 5000 THEN 'Moderate Data Users'
--          ELSE 'Light Data Users' END AS Data_Usage_Segment
-- FROM customers;

-- SELECT
--     Customer_ID,
--     CASE WHEN Total_Call_Duration_Min >= 1000 THEN 'Heavy Voice Users'
--          WHEN Total_Call_Duration_Min >= 500 AND Total_Call_Duration_Min < 1000 THEN 'Moderate Voice Users'
--          ELSE 'Light Voice Users' END AS Voice_Usage_Segment
-- FROM customers;

-- SELECT
--     Customer_ID,
--     CASE WHEN TOTAL_RECHARGE_AMOUNT >= 200 THEN 'High Recharge Users'
--          WHEN TOTAL_RECHARGE_AMOUNT >= 100 AND TOTAL_RECHARGE_AMOUNT < 200 THEN 'Moderate Recharge Users'
--          ELSE 'Low Recharge Users' END AS Recharge_Behavior_Segment
-- FROM customers;

WITH Data_Usage_Segmentation AS (
    SELECT
        Customer_ID,
        CASE WHEN Data_Vol_MB >= 5000 THEN 'Heavy Data Users'
             WHEN Data_Vol_MB >= 1000 AND Data_Vol_MB < 5000 THEN 'Moderate Data Users'
             ELSE 'Light Data Users' END AS Data_Usage_Segment
    FROM customers
),
Voice_Usage_Segmentation AS (
    SELECT
        Customer_ID,
        CASE WHEN Total_Call_Duration_Min >= 1000 THEN 'Heavy Voice Users'
             WHEN Total_Call_Duration_Min >= 500 AND Total_Call_Duration_Min < 1000 THEN 'Moderate Voice Users'
             ELSE 'Light Voice Users' END AS Voice_Usage_Segment
    FROM customers
),
SMS_Usage_Segmentation AS (
    SELECT
        Customer_ID,
        CASE WHEN SMS_SPENT >= 100 THEN 'Heavy SMS Users'
             WHEN SMS_SPENT >= 50 AND SMS_SPENT < 100 THEN 'Moderate SMS Users'
             ELSE 'Light SMS Users' END AS SMS_Usage_Segment
    FROM customers
),
Recharge_Behavior_Segmentation AS (
    SELECT
        Customer_ID,
        CASE WHEN TOTAL_RECHARGE_AMOUNT >= 200 THEN 'High Recharge Users'
             WHEN TOTAL_RECHARGE_AMOUNT >= 100 AND TOTAL_RECHARGE_AMOUNT < 200 THEN 'Moderate Recharge Users'
             ELSE 'Low Recharge Users' END AS Recharge_Behavior_Segment
    FROM customers
)
SELECT
    Data_Usage_Segment,
    COUNT(Data_Usage_Segment) AS Num_Data_Usage_Customers,
    Voice_Usage_Segment,
    COUNT(Voice_Usage_Segment) AS Num_Voice_Usage_Customers,
    SMS_Usage_Segment,
    COUNT(SMS_Usage_Segment) AS Num_SMS_Usage_Customers,
    Recharge_Behavior_Segment,
    COUNT(Recharge_Behavior_Segment) AS Num_Recharge_Behavior_Customers
FROM Data_Usage_Segmentation
JOIN Voice_Usage_Segmentation ON Data_Usage_Segmentation.Customer_ID = Voice_Usage_Segmentation.Customer_ID
JOIN SMS_Usage_Segmentation ON Data_Usage_Segmentation.Customer_ID = SMS_Usage_Segmentation.Customer_ID
JOIN Recharge_Behavior_Segmentation ON Data_Usage_Segmentation.Customer_ID = Recharge_Behavior_Segmentation.Customer_ID
GROUP BY Data_Usage_Segment, Voice_Usage_Segment, SMS_Usage_Segment, Recharge_Behavior_Segment;


SELECT Data_Usage_Segment, COUNT(Customer_ID) AS Num_Customers
FROM (
    SELECT
        Customer_ID,
        CASE WHEN Data_Vol_MB >= 5000 THEN 'Heavy Data Users'
             WHEN Data_Vol_MB >= 1000 AND Data_Vol_MB < 5000 THEN 'Moderate Data Users'
             ELSE 'Light Data Users' END AS Data_Usage_Segment
    FROM customers
) AS Segmented_Customers
GROUP BY Data_Usage_Segment;


SELECT Voice_Usage_Segment, COUNT(Customer_ID) AS Num_Customers
FROM (
    SELECT
    Customer_ID,
    CASE WHEN Total_Call_Duration_Min >= 1000 THEN 'Heavy Voice Users'
         WHEN Total_Call_Duration_Min >= 500 AND Total_Call_Duration_Min < 1000 THEN 'Moderate Voice Users'
         ELSE 'Light Voice Users' END AS Voice_Usage_Segment
FROM customers
) AS Segmented_Customers
GROUP BY Voice_Usage_Segment;

SELECT SMS_Usage_Segment, COUNT(Customer_ID) AS Num_Customers
FROM (
    SELECT
    Customer_ID,
    CASE WHEN SMS_SPENT >= 100 THEN 'Heavy SMS Users'
         WHEN SMS_SPENT >= 50 AND SMS_SPENT < 100 THEN 'Moderate SMS Users'
         ELSE 'Light SMS Users' END AS SMS_Usage_Segment
FROM customers
) AS Segmented_Customers
GROUP BY SMS_Usage_Segment;

SELECT Recharge_Behavior_Segment, COUNT(Customer_ID) AS Num_Customers
FROM (
    SELECT
    Customer_ID,
    CASE WHEN TOTAL_RECHARGE_AMOUNT >= 200 THEN 'High Recharge Users'
         WHEN TOTAL_RECHARGE_AMOUNT >= 100 AND TOTAL_RECHARGE_AMOUNT < 200 THEN 'Moderate Recharge Users'
         ELSE 'Low Recharge Users' END AS Recharge_Behavior_Segment
FROM customers
) AS Segmented_Customers
GROUP BY Recharge_Behavior_Segment;