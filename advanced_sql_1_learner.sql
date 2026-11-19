-- =====================================================================
--  ADVANCED SQL 1
--  Subqueries, CTEs, window functions and transactions
--  Learner file · Pagila on PostgreSQL · run in DBeaver
-- =====================================================================
--
--  How to run code in DBeaver
--    One statement:  click inside it, then Ctrl+Enter (Cmd+Enter on a Mac)
--    Several lines:  select them, then Alt+X (Option+X on a Mac)
--
--  How this file works
--    DEMO      run these as the trainer talks them through; change them freely
--    EXERCISE  write your own query under each TODO
--    Parts 1 to 3 only read Pagila, which is in schema main.
--    Part 4 writes to your own schema, ade_1, in tables that start with
--    your initials. Before Part 4, press Ctrl+F (Cmd+F on a Mac) and
--    replace  xx_  with your initials, for example  jd_
-- =====================================================================

-- Run this first, so that film, rental, payment ... are found in main
SET search_path TO main;


-- =====================================================================
--  PART 1 · SUBQUERIES
-- =====================================================================

-- ---------------------------------------------------------------------
-- DEMO 1.1 · A subquery is a query inside a query -- can only return one column though
-- Question: which films are longer than the average film?
-- ---------------------------------------------------------------------

-- Step 1: run the inner query on its own. It returns one value.
SELECT AVG(length) FROM film;

-- Step 2: put it inside the outer query, in brackets.
SELECT title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY length DESC;


-- ---------------------------------------------------------------------
-- DEMO 1.2 · A subquery can return a list: IN and NOT IN
-- ---------------------------------------------------------------------

-- Films in the Horror category
SELECT title
FROM film
WHERE film_id IN (
    SELECT fc.film_id
    FROM film_category AS fc
    JOIN category AS c ON c.category_id = fc.category_id
    WHERE c.name = 'Horror'
)
ORDER BY title;

-- Films the stores have never stocked
SELECT film_id, title
FROM film
WHERE film_id NOT IN (SELECT film_id FROM inventory)
ORDER BY title;
-- Careful: if the list contains a NULL, NOT IN returns no rows at all.
-- inventory.film_id is NOT NULL, so it is safe here.


-- ---------------------------------------------------------------------
-- DEMO 1.3 · A subquery in FROM builds a table on the fly
-- Question: how much does the average customer spend in total?
-- ---------------------------------------------------------------------

-- This fails: one aggregate cannot sit inside another
SELECT AVG(SUM(amount))
FROM payment
GROUP BY customer_id;

-- Total per customer first, then the average of those totals
SELECT ROUND(AVG(total_spent), 2) AS avg_customer_spend
FROM (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM payment
    GROUP BY customer_id
) AS customer_totals;          -- a subquery in FROM must be given a name


-- ---------------------------------------------------------------------
-- DEMO 1.4 · A subquery in SELECT runs once for every row
-- ---------------------------------------------------------------------

SELECT c.customer_id,
       c.first_name,
       c.last_name,
       (SELECT COUNT(*)
        FROM rental AS r
        WHERE r.customer_id = c.customer_id) AS rentals
FROM customer AS c
ORDER BY rentals DESC, c.customer_id
LIMIT 10;
-- The inner query uses c from the outer query, so it is called "correlated".

-- The same answer with a JOIN and GROUP BY, usually easier to read
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       COUNT(r.rental_id) AS rentals
FROM customer AS c
LEFT JOIN rental AS r ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY rentals DESC, c.customer_id
LIMIT 10;


-- ---------------------------------------------------------------------
-- EXERCISE 1A · Subquery
-- List the films whose rental_rate is higher than the average rental_rate.
-- Show title and rental_rate, highest first.
-- ---------------------------------------------------------------------
-- TODO: write your query here

-- inner query
SELECT 
	AVG(f.rental_rate)
FROM film f;

SELECT 
	f.title
	, f.rental_rate 
