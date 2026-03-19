create database ecommerce_project;

use ecommerce_project;

-- create tables --

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(50),
    signup_date DATE
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Order_Items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

INSERT INTO Customers VALUES
(1,'Alice','USA','2023-01-01'),
(2,'Bob','UK','2023-01-05'),
(3,'Charlie','India','2023-01-10'),
(4,'David','India','2023-02-01'),
(5,'Eva','USA','2023-02-10'),
(6,'Frank','Germany','2023-03-01'),
(7,'Grace','India','2023-03-15'),
(8,'Helen','UK','2023-04-01'),
(9,'Ian','USA','2023-04-10'),
(10,'Jack','India','2023-05-01'),
(11,'Kate','USA','2023-05-10'),
(12,'Leo','UK','2023-06-01'),
(13,'Mia','India','2023-06-10'),
(14,'Nina','Germany','2023-07-01'),
(15,'Oscar','USA','2023-07-10'),
(16,'Paul','India','2023-08-01'),
(17,'Quinn','UK','2023-08-10'),
(18,'Rose','India','2023-09-01'),
(19,'Steve','USA','2023-09-10'),
(20,'Tina','India','2023-10-01');

INSERT INTO Products VALUES
(101,'Laptop','Electronics',800),
(102,'Mouse','Electronics',20),
(103,'Keyboard','Electronics',50),
(104,'Chair','Furniture',150),
(105,'Table','Furniture',300),
(106,'Phone','Electronics',600),
(107,'Headphones','Electronics',100),
(108,'Bag','Accessories',40),
(109,'Shoes','Fashion',120),
(110,'Watch','Fashion',200);

INSERT INTO Orders VALUES
(1,1,'2024-01-01','Delivered'),
(2,2,'2024-01-02','Delivered'),
(3,3,'2024-01-03','Cancelled'),
(4,4,'2024-01-05','Delivered'),
(5,5,'2024-01-06','Delivered'),
(6,6,'2024-01-07','Returned'),
(7,7,'2024-01-08','Delivered'),
(8,8,'2024-01-10','Delivered'),
(9,9,'2024-01-11','Cancelled'),
(10,10,'2024-01-12','Delivered'),
(11,1,'2024-01-15','Delivered'),
(12,2,'2024-01-16','Returned'),
(13,3,'2024-01-17','Delivered'),
(14,4,'2024-01-18','Delivered'),
(15,5,'2024-01-19','Delivered'),
(16,6,'2024-01-20','Cancelled'),
(17,7,'2024-01-21','Delivered'),
(18,8,'2024-01-22','Delivered'),
(19,9,'2024-01-23','Delivered'),
(20,10,'2024-01-24','Returned'),
(21,11,'2024-02-01','Delivered'),
(22,12,'2024-02-02','Delivered'),
(23,13,'2024-02-03','Delivered'),
(24,14,'2024-02-04','Cancelled'),
(25,15,'2024-02-05','Delivered'),
(26,16,'2024-02-06','Delivered'),
(27,17,'2024-02-07','Delivered'),
(28,18,'2024-02-08','Returned'),
(29,19,'2024-02-09','Delivered'),
(30,20,'2024-02-10','Delivered');

INSERT INTO Order_Items VALUES
(1,1,101,1),(2,1,102,2),
(3,2,103,1),(4,2,104,1),
(5,3,105,1),(6,4,101,1),
(7,5,106,1),(8,6,107,2),
(9,7,108,3),(10,8,109,1),
(11,9,110,1),(12,10,101,1),
(13,11,102,2),(14,12,103,1),
(15,13,104,1),(16,14,105,1),
(17,15,106,1),(18,16,107,1),
(19,17,108,2),(20,18,109,1),
(21,19,110,1),(22,20,101,1),
(23,21,102,3),(24,22,103,2),
(25,23,104,1),(26,24,105,1),
(27,25,106,2),(28,26,107,1),
(29,27,108,1),(30,28,109,2),
(31,29,110,1),(32,30,101,1),
(33,5,102,2),(34,7,103,1),
(35,8,104,1),(36,10,105,1),
(37,12,106,1),(38,14,107,2),
(39,15,108,1),(40,18,109,1),
(41,20,110,2),(42,21,101,1),
(43,22,102,1),(44,23,103,1),
(45,24,104,1),(46,25,105,2),
(47,26,106,1),(48,27,107,1),
(49,28,108,1),(50,29,109,1);

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