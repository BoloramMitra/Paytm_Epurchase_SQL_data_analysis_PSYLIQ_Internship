use paytm;
set sql_safe_updates = 0;

select * from paytm_data;

UPDATE paytm_data
SET Class = 'Other'
WHERE Class IS NULL;

-- 1. What does the "Category_Grouped" column represent, and how many unique categories are there?

SELECT DISTINCT Category_Grouped AS Unique_Categories
FROM paytm_data;

SELECT COUNT(DISTINCT Category_Grouped) AS Unique_Categories_count
FROM paytm_data;

-- 2. List the top 5 shipping cities in terms of the number of orders.

SELECT Shipping_city, COUNT(*) AS Order_Count
FROM paytm_data
GROUP BY Shipping_city
ORDER BY Order_Count DESC
LIMIT 5;

-- 3. Show me a table with all the data for products that belong to the "Apparels" category.

SELECT *
FROM paytm_data
WHERE Category_grouped = "Apparels" ;

-- 4. Filter the data to show only rows with a "Sale_Flag" of 'Yes'.

SELECT *
FROM paytm_data
WHERE Sale_Flag = 'On Sale';

-- 5. Sort the data by "Item_Price" in descending order. What is the most expensive item?

SELECT *
FROM paytm_data
ORDER BY Item_Price DESC
LIMIT 1;

-- --------------------------------------------ALTERNATIVELY-------------------------------------------

SELECT *
FROM (
    SELECT *, RANK() OVER (ORDER BY Item_Price DESC) AS price_rank
    FROM paytm_data
) AS ranked_items
WHERE price_rank = 1;

-- 6. Apply conditional formatting to highlight all products with a "Special_Price_effective" value below $50 (INR 4,179.69) in red.

SELECT *
FROM paytm_data
WHERE Special_Price_effective < 4179.69;

-- 7. Create a pivot table to find the total sales value for each category.

SELECT Category_grouped, SUM(Item_Price) AS Total_Sales_Value
FROM paytm_data
GROUP BY Category_grouped;

-- 8. Create a bar chart to visualize the total sales for each category.

SELECT Category, SUM(Item_Price) AS Total_Sales
FROM paytm_data
GROUP BY Category;

-- 9. Calculate the average "Quantity" sold for products in the "Clothing" category, grouped by "Product_Gender".

SELECT Product_Gender, AVG(Quantity) AS Average_Quantity
FROM paytm_data
WHERE category like "%Apparel%"
GROUP BY Product_Gender;

-- 10. Find the top 5 products with the highest "Value_CM1" and "Value_CM2" ratios. Create a chart to visualize this data.

SELECT Item_NM,
       Value_CM1 / NULLIF(Value_CM2, 0) AS Ratio
FROM paytm_data
ORDER BY Ratio DESC
LIMIT 5;
-- --------------------------------ALTERNATIVELY-------------------------------------
WITH ranked_data AS (
    SELECT Item_NM,
           DENSE_RANK() OVER (ORDER BY Ratio DESC) AS Ranking
    FROM (
        SELECT *,
               Value_CM1 / NULLIF(Value_CM2, 0) AS Ratio
        FROM paytm_data
    ) AS ranked_ratios
)
SELECT DISTINCT Ranking, Item_NM
FROM ranked_data
WHERE Ranking <= 5;

-- 11. Identify the top 3 "Class" categories with the highest total sales. Create a stacked bar chart to represent this data.

SELECT Class, SUM(Item_Price) AS Total_Sales
FROM paytm_data
GROUP BY Class
ORDER BY Total_Sales DESC
LIMIT 3;

-- 12. Find the total sales for each "Brand" and display the top 3 brands in terms of sales.

SELECT Brand, SUM(Item_Price) AS Total_Sales
FROM paytm_data
GROUP BY Brand
ORDER BY Total_Sales DESC
LIMIT 3;

-- 13. Calculate the total revenue generated from "Apparels" category products with a "Sale_Flag" of 'On Sale'.

SELECT Category_grouped,Sale_Flag, SUM(Item_Price) AS Total_Revenue
FROM paytm_data
WHERE Category_grouped = 'Apparels' AND Sale_Flag = 'On Sale';

-- 14. Identify the top 5 shipping cities based on the average order value (total sales amount divided by the number of orders) and display their average order values.

SELECT Shipping_city,
       SUM(Item_Price) / COUNT(*) AS Average_Order_Value
FROM paytm_data
GROUP BY Shipping_city
ORDER BY Average_Order_Value DESC
LIMIT 5;
-- --------------------------ALTERNATIVELY---------------------------------------

WITH ranked_cities AS (
    SELECT Shipping_city,
           SUM(Item_Price) / COUNT(*) AS Average_Order_Value,
           DENSE_RANK() OVER (ORDER BY SUM(Item_Price) / COUNT(*) DESC) AS City_Rank
    FROM paytm_data
    GROUP BY Shipping_city
)
SELECT Shipping_city, Average_Order_Value,City_Rank
FROM ranked_cities
WHERE City_Rank <= 5;

-- 15. Determine the total number of orders and the total sales amount for each "Product_Gender" within the "Apparels" category_grouped.

SELECT Product_Gender,
       COUNT(*) AS Total_Orders,
       SUM(Item_Price) AS Total_Sales_Amount
FROM paytm_data
WHERE Category_Grouped = 'Apparels'
GROUP BY Product_Gender;

-- 16. Calculate the percentage contribution of each "Category" to the overall total sales.

SELECT 
    Category,
    round(((SUM(Item_Price) / total.total_sales) * 100),2) AS Percentage_Contribution
FROM 
    paytm_data
CROSS JOIN (
    SELECT SUM(Item_Price) AS total_sales
    FROM paytm_data
) AS total
GROUP BY 
    Category, total.total_sales
    order by Percentage_Contribution DESC;
-- ----------------------------------------------ALTERNATIVELY-----------------------------------------------
SELECT 
    Category,
    Round(((SUM(Item_Price) / (SELECT SUM(Item_Price) FROM paytm_data)) * 100),2) AS Percentage_Contribution
FROM 
    paytm_data
GROUP BY 
    Category
ORDER BY Percentage_Contribution DESC;

-- 17. Identify the "Category" with the highest average "Item_Price" and its corresponding average price.

SELECT 
    Category,
    round(AVG(Item_Price),2) AS Average_Item_Price
FROM 
    paytm_data
GROUP BY 
    Category
ORDER BY 
    Average_Item_Price DESC
LIMIT 1;
-- --------------------------------------ALTERNATIVELY--------------------------------------

SELECT 
    Category,
    round(AVG(Item_Price),2) AS Average_Item_Price
FROM 
    paytm_data
GROUP BY 
    Category
HAVING 
    AVG(Item_Price) = (
        SELECT MAX(avg_item_price)
        FROM (
            SELECT AVG(Item_Price) AS avg_item_price
            FROM paytm_data
            GROUP BY Category
        ) AS avg_prices
    );

-- 18. Find the month with the highest total sales revenue.

/* NO DATE COLUMN IN THE DATASET */

-- 19. Calculate the total sales for each "Segment" and the average quantity sold per order for each segment.

SELECT 
    Segment,
    SUM(Item_Price) AS Total_Sales,
    AVG(Quantity) AS Average_Quantity_Per_Order
FROM 
    paytm_data
GROUP BY 
    Segment;