FROM film f 
WHERE f.rental_rate > (SELECT AVG(f2.rental_rate )FROM film f2)
ORDER BY f.rental_rate;


-- ---------------------------------------------------------------------
-- EXERCISE 1B · Stretch
-- Keep only the films from 1A that are also shorter than the average film.
-- ---------------------------------------------------------------------
-- TODO: write your query here

SELECT 
	f.title
	, f.rental_rate
	, f.length
FROM film f 
WHERE f.rental_rate > (SELECT AVG(f2.rental_rate)FROM film f2) 
	AND f.length < (SELECT AVG(f3.length) FROM film f3)
ORDER BY f.rental_rate, f.length;



-- =====================================================================
--  PART 2 · COMMON TABLE EXPRESSIONS (CTEs)
-- =====================================================================

-- ---------------------------------------------------------------------
-- DEMO 2.1 · Nested subqueries are hard to read
-- Question: which countries have the most customers who spend more than
-- the average customer?
-- ---------------------------------------------------------------------

SELECT country, COUNT(*) AS big_spenders
FROM (
    SELECT co.country
    FROM (
        SELECT customer_id, SUM(amount) AS total_spent
        FROM payment
        GROUP BY customer_id
    ) AS ct
    JOIN customer AS cu ON cu.customer_id = ct.customer_id
    JOIN address  AS a  ON a.address_id   = cu.address_id
    JOIN city     AS ci ON ci.city_id     = a.city_id
    JOIN country  AS co ON co.country_id  = ci.country_id
    WHERE ct.total_spent > (
        SELECT AVG(total_spent)
        FROM (
            SELECT customer_id, SUM(amount) AS total_spent
            FROM payment
            GROUP BY customer_id
        ) AS t
    )
) AS big
GROUP BY country
ORDER BY big_spenders DESC, country
LIMIT 10;
-- Read it from the inside out. The customer totals are written twice.


-- ---------------------------------------------------------------------
-- DEMO 2.2 · The same question as a CTE
-- WITH gives each step a name. Read it from top to bottom.
-- ---------------------------------------------------------------------

WITH customer_totals AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM payment
    GROUP BY customer_id
),
big_spenders AS (
    SELECT customer_id, total_spent
    FROM customer_totals
    WHERE total_spent > (SELECT AVG(total_spent) FROM customer_totals)
),
customer_country AS (
    SELECT cu.customer_id, co.country
    FROM customer AS cu
    JOIN address  AS a  ON a.address_id  = cu.address_id
    JOIN city     AS ci ON ci.city_id    = a.city_id
    JOIN country  AS co ON co.country_id = ci.country_id
)
SELECT cc.country, COUNT(*) AS big_spenders
FROM big_spenders AS bs
JOIN customer_country AS cc ON cc.customer_id = bs.customer_id
GROUP BY cc.country
ORDER BY big_spenders DESC, cc.country
LIMIT 10;
-- Same answer as DEMO 2.1. customer_totals is written once and used twice.


-- ---------------------------------------------------------------------
-- DEMO 2.3 · Check one step at a time
-- Keep the WITH part and change only the final SELECT.
-- ---------------------------------------------------------------------

WITH customer_totals AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM payment
    GROUP BY customer_id
),
big_spenders AS (
    SELECT customer_id, total_spent
    FROM customer_totals
    WHERE total_spent > (SELECT AVG(total_spent) FROM customer_totals)
)
SELECT *
FROM big_spenders
ORDER BY total_spent DESC;


-- ---------------------------------------------------------------------
-- DEMO 2.4 · A CTE lasts for one statement only
-- ---------------------------------------------------------------------

-- This fails: customer_totals existed only inside the statement above
SELECT * FROM customer_totals;
-- To reuse a query in many statements, save it as a view (CREATE VIEW).


