---------------------------------------------
--------- SQL in practice - part 1 ----------
---------------------------------------------

---- DIGITAL FUTURES
---- SQL: SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY, LIMIT

-----------------------------------------------------------------------------------------------------------
-------- CONTENTS
-----------------------------------------------------------------------------------------------------------
/*
DF1	COMMENTS
DF2	SELECTING FROM THE SERVER
DF3	SELECTING FROM THE DATABASE
DF4	ORDERING THE RESULTS (ORDER BY)
DF5	CHOOSING ROWS (Where)
DF6	FUNCTIONS & Maths
DF7	AGGREGATES
DF8	GROUPED AGGREGATES
DF9     NULLS
*/
-----------------------------------------------------------------------------------------------------------
-------- Instructions 
-----------------------------------------------------------------------------------------------------------
/*
EX   - (Short for example) Your instructor will show you how to do this! 
TASK - An exercise for you to try! 

SCHEMA:
https://dataedo.com/samples/html/Pagila/doc/Pagila_10/home.html

Notes before we begin: 
	> We don't always start by doing things the "Best" way. 
	> This is to help the learning order - we start with the basics and then build from there! 
*/



/* logical execution order of SQL
FROM
WHERE
GROUP BY
AGGREGATE
HAVING
SELECT
ORDER by
limit
*/



-----------------------------------------------------------------------------------------------------------
-------- DF1 -- Comments 
-----------------------------------------------------------------------------------------------------------

-- First things first 
-- Two dashes means it's a comment. 
-- The server will ignore things in comments. 


--We can also do long comments. Between the open /*   and close    */
/*
comment
comment
comment
*/


-----------------------------------------------------------------------------------------------------------
-------- DF2 -- SELECTING FROM THE SERVER
-----------------------------------------------------------------------------------------------------------

-- For a refresher see: `0 - SQL basics.sql` -- `SELECT`

/*  
We can specify the column name we would like to see for each column. 
The 'AS' keyword is technically optional.
A word on it's own after the column will become the columns name! 
It can't be a reserved word. 
It *could* have spaces, but it shouldn't! #best-practice!
*/

SELECT 
	'HELLO' AS greeting, 
	439859 as random_number, 
	CURRENT_DATE,
   	'spaces are the worst' dont_use_spaces;

-----------------------------------------------------------------------------------------------------------
-------- DF3 -- SELECTING FROM THE DATABASE
-----------------------------------------------------------------------------------------------------------

-- For a refresher see: `0 - SQL basics.sql` -- `FROM`

/* 
SELECT 
{{WHAT COLUMNS TO SELECT}}
FROM 
{WHICH TABLE IN THE DATABASE}
*/
  
  
  
--- How do we know where the table is? 
--- Every table address has two parts -> the schema name, and the table name! 
  
--- A schema is basically a "folder" -> it keeps our database neat and tidy. 
--- We group other tables together in a 'schema' called after the project name 
  
-- For most of our examples, we use the "main" schema. Here some example tables:
-- main.customer 
-- main.film
-- main.category 

------------------------
-------- DF3 -- EXAMPLES
------------------------

-- EX -- Who are our customers?
      -- What are their first and last names?
  
SELECT
	first_name
	, last_name 
	FROM main.customer;

	
-- EX -- What addresses do we have in our database?
      -- What are the address, district and postal_code for the addresses?

SELECT 
	address
	, district
	, postal_code
	FROM main.address;
	
  
-- EX -- What films do we have in our database?
      -- Return all of the columns.

SELECT
	*
	FROM main.film;

------------------------
-------- DF3 -- TASKS
------------------------

-- TASK 1 -- What are the first and last names of the ACTORs in our database?

SELECT 
	first_name
	, last_name
	FROM main.actor;

-- TASK 2 -- What are the film CATEGORY names in our database?

SELECT 
	name
	FROM main.category;

-- TASK 3 -- What are the LANGUAGEs in our database?

SELECT 
	name
	FROM main."language";


