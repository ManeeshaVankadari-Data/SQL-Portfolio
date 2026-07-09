-- ==========================================
-- Parks and Recreation Relational Database
-- Portfolio Script: Core to Advanced SQL
-- ==========================================

DROP DATABASE IF EXISTS `Parks_and_Recreation`;
CREATE DATABASE `Parks_and_Recreation`;
USE `Parks_and_Recreation`;

-- ------------------------------------------
-- Table Structures & Data Seeding
-- ------------------------------------------

CREATE TABLE employee_demographics (
  employee_id INT NOT NULL,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  age INT,
  gender VARCHAR(10),
  birth_date DATE,
  PRIMARY KEY (employee_id)
);

CREATE TABLE employee_salary (
  employee_id INT NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  occupation VARCHAR(50),
  salary INT,
  dept_id INT
);

INSERT INTO employee_demographics (employee_id, first_name, last_name, age, gender, birth_date)
VALUES
(1,'Leslie', 'Knope', 44, 'Female','1979-09-25'),
(3,'Tom', 'Haverford', 36, 'Male', '1987-03-04'),
(4, 'April', 'Ludgate', 29, 'Female', '1994-03-27'),
(5, 'Jerry', 'Gergich', 61, 'Male', '1962-08-28'),
(6, 'Donna', 'Meagle', 46, 'Female', '1977-07-30'),
(7, 'Ann', 'Perkins', 35, 'Female', '1988-12-01'),
(8, 'Chris', 'Traeger', 43, 'Male', '1980-11-11'),
(9, 'Ben', 'Wyatt', 38, 'Male', '1985-07-26'),
(10, 'Andy', 'Dwyer', 34, 'Male', '1989-03-25'),
(11, 'Mark', 'Brendanawicz', 40, 'Male', '1983-06-14'),
(12, 'Craig', 'Middlebrooks', 37, 'Male', '1986-07-27');

INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES
(1, 'Leslie', 'Knope', 'Deputy Director of Parks and Recreation', 75000, 1),
(2, 'Ron', 'Swanson', 'Director of Parks and Recreation', 70000, 1),
(3, 'Tom', 'Haverford', 'Entrepreneur', 50000, 1),
(4, 'April', 'Ludgate', 'Assistant to the Director of Parks and Recreation', 25000, 1),
(5, 'Jerry', 'Gergich', 'Office Manager', 50000, 1),
(6, 'Donna', 'Meagle', 'Office Manager', 60000, 1),
(7, 'Ann', 'Perkins', 'Nurse', 55000, 4),
(8, 'Chris', 'Traeger', 'City Manager', 90000, 3),
(9, 'Ben', 'Wyatt', 'State Auditor', 70000, 6),
(10, 'Andy', 'Dwyer', 'Shoe Shiner and Musician', 20000, NULL),
(11, 'Mark', 'Brendanawicz', 'City Planner', 57000, 3),
(12, 'Craig', 'Middlebrooks', 'Parks Director', 65000, 1);

CREATE TABLE parks_departments (
  department_id INT NOT NULL AUTO_INCREMENT,
  department_name VARCHAR(50) NOT NULL,
  PRIMARY KEY (department_id)
);

INSERT INTO parks_departments (department_name)
VALUES
('Parks and Recreation'),
('Animal Control'),
('Public Works'),
('Healthcare'),
('Library'),
('Finance');

-- ------------------------------------------
-- Basic Queries & Math Operators
-- ------------------------------------------

SELECT * FROM employee_demographics;
SELECT * FROM employee_salary;
SELECT first_name FROM employee_demographics;

SELECT first_name, last_name, birth_date, age, age + 10 AS Age_increased
FROM employee_demographics;

SELECT DISTINCT gender FROM employee_demographics;

-- ------------------------------------------
-- WHERE Clause & Logical Operators
-- ------------------------------------------

SELECT * FROM employee_salary WHERE first_name = 'Leslie';
SELECT * FROM employee_salary WHERE salary >= 50000;
SELECT * FROM employee_demographics WHERE gender != 'Female';
SELECT * FROM employee_demographics WHERE birth_date > '1985-01-01' AND gender = 'Male';

SELECT * FROM employee_demographics
WHERE (first_name = 'Leslie' AND age = 44) OR age > 55;

SELECT * FROM employee_demographics WHERE first_name LIKE 'jer%';
SELECT * FROM employee_demographics WHERE first_name LIKE 'a__';

-- ------------------------------------------
-- GROUP BY, ORDER BY, & HAVING Clauses
-- ------------------------------------------