-- ---------------------------------------------------------------------
-- EXERCISE 2A · Build a query in CTE steps
-- Which 5 actors appear in the films that were rented most often?
--   Step 1  film_rentals: the number of rentals per film_id
--           (rental joins to inventory; inventory has film_id)
--   Step 2  actor_rentals: add up film_rentals per actor_id (use film_actor)
--   Step 3  final SELECT: join actor for first_name and last_name,
--           sort by rentals and keep the top 5
-- Check each step with SELECT * FROM <step> before you move on.
-- ---------------------------------------------------------------------
-- TODO: write your query here

WITH rental_count AS(
	SELECT i.film_id, count(i.film_id) AS rentals
	FROM inventory i  
	GROUP BY i.film_id
),
actor_rentals AS(
	SELECT fa.actor_id, SUM(rc.rentals) AS rentals
	FROM film_actor fa 
	JOIN rental_count AS rc ON rc.film_id = fa.film_id 
	GROUP BY fa.actor_id 
)
SELECT a.first_name, a.last_name, ar.rentals
FROM actor_rentals AS ar
JOIN actor AS a ON a.actor_id = ar.actor_id
ORDER BY ar.rentals DESC, a.last_name 
LIMIT 5;



-- ---------------------------------------------------------------------
-- EXERCISE 2B · Stretch
-- Reuse your steps from 2A. Keep only the actors whose rental total is
-- above the average actor's total. How many actors is that?
-- ---------------------------------------------------------------------
-- TODO: write your query here





-- ---------------------------------------------------------------------
-- DEMO 2.5 · A recursive CTE builds a calendar (a "date spine")
-- Question: on how many days did the stores rent nothing at all?
-- GROUP BY only returns days that have rentals, so first we need a row
-- for every day, then we LEFT JOIN the rentals to it.
-- ---------------------------------------------------------------------
WITH RECURSIVE
bounds AS (
    SELECT MIN(rental_date)::date AS first_day,
           MAX(rental_date)::date AS last_day
    FROM rental
),
calendar AS (
    SELECT first_day AS day           -- anchor: start with the first day
    FROM bounds
    UNION ALL
    SELECT cal.day + 1                -- recursive step: add the next day
    FROM calendar AS cal
    WHERE cal.day < (SELECT last_day FROM bounds)        -- stop at the last day
)
SELECT day FROM calendar;



WITH RECURSIVE
bounds AS (
    SELECT MIN(rental_date)::date AS first_day,
           MAX(rental_date)::date AS last_day
    FROM rental
),
calendar AS (
    SELECT first_day AS day           -- anchor: start with the first day
    FROM bounds
    UNION ALL
    SELECT cal.day + 1                -- recursive step: add the next day
    FROM calendar AS cal
    WHERE cal.day < (SELECT last_day FROM bounds)        -- stop at the last day
),
daily_rentals AS (
    SELECT rental_date::date AS day, COUNT(*) AS rentals
    FROM rental
    GROUP BY rental_date::date
)
SELECT cal.day,
       COALESCE(dr.rentals, 0) AS rentals
FROM calendar AS cal
LEFT JOIN daily_rentals AS dr ON dr.day = cal.day
ORDER BY cal.day;

-- Same calendar, now counting the empty days
WITH RECURSIVE
bounds AS (
    SELECT MIN(rental_date)::date AS first_day,
           MAX(rental_date)::date AS last_day
    FROM rental
),
calendar AS (
    SELECT first_day AS day FROM bounds
    UNION ALL
    SELECT cal.day + 1
    FROM calendar AS cal
    WHERE cal.day < (SELECT last_day FROM bounds)
),
daily_rentals AS (
    SELECT rental_date::date AS day, COUNT(*) AS rentals
    FROM rental
    GROUP BY rental_date::date
)
SELECT COUNT(*) AS days_without_rentals
FROM calendar AS cal
LEFT JOIN daily_rentals AS dr ON dr.day = cal.day
WHERE dr.day IS NULL;
-- PostgreSQL also has generate_series() for calendars. The recursive
-- pattern works in most databases, and it can also walk hierarchies
-- such as the Employees/ManagerID table from Data Modelling.