-- TASK 4 --  Extract the columns customer_id, amount, and payment_date from the payment table.

SELECT 
	customer_id
	, amount
	, payment_date
	FROM main.payment; 

-----------------------------------------------------------------------------------------------------------
-------- DF4 -- ORDERING THE RESULTS
-----------------------------------------------------------------------------------------------------------

-- For a refresher see: `0 - SQL basics.sql` -- `ORDER BY`

/* 
SELECT 
{{WHAT COLUMNS TO SELECT}}
FROM 
{WHICH TABLE IN THE DATABASE}
ORDER BY 
{COLUMN TO ORDER BY} {DIRECTION}
*/
-- The default Direction is ASC

------------------------
-------- DF4 -- EXAMPLES
------------------------


-- EX -- What films do we have in our database?
SELECT
	*
	FROM main.film;
-- EX -- What films do we have in our database - Ascending by title?
SELECT
	*
	FROM main.film
	ORDER BY title ASC;
-- EX -- What films do we have in our database - Descending by title?
SELECT
	*
	FROM main.film
	ORDER BY title DESC;
-- EX -- Breaking Ties. Select all of the payments - order by Amount. Order by Payment_ID
SELECT
	*
	FROM main.payment
	ORDER BY amount ASC, payment_id ASC;

 -- A "tie" is when we have two things with the same value. Which one comes first? 
 -- If we only sort by one column, the database will decide at random. 
  
 --  first_name    |    surname
-------------------------------------
 --     Alex       |     Zaian
 --     Alex       |     Caian
  
 -- In this example, if we order by "First Name" only, Zaian or Caian could come first -> it's random! 
 -- If we want to control the order, we'd specify to sort by first_name and surname 
------------------------
-------- DF4 -- TASKS
------------------------

-- TASK 1 -- Which Actor comes last alphabetically in our actor table (according to their surname)? 
		  -- Also sort by First name descending in case of ties.

SELECT
	first_name 
	, last_name
	FROM main.actor
	ORDER BY last_name DESC, first_name DESC
	LIMIT 1;

-- TASK 2 -- Which city name is first alphbabetically? 

SELECT 
	city
	FROM main.city
	ORDER BY city ASC
	LIMIT 1;

-- Task 3 -- What is our smallest postal_code? 

SELECT
	postal_code
	FROM main.address a 
	ORDER BY CAST(postal_code AS INT) ASC
	LIMIT 1;

SELECT
	postal_code
	FROM main.address a 
	ORDER BY postal_code::int ASC	--postgreSQL only
	LIMIT 1;

---------------------------------------
-------- DF4 -- BONUS EXAMPLES -- LIMIT
---------------------------------------

-- For a refresher see: `0 - SQL basics.sql` -- `LIMIT`

-- We can use the LIMIT command at the end, to limit the amount of results we get. 
-- Let's revisit the previous examples.



-----------------------------------------------------------------------------------------------------------
-------- DF5 -- CHOOSING ROWS
-----------------------------------------------------------------------------------------------------------

-- For a refresher see: `0 - SQL basics.sql` -- `WHERE`

/* 
SELECT 
{{WHAT COLUMNS TO SELECT}}
FROM 
{WHICH TABLE IN THE DATABASE}
WHERE 
 {{RULES ABOUT WHERE!}}
ORDER BY 
{COLUMN TO ORDER BY} {DIRECTION}

SELECT
FROM
WHERE 
ORDER BY

*/


------------------------
-------- DF5 -- EXAMPLES
------------------------

-- EX -- Who is customer 99? What do we know about them? 

SELECT 
	*
	FROM main.customer
	WHERE customer_id = 99;

-- EX -- Our customer IDs are assigned as ascending integers - who were our first 10 customers? 

SELECT 
	*
	FROM main.customer
	WHERE customer_id <= 10;

SELECT 
	*
	FROM main.customer
	ORDER BY customer_id 
	LIMIT 10;



-- EX -- There were some dark times for our 11th to 20th customer! 
      -- Bring back everyone except customers between 11 and 20! (including 11 and 20.)
	  -- We don't mention the dark times. 
      -- Lets explore the most basic way of finding the dark time customers!

