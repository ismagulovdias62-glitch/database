CREATE DATABASE advanced_Lab;

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL,
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(100),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(50) DEFAULT 'Active'
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER,
    CONSTRAINT fk_department FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (1, 'John', 'Doe', 'HR');

INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date, status)
VALUES (2, 'Alice', 'Smith', 'Finance', DEFAULT, '2022-05-10', DEFAULT);

INSERT INTO departments (dept_name, budget, manager_id) VALUES
('IT', 150000, 101),
('Sales', 120000, 102),
('Marketing', 90000, 103);

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Bob', 'Johnson', 'IT', CAST(50000 * 1.1 AS INTEGER), CURRENT_DATE);

CREATE TEMP TABLE temp_employees AS 
SELECT * FROM employees WHERE department = 'IT';

UPDATE employees
SET salary = salary * 1.10;

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

UPDATE employees
SET department = CASE 
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments d
SET budget = (
    SELECT CAST(AVG(e.salary) * 1.20 AS INTEGER)
    FROM employees e
    WHERE e.department = d.dept_name
);

UPDATE employees
SET salary = CAST(salary * 1.15 AS INTEGER), status = 'Promoted'
WHERE department = 'Sales';

DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;

DELETE FROM departments
WHERE dept_id NOT IN (
    SELECT DISTINCT dept_id FROM projects WHERE dept_id IS NOT NULL
);

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('Null', 'Test', NULL, NULL);

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Michael', 'Scarn', 'Management', 95000, '2021-03-15')
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'Emma', 'Watson', 'Legal', 70000, '2022-01-10'
WHERE NOT EXISTS (
    SELECT 1 FROM employees 
    WHERE first_name = 'Emma' AND last_name = 'Watson'
);

UPDATE employees e
SET salary = CAST(
    CASE 
        WHEN (SELECT budget FROM departments d WHERE d.dept_name = e.department) > 100000 
            THEN e.salary * 1.10
        ELSE e.salary * 1.05
    END AS INTEGER
);

INSERT INTO employees (first_name, last_name, department, salary, hire_date) VALUES
('User1', 'Test', 'IT', 50000, CURRENT_DATE),
('User2', 'Test', 'IT', 52000, CURRENT_DATE),
('User3', 'Test', 'Sales', 48000, CURRENT_DATE),
('User4', 'Test', 'Sales', 53000, CURRENT_DATE),
('User5', 'Test', 'HR', 45000, CURRENT_DATE);

UPDATE employees
SET salary = CAST(salary * 1.10 AS INTEGER)
WHERE first_name LIKE 'User%';

CREATE TABLE employee_archive (
    LIKE employees INCLUDING ALL
);

WITH moved_employees AS (
    DELETE FROM employees
    WHERE status = 'Inactive'
    RETURNING *
)
INSERT INTO employee_archive
SELECT * FROM moved_employees;

UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000 
  AND (
      SELECT COUNT(*) 
      FROM employees e 
      WHERE e.department = (SELECT dept_name FROM departments d WHERE d.dept_id = p.dept_id)
  ) > 3;