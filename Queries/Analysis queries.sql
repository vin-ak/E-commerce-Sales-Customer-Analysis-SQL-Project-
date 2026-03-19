-- creating view --
CREATE VIEW Sales_Details AS
SELECT 
    o.order_id,
    o.order_date,
    c.customer_id,
    c.name,
    c.city,
    p.product_name,
    p.category,
    oi.quantity,
    p.price,
    (oi.quantity * p.price) AS sales_amount,
    o.status
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Order_Items oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id;

-- Total Revenue --
SELECT SUM(sales_amount) FROM Sales_Details;

-- Top Products --
select product_name,sum(sales_amount) as revenue
from sales_details
group by product_name
order by revenue desc;

-- Top customers --
select customer_id,name,sum(sales_amount) as revenue
from sales_details
group by customer_id
order by revenue desc;

-- Sales by City --
select city,sum(sales_amount) as sales
from sales_details 
group by city
order by sales desc;

-- monthly trend --
SELECT DATE_FORMAT(order_date,'%Y-%m') month,
       SUM(sales_amount) revenue
FROM Sales_Details
GROUP BY month;

-- rank the customer --
select name,
		sum(sales_amount) as total_spent,
        rank() over (order by sum(sales_amount) desc) rnk
from sales_details
group by name;

-- customer more than 1 order--
SELECT customer_id, COUNT(order_id) orders_count
FROM Sales_Details
GROUP BY customer_id
HAVING COUNT(DISTINCT order_id) > 1;
        
-- Customer Segmentation (High / Medium / Low Value) --
SELECT name,
       SUM(sales_amount) AS total_spent,
       CASE 
           WHEN SUM(sales_amount) > 1500 THEN 'High Value'
           WHEN SUM(sales_amount) BETWEEN 800 AND 1500 THEN 'Medium Value'
           ELSE 'Low Value'
       END AS segment
FROM Sales_Details
GROUP BY name;

-- Average Order Value (AOV) --
SELECT 
    SUM(sales_amount) / COUNT(DISTINCT order_id) AS avg_order_value
FROM Sales_Details;

-- Top Product per Category --
SELECT *
FROM (
    SELECT category,
           product_name,
           SUM(sales_amount) AS revenue,
           RANK() OVER (PARTITION BY category ORDER BY SUM(sales_amount) DESC) rnk
    FROM Sales_Details
    GROUP BY category, product_name
) t
WHERE rnk = 1;

-- Category-wise Avg Price --
SELECT category,
       AVG(price) AS avg_price
FROM Sales_Details
GROUP BY category;

-- Running Revenue (Cumulative) --
SELECT order_date,
       SUM(sales_amount) OVER (ORDER BY order_date) AS running_revenue
FROM Sales_Details;

-- Most Popular Product (by Quantity) --
SELECT product_name,
       SUM(quantity) AS total_qty
FROM Sales_Details
GROUP BY product_name
ORDER BY total_qty DESC
LIMIT 1;

-- Identify Inactive Customers --
SELECT c.customer_id, c.name
FROM Customers c
LEFT JOIN Sales_Details s ON c.customer_id = s.customer_id
WHERE s.customer_id IS NULL;

-- Top 5 Highest Value Orders --
SELECT order_id,
       SUM(sales_amount) AS order_value
FROM Sales_Details
GROUP BY order_id
ORDER BY order_value DESC
LIMIT 5;