SELECT 
	*
	FROM main.customer
	WHERE customer_id <= 10 OR customer_id > 20
	ORDER BY customer_id;
  
  
-- EX -- A quicker way of finding the dark time customers! 
      -- (Between is inclusive)

SELECT 
	*
	FROM main.customer
	WHERE customer_id BETWEEN 11 AND 20
	ORDER BY customer_id;

-- EX -- How about if we want to have everyone except the "dark time" customers
      -- just add NOT

SELECT 
	*
	FROM main.customer
	WHERE customer_id NOT BETWEEN 11 AND 20
	ORDER BY customer_id;

-- EX -- However if we are checking for = we use != as not equal

SELECT 
	*
	FROM main.customer
	WHERE customer_id != 1
	ORDER BY customer_id
	LIMIT 10;

SELECT 
	*
	FROM main.customer
	WHERE customer_id <> 1
	ORDER BY customer_id
	LIMIT 10;

-- EX -- You can also use less than / greater than on strings.
	  -- Which films start with something less than C?

SELECT 
	title
	FROM main.film
	WHERE title < 'c';

/*
 * Less than/Greater than a string might seem a little confusing -> it's actually simple!
 * Just think about where the strings would go in an 'order by'
 * 
 * A
 * A great film
 * B
 * Bravo Film 
 * C
 * Creative Film
 * D
 * Dandy Film
 */
------------------------
-------- DF5 -- TASKS
------------------------

-- TASK 1 -- Display the payments greater than $4.99 (including $4.99)

SELECT 
	* 
	FROM main.payment
	WHERE amount <= 4.99
	ORDER BY amount DESC;
	
-- TASK 2 -- Find all of the staff who work for the store with store_id 1

SELECT 
	*
	FROM main.staff
	WHERE store_id = 1;

	
-- TASK 3 -- Find all the films in the database that aren't in English. 
		  -- (You might need a couple of steps)

SELECT 
	*
	FROM main.film
	WHERE language_id  <> 1;

------------------------
-------- DF5 -- MORE EXAMPLES
------------------------

-- EX -- What if we want to look for text? 
      -- Let's find customers called jared
  
SELECT 
	*
	FROM main.customer
	WHERE first_name = 'jared';
  
-- No results -> the equal clause is case sensitive!

SELECT 
	*
	FROM main.customer
	WHERE LOWER(first_name) = 'jared';

SELECT 
	*
	FROM main.customer
	WHERE UPPER(first_name) = 'JARED';

-- We can also do partial comparisons. 
-- EX --  Let's find names starting with J

SELECT 
	*
	FROM main.customer
	WHERE LOWER(first_name) LIKE 'j%'; --% is 'wild card' so this is anything starting with j

SELECT 
	*
	FROM main.customer
	WHERE first_name ILIKE 'j%'; --% ILIKE only postgreSQL and a couple others
	
-- EX --  Names with an e at the end

SELECT 
	*
	FROM main.customer
	WHERE LOWER(first_name) LIKE '%e'

-- EX --  names with e in the middle. 

SELECT 
	*
	FROM main.customer
	WHERE LOWER(first_name) LIKE '%_e_%'; -- _ means expecting at least 1 character. so here infront and behind 'e'

-- EX --  if we want to do a case insensitive check. 


 


-- EX --  What if we'd like multiple? Names that start with A and have an E in there.

SELECT 
	*
	FROM main.customer
	WHERE first_name ILIKE 'a%' AND LOWER(first_name) LIKE '%_e_%';
	

-- EX --  What about names that start with A or B?

SELECT 
	*
	FROM main.customer
	WHERE LOWER(first_name) LIKE 'a%' OR LOWER(first_name) LIKE 'b%';

-- EX -- What if we'd like to bring back multiple exact entries?
-- Let's display the country_id for 'Afghanistan','Bangladesh' and 'China'