SELECT gender, COUNT(first_name) AS count_of_employee, AVG(age) AS Average_age, MAX(age), MIN(age)
FROM employee_demographics
GROUP BY gender;

SELECT * FROM employee_demographics ORDER BY gender, age DESC;

SELECT occupation, MAX(salary)
FROM employee_salary
GROUP BY occupation
ORDER BY MAX(salary) DESC;

SELECT gender, AVG(age) AS avg_age
FROM employee_demographics
GROUP BY gender
HAVING avg_age > 40;

-- ------------------------------------------
-- Advanced Joins (Inner, Left, Right, Cross, Full Outer)
-- ------------------------------------------

SELECT * FROM employee_demographics ORDER BY age DESC LIMIT 3;

-- 1. INNER JOIN (Matches in both tables)
SELECT emp_dem.employee_id, age, occupation
FROM employee_demographics emp_dem
INNER JOIN employee_salary emp_sal
  ON emp_dem.employee_id = emp_sal.employee_id;

-- 2. LEFT JOIN (All records from left table, matching from right)
SELECT *
FROM employee_demographics emp_dem
LEFT JOIN employee_salary emp_sal
  ON emp_dem.employee_id = emp_sal.employee_id;

-- 3. RIGHT JOIN (All records from right table, matching from left)
-- Useful here because Ron Swanson (ID 2) exists in salary but not demographics
SELECT *
FROM employee_demographics emp_dem
RIGHT JOIN employee_salary emp_sal
  ON emp_dem.employee_id = emp_sal.employee_id;

-- 4. CROSS JOIN (Cartesian product - combinations of all rows)
SELECT emp_dem.first_name, pd.department_name
FROM employee_demographics emp_dem
CROSS JOIN parks_departments pd;

-- 5. FULL OUTER JOIN Emulation (MySQL workaround using LEFT + RIGHT JOIN combined with UNION)
SELECT * FROM employee_demographics emp_dem
LEFT JOIN employee_salary emp_sal ON emp_dem.employee_id = emp_sal.employee_id
UNION
SELECT * FROM employee_demographics emp_dem
RIGHT JOIN employee_salary emp_sal ON emp_dem.employee_id = emp_sal.employee_id;

-- 6. Self Join (Conceptual Offset Example)
SELECT e1.employee_id, e1.first_name AS employee_first_name, 
       e2.employee_id AS Next_id, e2.first_name AS Next_first_name
FROM employee_salary e1
JOIN employee_salary e2
  ON e1.employee_id + 1 = e2.employee_id;

-- 7. Multiple Table Joins
SELECT *
FROM employee_demographics emp_dem
INNER JOIN employee_salary emp_sal ON emp_dem.employee_id = emp_sal.employee_id
INNER JOIN parks_departments pd ON emp_sal.dept_id = pd.department_id;

-- ------------------------------------------
-- UNIONS & UNION ALL
-- ------------------------------------------

-- UNION (Removes duplicates)
SELECT first_name, last_name FROM employee_demographics
UNION
SELECT first_name, last_name FROM employee_salary;

-- UNION ALL (Retains all duplicate entries)
SELECT first_name, last_name FROM employee_demographics
UNION ALL
SELECT first_name, last_name FROM employee_salary;

SELECT first_name, last_name, 'Old Man/Lady' AS Label FROM employee_demographics WHERE age > 40
UNION
SELECT first_name, last_name, 'Highly Paid Employee' AS Label FROM employee_salary WHERE salary > 70000;

-- ------------------------------------------
-- String Functions & Null Handling
-- ------------------------------------------

SELECT first_name, LENGTH(first_name) AS Length_of_Names FROM employee_demographics;
SELECT UPPER(first_name), LOWER(last_name) FROM employee_demographics;
SELECT SUBSTRING(birth_date, 6, 2) AS Birth_month FROM employee_demographics;
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM employee_demographics;

-- Handling NULL Values (Using COALESCE to fallback when dept_id is missing, like Andy Dwyer's)
SELECT first_name, last_name, COALESCE(dept_id, 0) AS safe_dept_id 
FROM employee_salary;

-- Conditional Logic via CASE
SELECT first_name, last_name, salary,
       CASE
         WHEN salary <= 50000 THEN salary * 1.05
         WHEN salary > 50000 THEN salary * 1.07
       END AS Increment_salary,
       CASE
         WHEN dept_id = 6 THEN salary * 0.1
       END AS Bonus
FROM employee_salary;

-- ------------------------------------------
-- Subqueries & Window Functions
-- ------------------------------------------

SELECT * FROM employee_demographics
WHERE employee_id IN (SELECT employee_id FROM employee_salary WHERE dept_id = 1);

-- Window Functions: Partitioning and Ranking
SELECT emp_dem.first_name, emp_dem.last_name, emp_dem.gender, salary,
       SUM(salary) OVER(PARTITION BY gender ORDER BY emp_dem.employee_id) AS Rolling_Total,
       ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary DESC) AS Row_Num,
       RANK() OVER(PARTITION BY gender ORDER BY salary DESC) AS Rank_Values,
       DENSE_RANK() OVER(PARTITION BY gender ORDER BY salary DESC) AS Dense_Rank_Values
