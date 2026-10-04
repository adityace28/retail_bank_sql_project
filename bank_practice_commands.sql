-- Retail bank SQL project
-- File 3: bank_practice_commands.sql
-- Practice of the commands that CHANGE data or tables (CREATE, ALTER, UPDATE, DELETE, ROLLBACK).
-- All of this is done on a COPY called customers_copy, so the real
-- customers table and the results of bank_queries.sql are not touched.
-- Run it one step at a time (select the lines, press F5) and look at the output.


-- step 1: make a copy of the customers table (DDL)
CREATE TABLE customers_copy AS
SELECT * FROM customers;

SELECT * FROM customers_copy ORDER BY customer_id;


-- step 2: add a new column (ALTER TABLE ... ADD COLUMN)
ALTER TABLE customers_copy ADD COLUMN email VARCHAR(100);


-- step 3: fill the new column (UPDATE)
-- LOWER makes small letters, REPLACE changes the space in the name to a dot
UPDATE customers_copy
SET email = LOWER(REPLACE(full_name, ' ', '.')) || '@examplebank.in';

SELECT customer_id, full_name, email FROM customers_copy ORDER BY customer_id;


-- step 4: change the datatype of a column (ALTER COLUMN ... TYPE)
ALTER TABLE customers_copy ALTER COLUMN age TYPE SMALLINT;


-- step 5: update only some rows (UPDATE with WHERE)
-- always write the WHERE, without it every row changes
UPDATE customers_copy
SET cibil_score = cibil_score + 25
WHERE customer_id = 5;

SELECT customer_id, full_name, cibil_score FROM customers_copy WHERE customer_id = 5;


-- step 6: delete some rows (DELETE with WHERE)
DELETE FROM customers_copy
WHERE age > 55;

SELECT COUNT(*) AS rows_left FROM customers_copy;


-- step 7: delete a column (ALTER TABLE ... DROP COLUMN)
ALTER TABLE customers_copy DROP COLUMN email;


-- step 8: transaction control (TCL)
-- select ALL the lines from BEGIN to the last SELECT and press F5 once
-- the DELETE is undone by ROLLBACK, so the count comes back to the old number
-- (11 rows before, 9 inside the transaction, 11 again after ROLLBACK)
-- pgAdmin shows only the last result, so you will see 11. To see the 9, run
-- the lines from BEGIN to the first SELECT, look at it, then run ROLLBACK;
BEGIN;
DELETE FROM customers_copy WHERE city = 'Delhi';
SELECT COUNT(*) AS rows_inside_transaction FROM customers_copy;
ROLLBACK;
SELECT COUNT(*) AS rows_after_rollback FROM customers_copy;


-- step 9: remove the copy (DDL)
DROP TABLE customers_copy;
