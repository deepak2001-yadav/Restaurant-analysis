CREATE DATABASE APNA_RESTAURANT;
USE APNA_RESTAURANT;

CREATE TABLE menu (
  product_id INT NOT NULL,
  product_name VARCHAR(25),
  price INT,
  PRIMARY KEY (product_id)
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'MAGGIE', '35'),
  ('2', 'TEA', '15'),
  ('3', 'SAMOSA', '10');

CREATE TABLE members (
  customer_id VARCHAR(1) NOT NULL,
  join_date DATE,
  PRIMARY KEY (customer_id)
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

CREATE TABLE sales (
  customer_id VARCHAR(1) NOT NULL,
  order_date DATE,
  product_id INTEGER NOT NULL
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  
  -- QUERIES 
  
-- 1. What is the total amount each customer spent at the restaurant?
 SELECT customer_id , SUM(price) amount_spent
FROM sales
LEFT JOIN menu 
  ON sales.product_id = menu.product_id
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT(order_date)) no_of_visits
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
SELECT   (s.customer_id), m.product_name, s.order_date
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
WHERE s.order_date = '2021-01-01' 
GROUP BY s.customer_id, m.product_name, s.order_date;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT product_name, COUNT(product_name) times_purchased
FROM sales
LEFT JOIN menu 
  ON sales.product_id = menu.product_id
GROUP BY product_name
ORDER BY times_purchased DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
SELECT customer_id, product_name, COUNT(product_name) times_purchased
FROM sales
LEFT JOIN menu 
  ON sales.product_id = menu.product_id
GROUP BY customer_id, product_name
ORDER BY times_purchased DESC;

-- 6. Which item was purchased first by the customer after they became a member?
-- Customer A
SELECT customer_id, order_date, product_name 
FROM sales
LEFT JOIN menu 
  ON sales.product_id = menu.product_id
WHERE customer_id = 'A' AND order_date > '2021-01-07' -- date after membership
ORDER BY order_date
LIMIT 1;

-- Customer B
SELECT customer_id, order_date, product_name 
FROM sales
LEFT JOIN menu 
  ON sales.product_id = menu.product_id
WHERE customer_id = 'B' AND order_date > '    2021-01-09' -- date after membership
ORDER BY order_date
LIMIT 1;

-- 7. Which item was purchased just before the customer became a member?
-- Customer A
SELECT customer_id, order_date, product_name 
FROM sales
LEFT JOIN menu 
  ON sales.product_id = menu.product_id
WHERE customer_id = 'A' AND order_date < '2021-01-07' -- dates before membership
ORDER BY order_date DESC ;
-- Customer B?
SELECT customer_id, order_date, product_name 
FROM sales
LEFT JOIN menu 
  ON sales.product_id = menu.product_id
WHERE customer_id = 'B' AND order_date < '2021-01-09' -- get dates before membership
ORDER BY order_date DESC -- to capture closest date before membership
LIMIT 1;

-- 8. What are the total items and amount spent for each member before they became a member?
-- Customer A
SELECT s.customer_id, s.order_date, COUNT(m.product_name) AS total_items, SUM(m.price) AS amount_spent
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
WHERE s.customer_id = 'A' AND s.order_date < '2021-01-07' 
GROUP BY s.customer_id, s.order_date
ORDER BY s.order_date;

-- Customer B
SELECT customer_id, order_date, COUNT(product_name) AS total_items, SUM(price) AS amount_spent
FROM sales
LEFT JOIN menu 
  ON sales.product_id = menu.product_id
WHERE customer_id = 'B' AND order_date < '2021-01-09' -- dates before membership
GROUP BY customer_id, order_date
ORDER BY order_date;


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
SELECT customer_id,
SUM(CASE
    WHEN product_name = 'sushi' THEN 20 * price
    ELSE 10 * price
END) total_points
FROM sales
LEFT JOIN menu 
  ON sales.product_id = menu.product_id
GROUP BY customer_id;

-- 10. If the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customers A and B have at the end of January?
WITH cte_OfferValidity AS 
    (SELECT s.customer_id, m.join_date, s.order_date,
        date_add(m.join_date, interval(6) DAY) firstweek_ends, menu.product_name, menu.price
    FROM sales s
    LEFT JOIN members m
      ON s.customer_id = m.customer_id
    LEFT JOIN menu
        ON s.product_id = menu.product_id)
SELECT customer_id,
    SUM(CASE
            WHEN order_date BETWEEN join_date AND firstweek_ends THEN 20 * price 
            WHEN (order_date NOT BETWEEN join_date AND firstweek_ends) AND product_name = 'sushi' THEN 20 * price
            ELSE 10 * price
        END) points
FROM cte_OfferValidity
WHERE order_date < '2021-02-01' -- filter jan points only
GROUP BY customer_id;