FROM employee_demographics emp_dem
JOIN employee_salary emp_salary ON emp_dem.employee_id = emp_salary.employee_id;

-- ------------------------------------------
-- Common Table Expressions (CTEs) & Temp Tables
-- ------------------------------------------

WITH CTE_EX1 AS (
  SELECT employee_id, gender, birth_date FROM employee_demographics WHERE birth_date > '1985-01-01'
),
CTE_EX2 AS (
  SELECT employee_id, salary FROM employee_salary WHERE salary > 50000
)
SELECT * FROM CTE_EX1
JOIN CTE_EX2 ON CTE_EX1.employee_id = CTE_EX2.employee_id;

CREATE TEMPORARY TABLE Salary_Over_than_50k
SELECT * FROM employee_salary WHERE salary >= 50000;

-- ------------------------------------------
-- Database Views
-- ------------------------------------------

CREATE OR REPLACE VIEW v_employee_summary AS
SELECT emp_dem.employee_id, emp_dem.first_name, emp_dem.last_name, emp_sal.occupation, emp_sal.salary
FROM employee_demographics emp_dem
JOIN employee_salary emp_sal ON emp_dem.employee_id = emp_sal.employee_id;

SELECT * FROM v_employee_summary;

-- ------------------------------------------
-- Advanced Control Flow: Stored Procedures & Triggers
-- ------------------------------------------

-- Stored Procedures
DELIMITER &&
CREATE PROCEDURE GetHighSalaries()
BEGIN
  SELECT * FROM employee_salary WHERE salary >= 50000;
END &&
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetSalaryByDetails(p_emp_id INT, p_dept_id INT)
BEGIN
  SELECT salary 
  FROM employee_salary
  WHERE employee_id = p_emp_id AND dept_id = p_dept_id;
END $$
DELIMITER ;

-- Triggers
DELIMITER $$
CREATE TRIGGER Trigger_After_Salary_Insert
AFTER INSERT ON employee_salary
FOR EACH ROW
BEGIN
  INSERT INTO employee_demographics (employee_id, first_name, last_name)
  VALUES (NEW.employee_id, NEW.first_name, NEW.last_name);
END $$
DELIMITER ;

-- Scheduled Events
DELIMITER $$
CREATE EVENT Retired_People_Delete
ON SCHEDULE EVERY 30 SECOND
DO
BEGIN
  DELETE FROM employee_demographics WHERE age >= 60;
END $$
DELIMITER ;

-- User Defined Functions (UDF)
DELIMITER $$
CREATE FUNCTION CalculateBonus(salary INT)
RETURNS INT
DETERMINISTIC
BEGIN
  RETURN salary * 0.1;
END $$
DELIMITER ;

-- ------------------------------------------
-- Cursors (Row-by-Row Processing)
-- ------------------------------------------
-- Example: A procedure that uses a cursor to loop through high-earning salaries
-- and count how many rows meet the criteria.

DELIMITER $$
CREATE PROCEDURE ProcessHighSalariesCursor(OUT total_high_earners INT)
BEGIN
  -- Declare variables for cursor values
  DECLARE done INT DEFAULT FALSE;
  DECLARE emp_salary INT;
  
  -- Declare the cursor
  DECLARE salary_cursor CURSOR FOR 
    SELECT salary FROM employee_salary;
    
  -- Declare a NOT FOUND handler to exit the loop
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  
  SET total_high_earners = 0;
  
  OPEN salary_cursor;
  
  read_loop: LOOP
    FETCH salary_cursor INTO emp_salary;
    IF done THEN
      LEAVE read_loop;
    END IF;
    
    -- Business logic condition inside loop
    IF emp_salary >= 60000 THEN
      SET total_high_earners = total_high_earners + 1;
    END IF;
  END LOOP;
  
  CLOSE salary_cursor;
END $$
DELIMITER ;

-- To test the cursor:
-- CALL ProcessHighSalariesCursor(@count);
-- SELECT @count;