-- =====================================================================
--  PART 3 · WINDOW FUNCTIONS
-- =====================================================================

-- ---------------------------------------------------------------------
-- DEMO 3.1 · GROUP BY collapses rows. A window keeps them.
-- ---------------------------------------------------------------------

-- GROUP BY: one row per customer
SELECT customer_id, SUM(amount) AS total_spent
FROM payment
WHERE customer_id IN (1, 2)
GROUP BY customer_id;

-- Window: every payment stays, with its customer's total alongside
SELECT customer_id,
       payment_date,
       amount,
       SUM(amount) OVER (PARTITION BY customer_id) AS customer_total,
       ROUND(100 * amount / SUM(amount) OVER (PARTITION BY customer_id), 1)
           AS pct_of_customer_total
FROM payment
WHERE customer_id IN (1, 2)
ORDER BY customer_id, payment_date;
-- PARTITION BY splits the rows into groups. The function is calculated
-- within each group, and the answer is written on every row.


-- ---------------------------------------------------------------------
-- DEMO 3.2 · Three ways to number rows: ROW_NUMBER, RANK, DENSE_RANK
-- Question: rank the films in each category by how often they were rented.
-- ---------------------------------------------------------------------

WITH film_rentals AS (
    SELECT c.name AS category, f.title, COUNT(*) AS rentals
    FROM rental AS r
    JOIN inventory     AS i  ON i.inventory_id = r.inventory_id
    JOIN film          AS f  ON f.film_id      = i.film_id
    JOIN film_category AS fc ON fc.film_id     = f.film_id
    JOIN category      AS c  ON c.category_id  = fc.category_id
    GROUP BY c.name, f.title
)
SELECT category,
       title,
       rentals,
       ROW_NUMBER() OVER (PARTITION BY category ORDER BY rentals DESC) AS row_num,
       RANK()       OVER (PARTITION BY category ORDER BY rentals DESC) AS rank_num,
       DENSE_RANK() OVER (PARTITION BY category ORDER BY rentals DESC) AS dense_rank_num
FROM film_rentals
ORDER BY category, rentals DESC, title;
-- Look at films with the same number of rentals:
--   ROW_NUMBER  always 1, 2, 3, 4 ...   ties get different numbers
--   RANK        1, 2, 2, 4 ...           ties share; the next number is skipped
--   DENSE_RANK  1, 2, 2, 3 ...           ties share; nothing is skipped


-- ---------------------------------------------------------------------
-- DEMO 3.3 · ROW_NUMBER needs a tie-breaker
-- With ties, PostgreSQL may number the tied rows in any order, and the
-- order can change between runs. Add a second ORDER BY column that is
-- unique, so the same data always gives the same numbers.
-- ---------------------------------------------------------------------

WITH film_rentals AS (
    SELECT c.name AS category, f.title, COUNT(*) AS rentals
    FROM rental AS r
    JOIN inventory     AS i  ON i.inventory_id = r.inventory_id
    JOIN film          AS f  ON f.film_id      = i.film_id
    JOIN film_category AS fc ON fc.film_id     = f.film_id
    JOIN category      AS c  ON c.category_id  = fc.category_id
    GROUP BY c.name, f.title
)
SELECT category,
       title,
       rentals,
       ROW_NUMBER() OVER (PARTITION BY category
                          ORDER BY rentals DESC, title) AS row_num,
       RANK()       OVER (PARTITION BY category ORDER BY rentals DESC) AS rank_num,
       DENSE_RANK() OVER (PARTITION BY category ORDER BY rentals DESC) AS dense_rank_num
FROM film_rentals
ORDER BY category, row_num;


-- ---------------------------------------------------------------------
-- DEMO 3.4 · Top 3 per category
-- ---------------------------------------------------------------------

