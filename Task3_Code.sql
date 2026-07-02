-- ===========================================
-- DROP TABLES (To avoid duplicate table error)
-- ===========================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- ===========================================
-- CREATE TABLES
-- ===========================================

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name TEXT NOT NULL,
    city TEXT,
    signup_date DATE
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT,
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date DATE,
    status TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ===========================================
-- INSERT DATA
-- ===========================================

INSERT INTO customers VALUES
(1,'Arun Kumar','Chennai','2024-01-15'),
(2,'Priya Raman','Trichy','2024-02-20'),
(3,'Suresh Babu','Madurai','2024-03-05'),
(4,'Meena Iyer','Coimbatore','2024-03-18'),
(5,'Karthik S','Trichy','2024-04-10'),
(6,'Divya Sri','Chennai','2024-05-01'),
(7,'Vignesh R',NULL,'2024-05-22');

INSERT INTO products VALUES
(101,'Wireless Mouse','Electronics',499.00),
(102,'Bluetooth Speaker','Electronics',1299.00),
(103,'Cotton T-Shirt','Apparel',399.00),
(104,'Running Shoes','Footwear',2199.00),
(105,'Yoga Mat','Fitness',799.00),
(106,'Laptop Bag','Accessories',999.00);

INSERT INTO orders VALUES
(1001,1,'2024-06-01','Completed'),
(1002,2,'2024-06-03','Completed'),
(1003,1,'2024-06-10','Completed'),
(1004,3,'2024-06-12','Cancelled'),
(1005,4,'2024-06-15','Completed'),
(1006,2,'2024-06-20','Pending'),
(1007,5,'2024-06-22','Completed'),
(1008,6,'2024-06-25','Completed'),
(1009,1,'2024-07-01','Completed');

INSERT INTO order_items VALUES
(1,1001,101,2),
(2,1001,103,1),
(3,1002,102,1),
(4,1003,104,1),
(5,1004,105,2),
(6,1005,106,1),
(7,1005,101,3),
(8,1006,103,2),
(9,1007,102,2),
(10,1008,104,1),
(11,1009,105,1),
(12,1009,106,2);

-- ===========================================
-- SELECT
-- ===========================================

SELECT * FROM customers;

SELECT * FROM products;

SELECT * FROM orders;

SELECT * FROM order_items;

-- ===========================================
-- WHERE
-- ===========================================

SELECT *
FROM customers
WHERE city='Chennai';

-- ===========================================
-- ORDER BY
-- ===========================================

SELECT *
FROM products
ORDER BY price DESC;

-- ===========================================
-- GROUP BY
-- ===========================================

SELECT
customer_id,
COUNT(order_id) AS Total_Orders
FROM orders
GROUP BY customer_id;

-- ===========================================
-- INNER JOIN
-- ===========================================

SELECT
c.customer_name,
o.order_id,
o.order_date,
o.status
FROM customers c
INNER JOIN orders o
ON c.customer_id=o.customer_id;

-- ===========================================
-- LEFT JOIN
-- ===========================================

SELECT
c.customer_name,
o.order_id,
o.status
FROM customers c
LEFT JOIN orders o
ON c.customer_id=o.customer_id;

-- ===========================================
-- MULTI TABLE JOIN
-- ===========================================

SELECT
c.customer_name,
p.product_name,
oi.quantity,
(p.price*oi.quantity) AS Total_Price
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
JOIN order_items oi
ON o.order_id=oi.order_id
JOIN products p
ON oi.product_id=p.product_id;

-- ===========================================
-- SUBQUERY
-- ===========================================

SELECT
product_name,
price
FROM products
WHERE price >
(
SELECT AVG(price)
FROM products
);

-- ===========================================
-- AGGREGATE FUNCTIONS
-- ===========================================

SELECT
SUM(quantity) AS Total_Quantity,
AVG(quantity) AS Average_Quantity
FROM order_items;

-- ===========================================
-- CUSTOMER SPENDING
-- ===========================================

SELECT
o.customer_id,
SUM(p.price*oi.quantity) AS Total_Spent
FROM orders o
JOIN order_items oi
ON o.order_id=oi.order_id
JOIN products p
ON oi.product_id=p.product_id
GROUP BY o.customer_id
ORDER BY Total_Spent DESC;

-- ===========================================
-- AVERAGE REVENUE PER USER (ARPU)
-- ===========================================

SELECT
ROUND(
SUM(p.price*oi.quantity)/
COUNT(DISTINCT o.customer_id),2
) AS Average_Revenue_Per_User
FROM orders o
JOIN order_items oi
ON o.order_id=oi.order_id
JOIN products p
ON oi.product_id=p.product_id;

-- ===========================================
-- VIEW
-- ===========================================

CREATE VIEW customer_purchase_summary AS

SELECT
c.customer_name,
COUNT(DISTINCT o.order_id) AS Total_Orders,
SUM(p.price*oi.quantity) AS Total_Spent
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
JOIN order_items oi
ON o.order_id=oi.order_id
JOIN products p
ON oi.product_id=p.product_id
GROUP BY c.customer_name;

SELECT * FROM customer_purchase_summary;

-- ===========================================
-- NULL HANDLING
-- ===========================================

SELECT
customer_id,
customer_name,
IFNULL(city,'City Not Available') AS City
FROM customers;

-- ===========================================
-- INDEX
-- ===========================================

CREATE INDEX idx_customer_orders
ON orders(customer_id);

-- ===========================================
-- ADVANCED SUBQUERY
-- Customers spending above average
-- ===========================================

SELECT
c.customer_name,
SUM(p.price*oi.quantity) AS Total_Spent
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
JOIN order_items oi
ON o.order_id=oi.order_id
JOIN products p
ON oi.product_id=p.product_id
GROUP BY c.customer_name
HAVING Total_Spent >
(
SELECT AVG(Customer_Total)
FROM
(
SELECT
SUM(p.price*oi.quantity) AS Customer_Total
FROM orders o
JOIN order_items oi
ON o.order_id=oi.order_id
JOIN products p
ON oi.product_id=p.product_id
GROUP BY o.customer_id
)
);

-- ===========================================
-- HIGHEST REVENUE PRODUCT
-- ===========================================

SELECT
p.product_name,
SUM(oi.quantity*p.price) AS Revenue
FROM products p
JOIN order_items oi
ON p.product_id=oi.product_id
GROUP BY p.product_name
ORDER BY Revenue DESC
LIMIT 1;
