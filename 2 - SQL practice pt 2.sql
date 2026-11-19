---------------------------------------------
--------- SQL in practice - part 2 ----------
---------------------------------------------

---- DIGITAL FUTURES
---- SQL: JOINS, CASE, UNION & more practice

-----------------------------------------------------------------------------------------------------------
-------- CONTENTS
-----------------------------------------------------------------------------------------------------------
/*
DF10	INNER JOINS
DF11	LEFT & RIGHT JOINS
DF12	FULL JOINS
DF13	CASE 
DF14    UNION 
DF-A	PRACTICE TASKS
*/

-----------------------------------------------------------------------------------------------------------
-------- DF10 -- INNER JOINS
-----------------------------------------------------------------------------------------------------------


-- Let's go to EXCEL! 



-- Welcome back =D Now lets try in the database.
-- EX -- Where do the customers live? Let's join customer and address

SELECT 
	a.address_id 
	, c.customer_id 
	, c.first_name 
	, c.last_name 
	, a.address 
	FROM main.customer AS c
	INNER JOIN main.address AS a
	ON c.address_id = a.address_id;

SELECT 
	*
	FROM main.customer AS c
	INNER JOIN main.address AS a
	ON c.address_id = a.address_id;

SELECT 
	*
	FROM main.customer AS c
	INNER JOIN main.address AS a
	USING (address_id); --removes duplicate address_id column, only usable when keys that we want to combine have same name


-- EX -- Let's join customer, address, city and country! 



SELECT 
	a.address_id 
	, c.customer_id 
	, c.first_name 
	, c.last_name 
	, a.address 
	, c2.city 
	, c3.country 
	FROM main.customer c 
	INNER JOIN main.address a 
	USING(address_id)
	INNER JOIN main.city c2 
	USING(city_id)
	INNER JOIN main.country c3
	USING(country_id);


-- EX -- Combining joins with other queries. 
      -- List each film and the number of actors who are listed for that film.

SELECT 
	f.title 
	, COUNT(fa.actor_id) AS num_of_actors
	FROM main.film f 
	INNER JOIN main.film_actor fa 
	USING(film_id)
	GROUP BY f.film_id;


------------------------
-------- DF10 -- TASKS
------------------------
-- Task 1 -- How many copies of the film Hunchback Impossible exist in the inventory system?


SELECT 
	COUNT(f.film_id) AS num_of_copies
	FROM main.inventory i
	INNER JOIN main.film f 
	USING(film_id)
	WHERE f.title ILIKE ('Hunchback Impossible'); 


-- Task 2 -- Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name


SELECT
	c.customer_id 
	, c.first_name 
	, c.last_name 
	, SUM(p.amount)
	FROM main.payment p 
	INNER JOIN main.customer c
	USING(customer_id)
	GROUP BY(c.customer_id)
	ORDER BY (c.last_name);


-- Task 3 -- Write a query to display for each store its store ID, city, and country.

SELECT 
	s.store_id
	, city 
	, country
FROM main.store s 
INNER JOIN address a 
USING (address_id)
INNER join main.city c 
USING(city_id)
INNER JOIN main.country
using(country_id);


-----------------------------------------------------------------------------------------------------------
-------- DF11 -- LEFT & RIGHT JOINS
-----------------------------------------------------------------------------------------------------------



-- Task 1 --
          -- The marketing team are having a really tough day in the office, and running out of ideas. 
		  -- Their best idea, is to let people know how many films have actors in that share the same first name as the customer? 
		  -- For example. If a customer is called Alex. We want to let them know how many films have an actor called Alex in! 
		  

SELECT
	c.first_name AS customer_name
	--, a.actor_id 
	--, fa.film_id 
	--, a.first_name AS actor_name
	--, c.customer_id 
	, COUNT(fa.film_id) AS num_of_films
	FROM main.customer c
	LEFT JOIN main.actor a
	ON c.first_name = a.first_name
	LEFT JOIN main.film_actor fa 
	USING(actor_id)
	GROUP BY customer_id 
	ORDER BY customer_name;


-- Task 2 -- Create a list of all of the languages (by Name), and how many films we have in that language.
          -- If there are no films in that language, it should display 0.
          -- Order by the name of the language
          
SELECT 
	l."name" 
	, COUNT(f.film_id)
	FROM main."language" l
	LEFT JOIN main.film f 
	USING(language_id)
	GROUP BY name
	ORDER BY l."name";


-----------------------------------------------------------------------------------------------------------
-------- DF12 -- FULL JOINS
-----------------------------------------------------------------------------------------------------------

-- Task 1 -- Can you find any situation in the DB that needs a full join?

SELECT 
	c.first_name
	, a.actor_id 
	, a.first_name AS actor_name
	, c.customer_id 
	FROM main.actor a 
	FULL JOIN main.customer c 
	USING(first_name);

-----------------------------------------------------------------------------------------------------------
-------- DF13 -- CASE
-----------------------------------------------------------------------------------------------------------

-- EX --Let's use case to categorise the payment types as small, medium or large.

SELECT 
	p.amount
	, CASE
		WHEN p.amount <= 2 THEN 'Small'
		WHEN p.amount <= 7 THEN 'Medium' --anything already categorised will not be parsed into next statement
		ELSE 'Large'
	END AS payment_size
FROM main.payment p;