SELECT 
	*
	FROM main.country
	WHERE country = 'Afghanistan' OR country = 'Bangladesh' OR country = 'China';

-- EX --  There's a quicker way ! 

SELECT 
	*
	FROM main.country
	WHERE country IN ('Afghanistan','Bangladesh','China') ;


------------------------
-------- DF5 -- MORE TASKS
------------------------

-- TASK 1 -- Find Actors whose first_names start with P. 

SELECT
	first_name
	FROM main.actor
	WHERE first_name ILIKE 'p%';

-- TASK 2 -  Find the films with Christmas in the title 
SELECT
	title
	FROM main.film
	WHERE title ILIKE '%christmas%';
	


-- TASK 3 - Find Films that cost less than $4.99 and the films starts with A or B.  (you should only return films that begin with (A or B) and are less than $4.99!)

SELECT
	title
	, rental_rate 
	FROM main.film
	WHERE rental_rate < 4.99 AND (title ILIKE 'a%' OR title ILIKE 'b%');
  
-- TASK 4 - My son is 13, and can only watch a film that is 60 minutes or less, and I have only $2.99! Please find a list of films suitable (Pg-13 or less, 60 minuutes or less and 2.99 or less)
		  -- Please order the list by the cheaperst ones to rent first for me. 
		  -- and then by the cost of replacement (i want the most expensive to replace first). 
		  -- and then by title.

SELECT
	*
	FROM main.film
	WHERE rental_rate <= 2.99 AND length <= 60 AND (rating = 'PG-13' OR rating = 'G' OR rating = 'PG')
	ORDER BY rental_rate ASC, replacement_cost DESC, title ASC;


-----------------------------------------------------------------------------------------------------------
-------- DF6 -- FUNCTIONS & MATHS
-----------------------------------------------------------------------------------------------------------

-- SQL has functions that can do things to our data 
-- If we're using SELECT, we aren't actually changing the data -> just what we're returning. 
-- The different parts of the query are separate! 

-- EX -- We can change the case to upper case

--UPPER()

-- EX -- We can change the case to lower case

--LOWER()

-- EX -- Concat (stands for concatenation) is putting together two things! 

--CONCAT()

-- EX -- Let's concatenate the actor names

SELECT 
	CONCAT(first_name, ' ', last_name) AS full_name
	FROM main.actor;


-- EX -- The Left 

SELECT 
	LEFT(first_name, 3) -- leftmost 3 characters
	FROM main.actor;
  
  
-- EX -- Find all customers whose first names start with A, B, C, D, E, F or G


SELECT 
	*
	FROM main.actor
	WHERE LEFT(first_name, 1) < 'H';  


-- EX -- The Right 

SELECT 
	RIGHT(first_name, 3) --rightmost 3 characters
	FROM main.actor;
	
	
-- EX --The middle 

SELECT 
	SUBSTRING(first_name, 2, 3)	--from 2nd char, for 3 characters
	FROM main.actor;

-- EX --The Len
	
SELECT 
	length(first_name)
	FROM main.actor;
	
	
-- EX -- Distinct (not a function technically!)

SELECT 
	DISTINCT first_name		--will only give unique output
	FROM main.actor
	WHERE LOWER(first_name) = 'kenneth';

-- EX -- SQL can also maths

SELECT
	amount + amount AS ADD
	, amount - amount AS SUB
	, amount * amount AS MULTI
	, amount / amount AS DIV
	, MOD(amount, amount) AS MOD
	FROM main.payment;


------------------------
-------- DF6 -- TASKS
------------------------

-- TASK 1 -- Create a list of all of the actors with their last_name, first initial and a dot. 
          -- e.g. Penelope Guiness should be "Guiness P."
		  
SELECT
	CONCAT(a.last_name, ' ', LEFT(a.first_name, 1), '.') AS new_name
	FROM main.actor a;
	
	
