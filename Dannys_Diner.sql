/*
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
	not just sushi - how many points do customer A and B have at the end of January?
*/

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
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
 
CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),

  ('B', '2021-01-09');

SELECT *
	FROM members
SELECT *
	FROM menu
SELECT *
	FROM sales

--1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, SUM(m.price) AS amount_spent
	FROM menu AS m
	JOIN sales AS s ON m.product_id = s.product_id
GROUP BY s.customer_id;

--2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT(order_date)) AS number_of_visits
	FROM sales
GROUP BY customer_id;

--3. What was the first item from the menu purchased by each customer?

WITH ranking AS
	(
	SELECT s.customer_id, m.product_name,
    ROW_NUMBER() OVER(
		PARTITION BY s.customer_id
		ORDER BY s.order_date, s.product_id
    ) AS item_order
		FROM sales AS s
		JOIN menu AS m ON s.product_id = m.product_id
	)
SELECT *
	FROM ranking
WHERE item_order = 1;

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT TOP 1 m.product_name , COUNT(s.product_id) AS times_purchased
	FROM menu m
	JOIN sales s ON m.product_id = s.product_id
GROUP BY m.product_name
ORDER BY COUNT(s.product_id) DESC;

--5. Which item was the most popular for each customer?

WITH order_count AS
	(
	SELECT s.customer_id, m.product_name, COUNT(*) AS order_count
		FROM sales AS s
		JOIN menu AS m ON s.product_id = m.product_id
	GROUP BY customer_id, product_name
	),
	popular_rank AS (
	SELECT *, RANK() OVER(PARTITION BY customer_id ORDER BY order_count DESC) AS ranking
		FROM order_count
	)
SELECT *
	FROM popular_rank
WHERE ranking = 1;

--6. Which item was purchased first by the customer after they became a member?

WITH rank AS
	(
	SELECT s.customer_id, m.product_name,
		DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
		FROM sales s
		JOIN menu m ON m.product_id = s.product_id
		JOIN members mb ON mb.customer_id = s.customer_id
	WHERE s.order_date >= mb.join_date  
	)
SELECT *
	FROM rank
WHERE rank = 1;

--7. Which item was purchased just before the customer became a member?

WITH rank AS
	(
	SELECT s.customer_id, m.product_name,
		DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
		FROM sales AS s
		JOIN menu AS m ON m.product_id = s.product_id
		JOIN members mb ON mb.customer_id = s.customer_id
	WHERE s.order_date < mb.join_date  
	)
SELECT customer_id, product_name
	FROM rank
WHERE rank = 1;

--8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(s.product_id) AS quantity, SUM(m.price) AS total_sales
	FROM sales AS s
	JOIN menu AS m ON m.product_id = s.product_id
	JOIN members AS mb ON mb.customer_id = s.customer_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id;

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH points AS
	(
	SELECT *, CASE WHEN product_id = 1 THEN price * 20
				ELSE price * 10
				END AS points
		FROM menu
	)
SELECT s.customer_id, SUM(p.points) AS points
	FROM sales AS s
	JOIN points AS p ON p.product_id = s.product_id
GROUP BY s.customer_id;

--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
--    not just sushi - how many points do customer A and B have at the end of January?

WITH dates AS 
	(
	SELECT *, DATEADD(DAY, 6, join_date) AS valid_date, EOMONTH('2021-01-31') AS last_date
		FROM members 
	)
SELECT s.customer_id, 
       SUM(CASE WHEN m.product_id = 1 THEN m.price * 20
			    WHEN s.order_date BETWEEN d.join_date and d.valid_date THEN m.price * 20
			    ELSE m.price * 10
			    END) AS points
	FROM dates AS d
	JOIN sales AS s ON d.customer_id = s.customer_id
	JOIN menu AS m ON m.product_id = s.product_id
WHERE s.order_date < d.last_date
GROUP BY s.customer_id;