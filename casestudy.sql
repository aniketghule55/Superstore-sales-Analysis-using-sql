
USE market_star_schema;

SELECT PRODUCT_CATEGORY,PRODUCT_SUB_CATEGORY FROM PROD_DIMEN;

/*-------------------------------------------------------------------------------------------
Problem statement: Growth team wants to understand sustainable(profitable) product categories
Sustainability can be achieved when we make better profits or at least positive profits.
	We can look at the profits per product category.
	We can look at profits per product subcategory. 
--------------------------------------------------------------------------------------------*/

-- Summary at Prodcut Category and Sub category. 
-- 1.1 Find the category wise profit. Which ones should we shut down?
SELECT 
    *
FROM
    market_fact_full;
SELECT 
    *
FROM
    prod_dimen;
SELECT DISTINCT
    Product_Category
FROM
    prod_dimen;

-- 1.1 Find the category wise profit. Which ones should we shut down?
SELECT 
    a.Product_Category,
    SUM(b.Profit) AS Total_Profit
FROM 
    prod_dimen a
 LEFT JOIN 
    market_fact_full b ON a.Prod_id = b.Prod_id
GROUP BY 
    a.Product_Category
ORDER BY 
    Total_Profit;

-- we shoud should shut down the furniture CATEGORY --

-- 1.2 Find the sub category wise profit. Which ones should we shut down?
SELECT
    a.Product_Sub_Category,
    SUM(b.Profit) AS Total_Profit
FROM
    prod_dimen a
LEFT JOIN
    market_fact_full b ON a.Prod_id = b.Prod_id
GROUP BY
    a.Product_Sub_Category
ORDER BY
    Total_Profit;
-- here we should shut the sub category product that are tables,bokcases,scissors,ruler and trimmers--



-- 1.3 Find the product wise profit. Which products should we shut down?

 SELECT
    pd.Prod_id,
    pd.Product_Category,
    pd.Product_Sub_Category,
    SUM(mf.Profit) AS Total_Profit
FROM
    prod_dimen pd
LEFT JOIN
    market_fact_full mf ON pd.Prod_id = mf.Prod_id
GROUP BY
    pd.Prod_id
ORDER BY
    Total_Profit 
    ;

-- 1.4 What is the category and sub category wise profit after removing the above products? 

SELECT 
    a.Product_Category,
    a.Product_sub_Category,
    SUM(b.profit)  AS total_profit
FROM
    prod_dimen a
LEFT JOIN
    market_fact_full b
ON 
    a.prod_id = b.prod_id
    where a.Prod_id NOT IN ('prod_11','prod_10','prod_16','prod_7')
GROUP BY
    a.prod_id,
    a.Product_Category,
    a.Product_sub_Category
    order by 
      total_profit desc;
