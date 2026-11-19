---------------------------------------------------
--- SQL: CREATING AND UPDATING TABLES
---------------------------------------------------

-- P1: CREATE
-- P2: INSERT
-- P3: UPDATE & SET
-- P4: ALTER
-- P5: DROP

---------------------------------------------------
--- P1: Creating tables >> CREATE
--- Documentation: https://www.postgresql.org/docs/current/sql-createtable.html
---------------------------------------------------

/* Syntax:
CREATE TABLE table_name (
	column1_name column1_type ,
	column2_name column2_type ,
	column3_name column3_type 
		);
*/

CREATE TABLE ade_1.stan_data_game(
	ids INT 
	, first_name VARCHAR(16)
	, ice_cream VARCHAR(16)
	, month VARCHAR(16)
	, transport VARCHAR(16)
	, olypmic_sport VARCHAR(16)
	, colour VARCHAR(16)
	, game VARCHAR(16)
	, movie VARCHAR(16)
	);

-- There are many data types to choose from:
-- INT, BIGINT, FLOAT, NUMERIC
-- VARCHAR, TEXT, CHAR
-- DATE, BOOL, ARRAY

---------------------------------------------------
--- P2: Inserting new data >> INSERT
--- Documentation: https://www.postgresql.org/docs/current/sql-insert.html
---------------------------------------------------

--right click table -> insert data

/* Syntax:
INSERT INTO table_name VALUES 
	( value1_1, value1_2, value1_3 ),
	( value2_1, value2_2, value2_3 );
*/

INSERT INTO ade_1.stan_data_game VALUES
	(21, 'bob', 'stawberry', 'april', 'bus', 'sprinting', 'blue', 'league', 'obsession');



-- We can also specify the names of the columns


/* Syntax:
INSERT INTO table_name (column_1, column_2, column_3)
	VALUES (value_1, value_2, value_3);
*/

INSERT INTO ade_1.stan_data_game (ids, first_name, colour) VALUES
	(22, 'jane', 'purple')

SELECT *
FROM ade_1.stan_data_game;
---------------------------------------------------
--- P3: Updating existing data >> UPDATE & SET
--- Documentation: https://www.postgresql.org/docs/current/sql-update.html
---------------------------------------------------

-- We can update the existing data in our table on a specific record
-- We typically designate the record we want using the table's PRIMARY KEY

/* Syntax:
UPDATE table_name
SET column = new_value
WHERE ID = record_value;
*/

UPDATE ade_1.stan_data_game
SET ids = 11
WHERE ids = 22;

SELECT *
FROM ade_1.stan_data_game;

---------------------- Here's a typical example
-- UPDATE my_table
-- SET flag = 1
-- WHERE ID = 2337;

---------------------------------------------------
--- P4: Modifying the table >> ALTER
--- Documentation: https://www.postgresql.org/docs/current/sql-altertable.html
---------------------------------------------------

-- The ALTER TABLE flag can interact with your table in many ways, such as
-- 1. Adding a new column

/* Syntax:
ALTER TABLE table_name
	ADD COLUMN column_name column_type;
*/

ALTER TABLE ade_1.stan_data_game
	ADD COLUMN like_sql BOOL;

UPDATE ade_1.stan_data_game
SET like_sql = TRUE;

SELECT *
FROM ade_1.stan_data_game;


-- 2. Dropping an existing column

/* Syntax:
ALTER TABLE table_name
	DROP COLUMN column_name;
*/

ALTER TABLE ade_1.stan_data_game 
	DROP COLUMN like_sql;

SELECT *
FROM ade_1.stan_data_game;

-- remove row

DELETE 
FROM ade_1.stan_data_game
WHERE ids = 20;

-- 3. Changing the data type of an existing column

/* Syntax:
ALTER TABLE table_name
	ALTER COLUMN column_name TYPE new_column_type;
*/

ALTER TABLE ade_1.stan_data_game 
	ALTER COLUMN first_name TYPE VARCHAR(18);

SELECT *
FROM ade_1.stan_data_game
ORDER BY ids;


-- example where you have a column that is yes/no in a var char and want to convert column data type into bool
ALTER TABLE ade_1.stan_data_game 
ALTER COLUMN like_pasta TYPE BOOL
USING CASE
	WHEN like_pasta = 'yes' THEN TRUE
	WHEN like_pasta = 'no' THEN FALSE
END;


-- 4. BONUS: Adding constraints

/* Syntax:
ALTER TABLE table_name
	ADD CONSTRAINT your_table_pkey PRIMARY KEY (column1, column2, ...);
*/

ALTER TABLE ade_1.stan_data_game 
	ADD CONSTRAINT stan_dg_Pkey PRIMARY KEY (ids);


-- Overall: There are many, many possible use cases for ALTER TABLE

---------------------------------------------------
--- P5: Deleting your table >> DROP
--- Documentation: https://www.postgresql.org/docs/current/sql-droptable.html
---------------------------------------------------

-- This action is irreversible!
-- DROP will completely delete your table from the database. To remove its contents rather than deleting it, use DELETE

-- Syntax:
-- DROP TABLE IF EXISTS table_name;

DROP TABLE IF EXISTS ade_1.stan_data_game; --this will completely remove table, so dont run it lol

--add new datatype, ig an enum so can have a ranking of strings for order by - eg: movie ratings

CREATE TYPE ade_1.stan_data_game rating AS ENUM('G', 'PG', 'PG-13', 'T', 'R');
 --can now use rating as a data type
