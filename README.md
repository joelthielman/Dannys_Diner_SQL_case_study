# Danny's Diner Case Study

![Danny.png]

This is a case study developed by Danny Ma. It can be found on his website [here.](https://8weeksqlchallenge.com/case-study-1/)

## Introduction

Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

## Problem Statement

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

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

### Create "sales" table and insert values:

<pre>
CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);
</pre>
  
<pre>
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
</pre>

### Output:

| customer_id | order_date | product_id |
| ----------- | ---------- | ---------- |
| A           | 2021-01-01 | 1          |
| A           | 2021-01-01 | 2          |
| A           | 2021-01-07 | 2          |
| A           | 2021-01-10 | 3          |
| A           | 2021-01-11 | 3          |
| A           | 2021-01-11 | 3          |
| B           | 2021-01-01 | 2          |
| B           | 2021-01-02 | 2          |
| B           | 2021-01-04 | 1          |
| B           | 2021-01-11 | 1          |
| B           | 2021-01-16 | 3          |
| B           | 2021-02-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-07 | 3          |

### Create "menu" table and insert values:

<pre>
CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);
</pre>

<pre>
INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
</pre>

### Output:

| product_id | product_name | price |
| ---------- | ------------ | ----- |
| 1          | sushi        | 10    |
| 2          | curry        | 15    |
| 3          | ramen        | 12    |

### Create "members" table and insert values:

<pre>
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);
</pre>

<pre>
INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
</pre>

### Output:

|customer_id| join_date |
| --------- | --------- |
| A         | 1/7/2021  |
| B         | 1/9/2021  |

### Question 1. What is the total amount each customer spent at the restaurant?

<pre>
SELECT s.customer_id, SUM(m.price) AS amount_spent
	FROM menu AS m
	JOIN sales AS s ON m.product_id = s.product_id
GROUP BY s.customer_id;
</pre>

### Output:

| customer_id | amount_spent |
| ----------- | ------------ |
| A           | 76           |
| B           | 74           |
| C           | 36           |

### Answer: A spent 76, B spent 74, C spent 36.

### Question 2. How many days has each customer visited the restaurant?

<pre>
SELECT customer_id, COUNT(DISTINCT(order_date)) AS number_of_visits
	FROM sales
GROUP BY customer_id;
</pre>

### Output:

| customer_id | number_of_visits |
| ----------- | ---------------- |
| A           | 4                |
| B           | 6                |
| C           | 2                |

### Answer: A visited 4 days, B visited 6 days, C visited 2 days.

### Question 3. What was the first item from the menu purchased by each customer?

<pre>
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
</pre>

### Output:

| customer_id | product_name | item_order |
| ----------- | ------------ | ---------- |
| A           | sushi        | 1          |
| B           | curry        | 1          |
| C           | ramen        | 1          |

### Answer: A purchased sushi first, B purchased curry first, C purchased ramen first.

### Question 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

<pre>
SELECT TOP 1 m.product_name , COUNT(s.product_id) AS times_purchased
	FROM menu m
	JOIN sales s ON m.product_id = s.product_id
GROUP BY m.product_name
ORDER BY COUNT(s.product_id) DESC;
</pre>

### Output:

| product_name | times_purchased |
| ------------ | --------------- |
| ramen        | 8               |

### Answer: Ramen, it was purchased 8 times.

### Question 5. Which item was the most popular for each customer?

<pre>
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
</pre>

### Output:

| customer_id | product_name | order_count | ranking |
| ----------- | ------------ | ----------- | ------- |
| A           | ramen        | 3           | 1       |
| B           | sushi        | 2           | 1       |
| B           | curry        | 2           | 1       |
| B           | ramen        | 2           | 1       |
| C           | ramen        | 3           | 1       |

### Answer: A ordered ramen 3 times, B ordered sushi, curry, and ramen 2 times, C ordered ramen 3 times.

### Question 6. Which item was purchased first by the customer after they became a member?

<pre>
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
</pre>

### Output:

| customer_id | product_name | rank |
| ----------- | ------------ | ---- |
| A           | curry        | 1    |
| B           | sushi        | 1    |

### Answer: A purchased curry, B purchased sushi.

### Question 7. Which item was purchased just before the customer became a member?

<pre>
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
</pre>

### Output:

| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| A           | curry        |
| B           | curry        |

### Answer: A purchased sushi and curry, B purchased curry.

### Question 8. What is the total items and amount spent for each member before they became a member?

<pre>
SELECT s.customer_id, COUNT(s.product_id) AS quantity, SUM(m.price) AS total_sales
	FROM sales AS s
	JOIN menu AS m ON m.product_id = s.product_id
	JOIN members AS mb ON mb.customer_id = s.customer_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id;
</pre>

### Output:

| customer_id | quantity | total_sales |
| ----------- | -------- | ----------- |
| A           | 2        | 25          |
| B           | 3        | 40          |

### Answer: A spent 25 on 2 items, B spent 40 on 3 items.

### Question 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

<pre>
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
</pre>

### Output:

| customer_id | points |
| ----------- | ------ |
| A           | 860    |
| B           | 940    |
| C           | 360    |

### Answer: A has 860 points, B has 940 point, C has 360 points.

### Question 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

<pre>
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
</pre>

### Output:

| customer_id | points |
| ----------- | ------ |
| A           | 1370   |
| B           | 820    |

### Answer: A has 1370 points, B has 820 points.