-- This fails: WHERE runs before window functions are calculated
WITH film_rentals AS (
    SELECT c.name AS category, f.title, COUNT(*) AS rentals
    FROM rental AS r
    JOIN inventory     AS i  ON i.inventory_id = r.inventory_id
    JOIN film          AS f  ON f.film_id      = i.film_id
    JOIN film_category AS fc ON fc.film_id     = f.film_id
    JOIN category      AS c  ON c.category_id  = fc.category_id
    GROUP BY c.name, f.title
)
SELECT category, title, rentals
FROM film_rentals
WHERE RANK() OVER (PARTITION BY category ORDER BY rentals DESC) <= 3;

-- Works: calculate the rank in one step, filter on it in the next
WITH film_rentals AS (
    SELECT c.name AS category, f.title, COUNT(*) AS rentals
    FROM rental AS r
    JOIN inventory     AS i  ON i.inventory_id = r.inventory_id
    JOIN film          AS f  ON f.film_id      = i.film_id
    JOIN film_category AS fc ON fc.film_id     = f.film_id
    JOIN category      AS c  ON c.category_id  = fc.category_id
    GROUP BY c.name, f.title
),
ranked AS (
    SELECT category,
           title,
           rentals,
           RANK() OVER (PARTITION BY category ORDER BY rentals DESC) AS rank_num
    FROM film_rentals
)
SELECT category, rank_num, title, rentals
FROM ranked
WHERE rank_num <= 3
ORDER BY category, rank_num, title;
-- RANK keeps every film tied for 3rd place, so some categories show more
-- than 3 rows. Use ROW_NUMBER (with a tie-breaker) for exactly 3.


-- ---------------------------------------------------------------------
-- DEMO 3.5 · Latest record per key
-- Data engineers use this pattern daily to remove duplicates: keep only
-- the newest row for each customer, order, claim ...
-- ---------------------------------------------------------------------

WITH ranked AS (
    SELECT customer_id,
           rental_id,
           rental_date,
           ROW_NUMBER() OVER (PARTITION BY customer_id
                              ORDER BY rental_date DESC, rental_id DESC) AS rn
    FROM rental
)
SELECT customer_id, rental_id, rental_date
FROM ranked
WHERE rn = 1
ORDER BY customer_id;


-- ---------------------------------------------------------------------
-- EXERCISE 3A · Top 3 customers in each store
-- Rank customers by total spend within each store (customer.store_id)
-- and keep the top 3 in each store. Ties should share a place.
-- Show store_id, the rank, first_name, last_name and total spend.
-- ---------------------------------------------------------------------
-- TODO: write your query here





-- ---------------------------------------------------------------------
-- DEMO 3.6 · LAG and LEAD look at the previous and next row
-- Question: how many days pass between a customer's rentals?
-- ---------------------------------------------------------------------

SELECT customer_id,
       rental_date::date                  AS rental_day,
       LAG(rental_date::date) OVER w      AS previous_day,
       rental_date::date
         - LAG(rental_date::date) OVER w  AS days_since,
       LEAD(rental_date::date) OVER w     AS next_day
FROM rental
WHERE customer_id = 1
WINDOW w AS (PARTITION BY customer_id ORDER BY rental_date, rental_id)
ORDER BY rental_date;
-- The first row has no previous row, so LAG returns NULL.
-- WINDOW w AS (...) names a window once so it can be reused.


-- ---------------------------------------------------------------------
-- DEMO 3.7 · Running totals and moving averages
-- ---------------------------------------------------------------------

