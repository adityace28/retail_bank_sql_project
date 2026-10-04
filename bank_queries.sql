-- Retail bank SQL project
-- File 2: bank_queries.sql
-- 8 queries, grouped by topic. Run bank_setup.sql first.
-- In pgAdmin: select ONE query with the mouse and press F5.
-- (if you run the whole file, pgAdmin only shows the last result)
-- Analysis date used in this project = 30 Sep 2026 (the data is fixed, not live)


-- =====================================================
-- PART 1: FILTERING (WHERE, AND, OR)
-- =====================================================

-- Q1. customers from Mumbai or Pune with a CIBIL score of 700 or more
-- the brackets matter: without them AND is checked before OR
SELECT full_name, city, cibil_score
FROM customers
WHERE (city = 'Mumbai' OR city = 'Pune')
  AND cibil_score >= 700
ORDER BY cibil_score DESC;


-- =====================================================
-- PART 2: GROUP BY and HAVING
-- =====================================================

-- Q2. spending categories where total withdrawals are more than 40,000
-- WHERE filters the rows first, HAVING filters the groups after SUM is done
SELECT category,
       COUNT(*) AS no_of_withdrawals,
       SUM(amount) AS total_withdrawn
FROM transactions
WHERE transaction_type = 'Withdrawal'
GROUP BY category
HAVING SUM(amount) > 40000
ORDER BY total_withdrawn DESC;


-- =====================================================
-- PART 3: SET OPERATOR (EXCEPT)
-- =====================================================

-- Q3. customers who have NO loan
-- EXCEPT = first result minus the second result
SELECT customer_id, full_name
FROM customers
EXCEPT
SELECT c.customer_id, c.full_name
FROM customers c
JOIN loans l ON l.customer_id = c.customer_id;


-- =====================================================
-- PART 4: CASE, COALESCE, VIEW and CTE
-- =====================================================

-- Q4. risk label for every customer, saved as a VIEW
-- a view is just a saved query, so the rules are written only once
-- High   : CIBIL below 600 or 3 or more missed payments
-- Low    : CIBIL 740 or more and no missed payments
-- Medium : everyone else
-- COALESCE turns NULL into 0 for customers who have no loan

-- Part A: create the view (run this first)
CREATE OR REPLACE VIEW view_customer_risk AS
SELECT c.customer_id,
       c.full_name,
       c.city,
       c.cibil_score,
       COALESCE(SUM(l.missed_payments), 0) AS total_missed_payments,
       CASE
           WHEN c.cibil_score < 600 OR COALESCE(SUM(l.missed_payments), 0) >= 3 THEN 'High Risk'
           WHEN c.cibil_score >= 740 AND COALESCE(SUM(l.missed_payments), 0) = 0 THEN 'Low Risk'
           ELSE 'Medium Risk'
       END AS risk_category
FROM customers c
LEFT JOIN loans l ON l.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name, c.city, c.cibil_score;

-- Part B: look at the view
SELECT * FROM view_customer_risk ORDER BY cibil_score;

-- Part C: how many customers in each group
SELECT risk_category, COUNT(*) AS no_of_customers
FROM view_customer_risk
GROUP BY risk_category
ORDER BY no_of_customers DESC;


-- Q5. default rate by income band (NPA = loans that are not being repaid)
-- step 1 (the WITH part): put every open loan in an income band
-- step 2 (the SELECT below it): add up the lent amount and the defaulted amount per band
-- closed loans are left out because the bank has no money at risk there
WITH loans_with_band AS (
    SELECT l.loan_amount,
           l.loan_status,
           CASE
               WHEN c.income < 500000 THEN '1. Below 5 lakh'
               WHEN c.income < 1000000 THEN '2. 5 to 10 lakh'
               ELSE '3. Above 10 lakh'
           END AS income_band
    FROM loans l
    JOIN customers c ON c.customer_id = l.customer_id
    WHERE l.loan_status IN ('Active', 'Defaulted')
)
SELECT income_band,
       COUNT(*) AS total_loans,
       SUM(CASE WHEN loan_status = 'Defaulted' THEN 1 ELSE 0 END) AS defaulted_loans,
       SUM(loan_amount) AS total_lent,
       SUM(CASE WHEN loan_status = 'Defaulted' THEN loan_amount ELSE 0 END) AS defaulted_amount,
       ROUND(100.0 * SUM(CASE WHEN loan_status = 'Defaulted' THEN loan_amount ELSE 0 END)
             / SUM(loan_amount), 2) AS default_percent
FROM loans_with_band
GROUP BY income_band
ORDER BY income_band;


-- =====================================================
-- PART 5: JOINS
-- =====================================================

-- Q6. INNER JOIN: total balance of each customer across all accounts
SELECT c.full_name,
       c.city,
       COUNT(a.account_id) AS no_of_accounts,
       SUM(a.balance) AS total_balance
FROM customers c
INNER JOIN accounts a ON a.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name, c.city
ORDER BY total_balance DESC;


-- Q7. LEFT JOIN: customers with no loan (same answer as Q3, different method)
-- LEFT JOIN keeps all customers, and the loan columns are NULL when there is no match
SELECT c.full_name, c.city, c.income, c.cibil_score
FROM customers c
LEFT JOIN loans l ON l.customer_id = c.customer_id
WHERE l.loan_id IS NULL;


-- =====================================================
-- PART 6: SUBQUERY
-- =====================================================

-- Q8. dormant accounts: balance above 50,000 and no transaction in the last 90 days
-- 90 days before 30 Sep 2026 is 2 Jul 2026
-- NOT EXISTS is true when the small query inside finds nothing, so an account
-- that never had any transaction is also caught
SELECT a.account_id,
       c.full_name,
       a.account_type,
       a.balance,
       (SELECT MAX(t.transaction_date)
        FROM transactions t
        WHERE t.account_id = a.account_id) AS last_transaction
FROM accounts a
JOIN customers c ON c.customer_id = a.customer_id
WHERE a.balance > 50000
  AND NOT EXISTS (SELECT 1
                  FROM transactions t
                  WHERE t.account_id = a.account_id
                    AND t.transaction_date >= DATE '2026-09-30' - 90)
ORDER BY a.balance DESC;
