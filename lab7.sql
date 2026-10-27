-- Lab 7: SQL Views and Roles

-- Part 2: Creating Basic Views
CREATE VIEW employee_details AS 
SELECT e.emp_name, e.salary, d.dept_name, d.location 
FROM employees e INNER JOIN departments d ON e.dept_id = d.dept_id;

CREATE VIEW dept_statistics AS 
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count, AVG(e.salary) AS avg_salary, MAX(e.salary) AS max_salary, MIN(e.salary) AS min_salary 
FROM departments d LEFT JOIN employees e ON d.dept_id = e.dept_id 
GROUP BY d.dept_id, d.dept_name;

CREATE VIEW project_overview AS 
SELECT p.project_name, p.budget, d.dept_name, d.location, (SELECT COUNT(*) FROM employees e WHERE e.dept_id = d.dept_id) AS team_size 
FROM projects p LEFT JOIN departments d ON p.dept_id = d.dept_id;

CREATE VIEW high_earners AS 
SELECT emp_name, salary, department FROM employees e JOIN departments d ON e.dept_id = d.dept_id WHERE salary > 55000;

-- Part 3: Modifying and Managing Views
CREATE OR REPLACE VIEW employee_details AS 
SELECT e.emp_name, e.salary, d.dept_name, d.location,
    CASE 
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
    END AS salary_grade
FROM employees e JOIN departments d ON e.dept_id = d.dept_id;

ALTER VIEW high_earners RENAME TO top_performers;

CREATE TEMP VIEW temp_view AS SELECT * FROM employees WHERE salary < 50000;
DROP VIEW temp_view;

-- Part 4: Updatable Views
CREATE VIEW employee_salaries AS 
SELECT emp_id, emp_name, dept_id, salary FROM employees;

UPDATE employee_salaries SET salary = 52000 WHERE emp_name = 'John Smith';

CREATE VIEW it_employees AS 
SELECT * FROM employees WHERE dept_id = 101 WITH LOCAL CHECK OPTION;

-- Part 5: Materialized Views
CREATE MATERIALIZED VIEW dept_summary_mv AS 
SELECT d.dept_id, d.dept_name, 
    COUNT(e.emp_id) AS total_employees, 
    COALESCE(SUM(e.salary), 0) AS total_salaries,
    (SELECT COUNT(*) FROM projects p WHERE p.dept_id = d.dept_id) AS total_projects,
    (SELECT COALESCE(SUM(budget), 0) FROM projects p WHERE p.dept_id = d.dept_id) AS total_budget
FROM departments d LEFT JOIN employees e ON d.dept_id = e.dept_id 
GROUP BY d.dept_id, d.dept_name
WITH DATA;

CREATE UNIQUE INDEX idx_dept_summary_mv_id ON dept_summary_mv(dept_id);

CREATE MATERIALIZED VIEW project_stats_mv AS 
SELECT p.project_name, p.budget, d.dept_name, COUNT(e.emp_id) AS assigned_employees
FROM projects p LEFT JOIN departments d ON p.dept_id = d.dept_id 
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_id, p.project_name, p.budget, d.dept_name
WITH NO DATA;

-- Part 6: Database Roles
CREATE ROLE analyst NOLOGIN;
CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
CREATE USER report_user WITH PASSWORD 'report456';

CREATE ROLE db_creator CREATEDB LOGIN PASSWORD 'creator789';
CREATE ROLE user_manager CREATEROLE LOGIN PASSWORD 'manager101';
CREATE ROLE admin_user SUPERUSER LOGIN PASSWORD 'admin999';

GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;

CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

CREATE USER hr_user1 WITH PASSWORD 'hr001';
CREATE USER hr_user2 WITH PASSWORD 'hr002';
CREATE USER finance_user1 WITH PASSWORD 'fin001';

GRANT hr_team TO hr_user1, hr_user2;
GRANT finance_team TO finance_user1;
GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;

REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;