-- EX -- Let's combine that CASE statement with group by 




-- EX -- What if we want the average payment within each of those groups?



-- EX -- What if we want the counts!

SELECT 
	CASE
		WHEN p.amount <= 2 THEN 'Small'
		WHEN p.amount <= 7 THEN 'Medium' --anything already categorised will not be parsed into next statement
		ELSE 'Large'
	END AS payment_size
	, count(p.amount)
FROM main.payment p
GROUP BY payment_size
ORDER BY payment_size;

-- Task 1 --
          -- Create a list of all of the category_ids and whether they are fiction or non fiction 
		  -- travel, sports and documentaries are non_fiction! 

SELECT
	c.category_id 
	, CASE
		WHEN c.name ILIKE 'travel' THEN 'non_fiction'
		WHEN c.name ILIKE 'sports' THEN 'non_fiction'
		WHEN c.name ILIKE 'documentary' THEN 'non_fiction'
		ELSE 'fiction'
	END AS ficticious
	FROM main.category c;

-- Task 2 -- 
		  -- Create a list of rentals which a column based on whether it was a long or short rental. 
		  -- less than 2 days is short, anything longer is long! 

SELECT 
	r.rental_date 
	, r.return_date 
	, EXTRACT(DAY FROM r.return_date - r.rental_date) AS rental_days
	, CASE 
		WHEN EXTRACT(DAY FROM r.return_date - r.rental_date) < 2 THEN 'short'
		ELSE 'long'
	END AS rental_period
	FROM main.rental r;
		
-----------------------------------------------------------------------------------------------------------
-------- DF14 -- UNION
-----------------------------------------------------------------------------------------------------------
-- Union lets us join together 2 sets of data, glueing them on top of each other.

SELECT 'Hello' AS greeting, 1 AS num
UNION
SELECT 'Hello', 2
ORDER BY num;

-- What does Union All do? 

SELECT 'Hello' AS greeting, 1 AS num
UNION
SELECT 'Hello', 2
UNION
SELECT 'Hello', 1; --union can remove duplicates

SELECT 'Hello' AS greeting, 1 AS num
UNION ALL
SELECT 'Hello', 2
UNION ALL
SELECT 'Hello', 1; --union all just joins regardless, no duplicate checks - and is faster because of this




-- Task 
   -- Use SELECT to create some data (without selecting from the DB)
   -- e.g. SELECT 'HELLO', 'GOODBYE', 'SUP' 
   -- Do this a couple of times and UNION and UNION ALL them together. 
   -- What are the rules of UNION? 
   -- What are the rules of UNION ALL?
   



-----------------------------------------------------------------------------------------------------------
-------- DF-A -- TASKS
-----------------------------------------------------------------------------------------------------------

-- Task 1 -- 
-- The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- display the titles of movies starting with the letters K and Q whose language is English.

SELECT 
	f.title 
	FROM main.film f
	WHERE LEFT(f.title, 1) ILIKE 'k' OR LEFT(f.title, 1) ILIKE 'q' AND f.language_id = 1;

-- Task 2 -- 
-- You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

SELECT
	c.first_name
	, c.last_name 
	, c.email 
	, c3.country 
	FROM main.customer c
	INNER JOIN main.address a
	ON a.address_id = c.address_id
	INNER JOIN main.city c2
	ON a.city_id  = c2.city_id
	INNER JOIN main.country c3
	ON c2.country_id = c3.country_id
	WHERE c3.country ILIKE 'Canada';
	

-- TASK 3 -- 
-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as a family film.

SELECT
	f.title
	, c."name" 
	FROM main.film_category fc
	INNER JOIN main.category c 
	USING(category_id)
	INNER JOIN main.film f 
	USING(film_id)
	WHERE c."name" ILIKE 'family'; 

-- TASK 4 -- 
-- Display the most frequently rented movies in descending order.

SELECT 
	f.title
	, COUNT(i.film_id) AS num_of_times_rented
	FROM main.rental r
	INNER JOIN main.inventory i 
	USING (inventory_id)
	INNER JOIN main.film f 
	USING(film_id)
	GROUP BY(f.title);

-- TASK 5 -- 
-- Write a query to display how much business, in dollars, each store brought in.

SELECT
	SUM(p.amount)
	, c.city  
	FROM main.payment p
	INNER JOIN main.rental r 
	USING(rental_id)
	INNER JOIN main.staff s
	ON s.staff_id = r.staff_id
	INNER JOIN main.address a 
	USING(address_id)
	INNER JOIN main.city c 
	USING(city_id)
	GROUP BY c.city; 

-- TASK 6 -- 
-- List the top five genres in gross revenue in descending order.

SELECT
	SUM(p.amount)
	, c."name" 
	FROM main.payment p
	INNER JOIN main.rental r 
	USING(rental_id)
	INNER JOIN main.inventory i 
	USING(inventory_id)
	INNER JOIN main.film f 
	USING(film_id)
	INNER JOIN main.film_category fc
	USING(film_id)
	INNER JOIN main.category c
	USING(category_id)
	GROUP BY c."name"
	ORDER BY SUM(p.amount) DESC
	LIMIT 5; 

-- Bonus Where  -- Working with Full Text Search
-- https://www.compose.com/articles/mastering-postgresql-tools-full-text-search-and-phrase-search/