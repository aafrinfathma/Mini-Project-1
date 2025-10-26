-- Employee Attendance Management Database Project
-- Tool: PostgreSQL, pgAdmin
-- Author: ChatGPT (GPT-5)
-- -----------------------------------------

-- STEP 1: Create Database
DROP DATABASE IF EXISTS employee_attendance_db;
CREATE DATABASE employee_attendance_db;

-- c employee_attendance_db;

DROP TABLE IF EXISTS Attendance CASCADE;
DROP TABLE IF EXISTS Employees CASCADE;
DROP TABLE IF EXISTS Roles CASCADE;
DROP TABLE IF EXISTS Departments CASCADE;

-- STEP 2: Create Tables
CREATE TABLE Departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL
);

CREATE TABLE Roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL,
    salary NUMERIC(10,2)
);

CREATE TABLE Employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender CHAR(1),
    hire_date DATE DEFAULT CURRENT_DATE,
    dept_id INT REFERENCES Departments(dept_id),
    role_id INT REFERENCES Roles(role_id)
);

CREATE TABLE Attendance (
    attendance_id SERIAL PRIMARY KEY,
    emp_id INT REFERENCES Employees(emp_id),
    attendance_date DATE DEFAULT CURRENT_DATE,
    check_in TIME,
    check_out TIME,
    status VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- STEP 3: Insert Dummy Data
INSERT INTO Departments (dept_name) VALUES
('HR'), ('Finance'), ('Engineering'), ('Sales'), ('IT Support');

INSERT INTO Roles (role_name, salary) VALUES
('Manager', 75000),
('Engineer', 50000),
('Technician', 35000),
('Sales Rep', 40000),
('HR Executive', 45000);

INSERT INTO Employees (first_name, last_name, gender, dept_id, role_id)
SELECT
    'Emp' || generate_series(1,200),
    'User',
    CASE WHEN random() > 0.5 THEN 'M' ELSE 'F' END,
    (1 + floor(random() * 5))::INT,
    (1 + floor(random() * 5))::INT;

-- STEP 4: Insert Dummy Attendance Records
INSERT INTO Attendance (emp_id, attendance_date, check_in, check_out, status)
SELECT
    emp_id,
    current_date - (random() * 30)::INT,
    TIME '09:00:00' + (random() * interval '30 minutes'),
    TIME '17:00:00' + (random() * interval '30 minutes'),
    CASE WHEN random() > 0.9 THEN 'Absent'
         WHEN random() > 0.7 THEN 'Late'
         ELSE 'Present' END
FROM Employees
CROSS JOIN generate_series(1,20);

-- STEP 5: Trigger for Auto Status Update
CREATE OR REPLACE FUNCTION set_attendance_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.check_in > TIME '09:15:00' THEN
        NEW.status := 'Late';
    ELSE
        NEW.status := 'Present';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_status
BEFORE INSERT ON Attendance
FOR EACH ROW
EXECUTE FUNCTION set_attendance_status();

-- STEP 6: Function to Calculate Total Work Hours
CREATE OR REPLACE FUNCTION calc_work_hours(p_emp INT, p_date DATE)
RETURNS INTERVAL AS $$
DECLARE
    work_hours INTERVAL;
BEGIN
    SELECT (check_out - check_in)
    INTO work_hours
    FROM Attendance
    WHERE emp_id = p_emp AND attendance_date = p_date;

    RETURN work_hours;
END;
$$ LANGUAGE plpgsql;

-- STEP 7: Reports and Queries

-- Monthly Attendance Summary
SELECT
    e.emp_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    COUNT(a.attendance_id) AS total_days,
    SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END) AS late_days,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absents
FROM Employees e
JOIN Attendance a ON e.emp_id = a.emp_id
WHERE date_part('month', a.attendance_date) = 10
GROUP BY e.emp_id, employee_name
ORDER BY late_days DESC;

-- Late Arrival Report
SELECT
    e.emp_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    a.attendance_date,
    a.check_in,
    a.status
FROM Employees e
JOIN Attendance a ON e.emp_id = a.emp_id
WHERE a.status = 'Late'
ORDER BY a.attendance_date DESC;

-- Department-wise Late Rate Report
SELECT
    d.dept_name,
    COUNT(a.attendance_id) AS total_records,
    SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END) AS late_count,
    ROUND(SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END)::NUMERIC / COUNT(a.attendance_id) * 100, 2) AS late_percent
FROM Attendance a
JOIN Employees e ON a.emp_id = e.emp_id
JOIN Departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name
HAVING ROUND(SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END)::NUMERIC / COUNT(a.attendance_id) * 100, 2) > 10;