-- TASK 2 -- Create a list of all of the active customer. 
	      -- create a column called 'Customer_name' it should contain their first name, the first initial of their last_name and asterisks (*) to hide the rest of their surname. 
		  -- Easier -> Just put in a set number of asterisks regardless of the length of the surname so Jared Ely becomes Jared E*****, and Mary Smith becomes Mary S*****. 
		  -- Harder -> Put in the correct number of asterisks for the length of the surname. So Jared Ely becomes Jared E**, and Mary Smith becomes Mary S****. (You'll need a new function we've not used)

SELECT 
	c.activebool 
	, CONCAT(c.first_name, ' ', LEFT(c.last_name, 1), '****') AS new_name
	FROM main.customer c
	WHERE c.activebool = true;

SELECT 
	CONCAT(first_name, ' ', LEFT(last_name, 1), REPEAT('*',LENGTH(last_name)-1 )) AS Customer_name
	FROM main.customer
	WHERE activebool = TRUE;


-----------------------------------------------------------------------------------------------------------
-------- DF7 -- AGGREGATES
-----------------------------------------------------------------------------------------------------------

-- An aggregate can calculate something across all of the rows for us.
-- EX -- Let's count things ! How many customers do we have.

SELECT
	count(*)
	FROM main.customer;

-- EX --How many distinct customer first_names do we have?

SELECT
	count(DISTINCT(first_name))
	FROM main.customer;

-- EX -- What is the smallest payment we've had?

SELECT
	MIN(p.amount) 
	FROM main.payment p; 

-- EX -- what is the largest payment we've had?
  
SELECT
	MAX(p.amount) 
	FROM main.payment p; 

-- EX -- what is average of payments?
  
SELECT
	AVG(p.amount) 
	FROM main.payment p; 

-- EX -- What is the smallest and largest payment value, and the average payment value we've had?

SELECT
	MIN(p.amount) AS min
	, MAX(p.amount) AS max
	, ROUND(AVG(p.amount), 2) AS average
	FROM main.payment p; 
 
------------------------
-------- DF7 -- TASKS
------------------------

-- TASK 1 -- What is the first ever rental date in the rental table?

SELECT 
	MIN(r.rental_date) AS first_rental
	FROM main.rental r;
	
-- TASK 2 - What is the most recent update on a record in the rental table?

SELECT 
	MAX(r.rental_date) AS recent_rental
	FROM main.rental r;
	
-- TASK 3 - What were the min, max and average payments for PAYMENTS made by STAFF_ID 1?

SELECT 
	MIN(p.amount) AS min_payment
	, MAX(p.amount) AS max_payment
	, ROUND(AVG(p.amount), 2) AS avg_payment
	FROM main.payment p
	WHERE p.staff_id = 1;


-- TASK 4 - What were the min, max and average payments for PAYMENTS made by STAFF_ID 2?

SELECT 
	MIN(p.amount) AS min_payment
	, MAX(p.amount) AS max_payment
	, ROUND(AVG(p.amount), 2) AS avg_payment
	FROM main.payment p
	WHERE p.staff_id = 2;

-----------------------------------------------------------------------------------------------------------
-------- DF8 -- GROUPED AGGREGATES
-----------------------------------------------------------------------------------------------------------


-- EX --  What happens if we try to include a non-aggregate and aggregate?
--- What are the min, max and average amounts of payment - for each staff_id ? 

SELECT 
	staff_id 
	, MIN(amount) AS min_payment
	, MAX(amount) AS max_payment
	, ROUND(AVG(amount), 2) AS avg_payment
	FROM main.payment
	GROUP BY staff_id;

-- EX --  What are the counts of how many films there are in each category? 

SELECT 
	category_id
	, COUNT(category_id) AS num_of_films
	FROM main.film_category
	GROUP BY category_id;

-- EX --  Let's take a look at having.
-- Which last_names are shared by 2 or more actors?

SELECT 
	last_name
	, COUNT(last_name) AS nb_last_names
	FROM main.actor
	GROUP BY last_name
	HAVING COUNT(last_name) >= 2;
  

--where executes before select so cannot use where for variables declared in select, use having instead

