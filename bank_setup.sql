-- Retail bank SQL project
-- File 1: bank_setup.sql
-- Creates the 4 tables and loads the sample data.
-- Run this first. It is safe to run again, it drops the old tables first.
-- Database: PostgreSQL (I used pgAdmin 4)
-- All dates are fixed. The analysis date for the whole project is 30 Sep 2026.

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS customers;


-- ---- tables (DDL) ----

CREATE TABLE customers (
    customer_id  SERIAL PRIMARY KEY,
    full_name    VARCHAR(100) NOT NULL,
    age          INT NOT NULL CHECK (age >= 18),
    city         VARCHAR(50) NOT NULL,
    income       NUMERIC(12,2) NOT NULL CHECK (income >= 0),
    cibil_score  INT NOT NULL CHECK (cibil_score BETWEEN 300 AND 900)
);

CREATE TABLE accounts (
    account_id    SERIAL PRIMARY KEY,
    customer_id   INT NOT NULL REFERENCES customers (customer_id),
    account_type  VARCHAR(10) NOT NULL CHECK (account_type IN ('Savings', 'Current')),
    balance       NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (balance >= 0)
);

CREATE TABLE transactions (
    transaction_id    SERIAL PRIMARY KEY,
    account_id        INT NOT NULL REFERENCES accounts (account_id),
    transaction_date  DATE NOT NULL,
    amount            NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    transaction_type  VARCHAR(12) NOT NULL CHECK (transaction_type IN ('Deposit', 'Withdrawal')),
    category          VARCHAR(30) NOT NULL
);

CREATE TABLE loans (
    loan_id          SERIAL PRIMARY KEY,
    customer_id      INT NOT NULL REFERENCES customers (customer_id),
    loan_amount      NUMERIC(12,2) NOT NULL CHECK (loan_amount > 0),
    missed_payments  INT NOT NULL DEFAULT 0 CHECK (missed_payments >= 0),
    loan_status      VARCHAR(10) NOT NULL CHECK (loan_status IN ('Active', 'Defaulted', 'Closed')),
    start_date       DATE NOT NULL
);

-- index so that looking up the transactions of one account is faster
CREATE INDEX idx_txn_account_date ON transactions (account_id, transaction_date);


-- ---- data (DML: INSERT) ----

-- 12 customers from 6 cities, good and bad credit scores
INSERT INTO customers (full_name, age, city, income, cibil_score) VALUES
('Aarav Sharma', 34, 'Mumbai', 1200000.00, 785),
('Priya Nair', 29, 'Pune', 950000.00, 742),
('Rohan Mehta', 45, 'Mumbai', 2400000.00, 801),
('Sneha Kulkarni', 38, 'Pune', 700000.00, 668),
('Vikram Singh', 52, 'Nagpur', 450000.00, 540),
('Anjali Desai', 27, 'Nagpur', 380000.00, 612),
('Karan Malhotra', 41, 'Delhi', 1800000.00, 720),
('Meera Iyer', 33, 'Delhi', 600000.00, 590),
('Suresh Patil', 58, 'Nashik', 300000.00, 505),
('Divya Reddy', 31, 'Hyderabad', 1500000.00, 760),
('Neha Gupta', 36, 'Hyderabad', 1100000.00, 710),
('Rahul Joshi', 47, 'Nashik', 520000.00, 560);

-- 15 accounts. Account 4, 10 and 14 have a big balance but nobody uses them
-- (14 has never had a single transaction)
INSERT INTO accounts (customer_id, account_type, balance) VALUES
(1, 'Savings', 452300.00),
(2, 'Savings', 281450.00),
(3, 'Current', 1252000.00),
(3, 'Savings', 641500.00),
(4, 'Savings', 85600.00),
(5, 'Savings', 4250.00),
(6, 'Savings', 15400.00),
(7, 'Current', 983000.00),
(8, 'Savings', 2350.00),
(9, 'Savings', 76200.00),
(10, 'Savings', 521700.00),
(11, 'Savings', 191800.00),
(12, 'Current', 31500.00),
(7, 'Savings', 212000.00),
(10, 'Current', 342000.00);

