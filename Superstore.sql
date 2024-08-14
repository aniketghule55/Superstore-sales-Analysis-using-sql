USE market_star_schema;

/*-------------------------------------------------------------------------------------------
Problem statement: Growth team wants to understand sustainable(profitable) product categories
Sustainability can be achieved when we make better profits or at least positive profits.
	We can look at the profits per product category.
	We can look at profits per product subcategory. 
--------------------------------------------------------------------------------------------*/

-- Summary at Prodcut Category and Sub category. 
-- 1.1 Find the category wise profit. Which ones should we shut down? 
create view 
pract as 
select p.prod_id,p.product_category,p.product_sub_category,m.profit 
from market_fact_full m inner join prod_dimen p on m.prod_id=p.Prod_id;

select product_category, sum(profit) as total_profit 
from pract group by product_category;
            

-- 1.2 Find the sub category wise profit. Which ones should we shut down? 
select product_category, product_sub_category, sum(profit) as total_profit 
from pract group by product_category, product_sub_category 
order by sum(profit) desc;

SELECT a.product_category, a.Product_Sub_Category, SUM(b.Profit) AS Total_Profit 
FROM prod_dimen a 
LEFT JOIN market_fact_full b ON a.Prod_id = b.Prod_id 
GROUP BY a.product_category, a.Product_Sub_Category 
ORDER BY Total_Profit;

            
-- 1.3 Find the product wise profit. Which products should we shut down? 
select prod_id, sum(profit) as total_profit 
from pract group by prod_id order by sum(profit) desc;
            
select * from market_fact_full where prod_id = 'Prod_17' and abs(Profit) > Sales;

-- 1.4 What is the category and sub category wise profit after removing the above products? 
select product_category, product_sub_category, sum(profit) as total_profit 
from pract 
where prod_id not in 
(select prod_id 
from pract group by prod_id having sum(profit) < 0)
group by product_category, product_sub_category 
order by sum(profit) desc;


-- 1.5 Which customers are most profitable and generate most revenue? 
 SELECT cust_id, round(sum(sales)) as revenue, SUM(profit) AS total_profit 
 FROM market_fact_full GROUP BY cust_id order by sum(profit)desc;

-- 1.6 Average profit and revenue per customer? 
 SELECT cust_id, round(avg(sales)) as revenue, round(avg(profit)) AS total_profit 
 FROM market_fact_full GROUP BY cust_id order by avg(profit) desc;
 
 select * from market_fact_full;

-- 1.7 Average order value per city/ state? 


with abcde as (select ord_id, cust_id, sum(sales) as ord_value from market_fact_full group by ord_id, cust_id)
select c.state, c.city, round(avg(m.ord_value)) as avg_ord_value 
from abcde m 
inner join cust_dimen c 
on m.cust_id = c.cust_id 
group by c.state, c.city 
order by avg(m.ord_value) desc;


-- 1.8 Average time for order for every customer?
with abcd as
(select a.cust_id, a.ord_id, 
b.order_date,
lag(b.order_date,1) over (partition by a.Cust_id order by b.order_date asc) previous_ord_date,
datediff(order_date, lag(b.order_date,1) over (partition by a.Cust_id order by b.order_date asc)) as no_days
from 
market_fact_full a
left join
orders_dimen b
on
a.ord_id = b.ord_id
group by 
a.cust_id, a.ord_id, 
b.order_date)
select cust_id, avg(no_days) avg_ord_days, count(no_days)+1 as total_ord from abcd where previous_ord_date is not null 
group by cust_id order by total_ord desc 
;