/* logical execution order of SQL
FROM
WHERE
GROUP BY
AGGREGATE
HAVING
SELECT
ORDER by
limit
*/

/* 
SELECT 
{{WHAT COLUMNS TO SELECT}}
FROM 
{WHICH TABLE IN THE DATABASE}
WHERE 
 {{RULES ABOUT WHERE!}}
GROUP BY 
 {{COLUMNS TO GROUP BY}}
HAVING 
 {{HAVING CONDITION}}
ORDER BY 
{COLUMN TO ORDER BY} {DIRECTION}

SELECT
FROM
WHERE
GROUP BY 
HAVING
ORDER BY

*/


------------------------
-------- DF8 -- TASKS
------------------------

-- TASK 1 -- How many customers belong to each store? 

SELECT 
	COUNT(store_id) AS num_of_customers
	FROM main.customer
	GROUP BY store_id;
  
-- TASK 2 -- Inventory is a table that contains a record of physical DVDs. We have many copies of each DVD. Each individual physical DVD has a unique inventory_id
		  --For each FILM_ID in the inventory table, which films have more than 5 inventory items? Order by the largest count first. 
  
  SELECT 
	COUNT(film_id) AS num_of_copies
	, film_id
  	FROM main.inventory
  	GROUP BY (film_id)
  	HAVING COUNT(film_id) > 5
  	ORDER BY num_of_copies DESC;


-- TASK 3 -- The web team are creating a web page that lets people explore the Titles of films. They have a question.
		  -- How many films start with each letter of the alphabet? (How many films start with A, how many start with B etc)?
		  -- order by the alphabet
		  -- You'll need to use one of the functions we looked at previously! 
  
SELECT 
	LEFT(title, 1) AS first_letter
	, COUNT(title)
	FROM main.film
	GROUP BY LEFT(title, 1)
	ORDER BY first_letter;
  
  
-----------------------------------------------------------------------------------------------------------
-------- DF9 -- NULLS
-----------------------------------------------------------------------------------------------------------

-- EX -- A null is not a value - it's the complete absence of a value.
-- Working with Nulls changes the key words slightly. 

-- EX --  Let's Explore the App_id table

SELECT 
	*
	FROM main.app_id;

-- EX --  What if we want to find the lines where apple_id is null? 
		-- The way we've done it before won't work! 
		-- We have to use the is keyword because null is not a string! 

SELECT 
	*
	FROM main.app_id
	WHERE apple_id IS NULL;
  
-- EX -- we can also use not

SELECT 
	*
	FROM main.app_id
	WHERE apple_id IS NOT NULL;

-- We can do some fun things with nulls. 
-- Coalesce (takes any amount of values - returns the first not null value)

-- 

 SELECT coalesce(null, null, null, null, null, 'hello');

-- We could Coalesce to other columns, or strings.

-- Nullif
-- Return first value, unless first value equals the second value, in which case, return null

SELECT 
	NULLIF(1, 2);
 
------------------------
-------- DF9 -- TASKS
------------------------

-- TASK 1 -- Select all of the customers from the app_id table, use coalesce to show a column called "device_id" 
          -- which contain their id regardless of if it's android or apple!

-- TASK 2 -- Some customers don't have an address_id. Find all of the customers who have no address_id 



/*
   _____                            _         _       _   _                 _ _ 
  / ____|                          | |       | |     | | (_)               | | |
 | |     ___  _ __   __ _ _ __ __ _| |_ _   _| | __ _| |_ _  ___  _ __  ___| | |
 | |    / _ \| '_ \ / _` | '__/ _` | __| | | | |/ _` | __| |/ _ \| '_ \/ __| | |
 | |___| (_) | | | | (_| | | | (_| | |_| |_| | | (_| | |_| | (_) | | | \__ \_|_|
  \_____\___/|_| |_|\__, |_|  \__,_|\__|\__,_|_|\__,_|\__|_|\___/|_| |_|___(_|_)
                     __/ |                                                      
                    |___/     
                    
We've made it to the end of Part 1 of SQL!                                               
 */



	