-- 38 transactions, listed account by account
INSERT INTO transactions (account_id, transaction_date, amount, transaction_type, category) VALUES
(1, '2026-09-25', 4620.00, 'Withdrawal', 'Groceries'),
(1, '2026-09-10', 98500.00, 'Deposit', 'Salary'),
(1, '2026-08-26', 8350.00, 'Withdrawal', 'Dining'),
(1, '2026-08-11', 98500.00, 'Deposit', 'Salary'),
(1, '2026-07-22', 15900.00, 'Withdrawal', 'Electronics'),
(1, '2026-06-27', 98500.00, 'Deposit', 'Salary'),
(1, '2026-04-23', 98500.00, 'Deposit', 'Salary'),
(2, '2026-09-18', 3180.00, 'Withdrawal', 'Dining'),
(2, '2026-08-19', 79200.00, 'Deposit', 'Salary'),
(2, '2026-07-20', 21750.00, 'Withdrawal', 'Travel'),
(2, '2026-06-17', 79200.00, 'Deposit', 'Salary'),
(3, '2026-09-22', 412000.00, 'Deposit', 'Business'),
(3, '2026-09-02', 148500.00, 'Withdrawal', 'Investment'),
(3, '2026-07-27', 355000.00, 'Deposit', 'Business'),
(3, '2026-07-04', 79800.00, 'Withdrawal', 'Travel'),
(3, '2026-06-07', 298000.00, 'Deposit', 'Business'),
(4, '2026-03-14', 340000.00, 'Deposit', 'Investment'),
(5, '2026-08-03', 5100.00, 'Withdrawal', 'Groceries'),
(5, '2026-06-02', 58400.00, 'Deposit', 'Salary'),
(5, '2026-05-13', 7250.00, 'Withdrawal', 'Utilities'),
(6, '2026-09-15', 2150.00, 'Withdrawal', 'Groceries'),
(7, '2026-09-05', 27800.00, 'Deposit', 'Salary'),
(7, '2026-07-12', 940.00, 'Withdrawal', 'Entertainment'),
(8, '2026-09-27', 252000.00, 'Deposit', 'Business'),
(8, '2026-08-16', 304500.00, 'Deposit', 'Business'),
(8, '2026-06-22', 44600.00, 'Withdrawal', 'Travel'),
(9, '2026-09-24', 1240.00, 'Withdrawal', 'Dining'),
(10, '2026-02-22', 24800.00, 'Deposit', 'Pension'),
(11, '2026-09-20', 124500.00, 'Deposit', 'Salary'),
(11, '2026-08-21', 17650.00, 'Withdrawal', 'Travel'),
(11, '2026-07-17', 124500.00, 'Deposit', 'Salary'),
(11, '2026-06-12', 31800.00, 'Withdrawal', 'Electronics'),
(12, '2026-09-23', 91800.00, 'Deposit', 'Salary'),
(12, '2026-08-24', 10900.00, 'Withdrawal', 'Healthcare'),
(12, '2026-07-25', 91800.00, 'Deposit', 'Salary'),
(13, '2026-08-01', 1480.00, 'Withdrawal', 'Fuel'),
(15, '2026-09-12', 61500.00, 'Deposit', 'Business'),
(15, '2026-08-06', 24500.00, 'Withdrawal', 'Investment');

-- 11 loans. Customer 11 (Neha Gupta) has no loan on purpose, it is used in the join queries
INSERT INTO loans (customer_id, loan_amount, missed_payments, loan_status, start_date) VALUES
(1, 3000000.00, 0, 'Active', '2021-03-15'),
(2, 600000.00, 0, 'Active', '2024-08-10'),
(3, 5000000.00, 0, 'Active', '2020-11-02'),
(4, 1200000.00, 2, 'Active', '2023-05-20'),
(5, 800000.00, 6, 'Defaulted', '2024-01-12'),
(6, 400000.00, 3, 'Active', '2025-04-08'),
(7, 2500000.00, 1, 'Active', '2022-09-25'),
(8, 300000.00, 7, 'Defaulted', '2025-02-14'),
(9, 250000.00, 5, 'Defaulted', '2024-06-30'),
(10, 1000000.00, 0, 'Closed', '2019-07-01'),
(12, 700000.00, 4, 'Defaulted', '2024-10-18');

-- ---- quick check, should show 12, 15, 38, 11 ----
SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'accounts', COUNT(*) FROM accounts
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL
SELECT 'loans', COUNT(*) FROM loans;