WITH daily_revenue AS (
    SELECT payment_date::date AS day, SUM(amount) AS revenue
    FROM payment
    GROUP BY payment_date::date
)
SELECT day,
       revenue,
       SUM(revenue) OVER (ORDER BY day) AS running_total,
       ROUND(AVG(revenue) OVER (ORDER BY day
                                ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2)
           AS avg_last_7_rows
FROM daily_revenue
ORDER BY day;
-- With ORDER BY, SUM adds up from the first row to the current row.
-- Without ORDER BY (DEMO 3.1), it uses the whole partition.
-- ROWS BETWEEN 6 PRECEDING AND CURRENT ROW is a "frame": the current row
-- and the 6 before it. Careful: 7 rows is only 7 days if no day is
-- missing. Join to a calendar (DEMO 2.5) first to fill the gaps.


-- ---------------------------------------------------------------------
-- EXERCISE 3B · Month on month
-- For each month show revenue, the change from the previous month and a
-- running total.
-- Hint: DATE_TRUNC('month', payment_date) gives the first day of the month.
-- ---------------------------------------------------------------------
-- TODO: write your query here





-- ---------------------------------------------------------------------
-- EXERCISE 3C · Stretch
-- Show each customer's first ever rental: customer_id, rental_date and
-- the film title. Make sure the result is the same every time you run it.
-- ---------------------------------------------------------------------
-- TODO: write your query here





-- =====================================================================
--  PART 4 · TRANSACTIONS
--  Run these one statement at a time (Ctrl+Enter) and read each result.
--  Always finish a transaction with COMMIT or ROLLBACK: an open
--  transaction can hold locks that make other people's queries wait.
-- =====================================================================

-- ---------------------------------------------------------------------
-- DEMO 4.0 · Set up (run this block once, with Alt+X)
-- Creates two small tables in your schema, shaped like Pagila's rental
-- and payment tables, plus a summary table for DEMO 4.5.
-- Running it again resets them. Replace xx_ with your initials first:
-- everyone shares ade_1, so the initials keep your tables apart.
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS ade_1.xx_payment_demo;
DROP TABLE IF EXISTS ade_1.xx_rental_demo;
DROP TABLE IF EXISTS ade_1.xx_daily_revenue;

CREATE TABLE ade_1.xx_rental_demo (
    rental_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rental_date  TIMESTAMPTZ NOT NULL DEFAULT now(),
    inventory_id INT NOT NULL,
    customer_id  INT NOT NULL,
    staff_id     INT NOT NULL
);

CREATE TABLE ade_1.xx_payment_demo (
    payment_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rental_id    INT NOT NULL REFERENCES ade_1.xx_rental_demo (rental_id),
    customer_id  INT NOT NULL,
    staff_id     INT NOT NULL,
    amount       NUMERIC(5,2) NOT NULL CHECK (amount >= 0),
    payment_date TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE ade_1.xx_daily_revenue (
    day       DATE PRIMARY KEY,
    revenue   NUMERIC(10,2) NOT NULL,
    payments  INT NOT NULL,
    loaded_at TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ---------------------------------------------------------------------
-- DEMO 4.1 · All or nothing: renting a film is two inserts
-- A rental row and its payment row must be saved together, or not at all.
-- ---------------------------------------------------------------------

BEGIN;

INSERT INTO ade_1.xx_rental_demo (inventory_id, customer_id, staff_id)
VALUES (1, 1, 1);

INSERT INTO ade_1.xx_payment_demo (rental_id, customer_id, staff_id, amount)
VALUES (currval('ade_1.xx_rental_demo_rental_id_seq'), 1, 1, 0.99);
-- currval(...) is the rental_id this session has just generated

COMMIT;

SELECT * FROM ade_1.xx_rental_demo;
SELECT * FROM ade_1.xx_payment_demo;


-- ---------------------------------------------------------------------
-- DEMO 4.2 · An error part-way through
-- ---------------------------------------------------------------------

BEGIN;

INSERT INTO ade_1.xx_rental_demo (inventory_id, customer_id, staff_id)
VALUES (2, 2, 1);

-- This breaks the CHECK rule (amount >= 0), so it fails
INSERT INTO ade_1.xx_payment_demo (rental_id, customer_id, staff_id, amount)
VALUES (currval('ade_1.xx_rental_demo_rental_id_seq'), 2, 1, -0.99);

-- After an error, PostgreSQL refuses every statement until the
-- transaction ends: "current transaction is aborted"
SELECT * FROM ade_1.xx_rental_demo;

ROLLBACK;

-- Still one rental: the half-finished rental was undone with the payment
SELECT * FROM ade_1.xx_rental_demo;
-- Note: the next rental_id skips a number. IDs used inside a rolled-back
-- transaction are not reused, so gaps in IDs are normal.


-- ---------------------------------------------------------------------
-- DEMO 4.3 · ROLLBACK as a safety net
-- Make risky changes inside a transaction, check them, then decide.
-- ---------------------------------------------------------------------

BEGIN;

DELETE FROM ade_1.xx_payment_demo;           -- oops: no WHERE

SELECT COUNT(*) AS payments_left FROM ade_1.xx_payment_demo;   -- 0

ROLLBACK;

SELECT COUNT(*) AS payments_left FROM ade_1.xx_payment_demo;   -- back


-- ---------------------------------------------------------------------
-- DEMO 4.4 · Isolation: other sessions see only committed work
-- You need two SQL editors. Open a second one with Ctrl+] (Cmd+] on a Mac).
-- Run the A lines here and the B lines in the second editor, in order.
-- ---------------------------------------------------------------------

-- A1 (this editor): start a change, but do not commit yet
BEGIN;
UPDATE ade_1.xx_payment_demo SET amount = 4.99 WHERE customer_id = 1;
SELECT customer_id, amount FROM ade_1.xx_payment_demo;   -- A sees 4.99

-- B1 (second editor): copy and run this there
--     SELECT customer_id, amount FROM ade_1.xx_payment_demo;
--     B still sees 0.99: A's change is not committed

-- B2 (second editor): try to change the same row
--     UPDATE ade_1.xx_payment_demo SET amount = 2.99 WHERE customer_id = 1;
--     B waits: A holds a lock on that row until A finishes

-- A2 (this editor): finish the transaction
COMMIT;
-- B's UPDATE now completes. Run B1 again in the second editor: 2.99


-- ---------------------------------------------------------------------
-- DEMO 4.5 · A load that is safe to rerun
-- A nightly job rebuilds a summary table: delete the old rows, insert
-- the new ones. Inside one transaction, nobody ever sees an empty table,
-- and running it twice gives the same result.
-- ---------------------------------------------------------------------

BEGIN;

DELETE FROM ade_1.xx_daily_revenue;

INSERT INTO ade_1.xx_daily_revenue (day, revenue, payments)
SELECT payment_date::date, SUM(amount), COUNT(*)
FROM payment
GROUP BY payment_date::date;

COMMIT;

SELECT COUNT(*) AS days, SUM(revenue) AS total_revenue
FROM ade_1.xx_daily_revenue;
-- Run the whole block again: the numbers do not change.


-- ---------------------------------------------------------------------
-- EXERCISE 4A · Record a rental
-- In one transaction, record a rental and its payment:
-- customer_id 3, inventory_id 10, staff_id 2, amount 2.99.
-- Commit, then check both tables.
-- ---------------------------------------------------------------------
-- TODO: write your query here





-- ---------------------------------------------------------------------
-- EXERCISE 4B · Practise a delete, then undo it
-- In one transaction, delete customer 3's payment and rental.
-- Check that both have gone, then ROLLBACK and check they are back.
-- Hint: xx_payment_demo refers to xx_rental_demo, so which must go first?
-- ---------------------------------------------------------------------
-- TODO: write your query here





-- ---------------------------------------------------------------------
-- EXERCISE 4C · Stretch: reconcile the load
-- Run the load from DEMO 4.5 twice. Each time, show that the total in
-- xx_daily_revenue matches the total of main.payment.
-- ---------------------------------------------------------------------
-- TODO: write your query here





-- =====================================================================
--  END · Next: Advanced SQL 2 (indexing, query plans, stored procedures)
-- =====================================================================
