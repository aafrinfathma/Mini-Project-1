# Employee Attendance Database (PostgreSQL Project)

## 🎯 Objective
This project manages **employee and attendance data** in PostgreSQL. It includes schema creation, dummy data generation, triggers, functions, and reports for performance analysis.

---

## 🧰 Tools Used
- **PostgreSQL**
- **pgAdmin 4** (GUI for database management)

---

## ⚙️ Setup Instructions

### Step 1: Create the Database
Open pgAdmin and run:
```sql
CREATE DATABASE employee_attendance;
```
Then connect to it:
```sql
\c employee_attendance
```

### Step 2: Run SQL Scripts (in order)
1. **schema.sql** → Creates all tables  
2. **data.sql** → Inserts 200+ employees and 30 days of attendance  
3. **triggers.sql** → Adds logic to auto-calculate work hours and mark lateness  
4. **functions.sql** → Creates a function to calculate monthly total work hours  
5. **reports.sql** → Provides queries for attendance and departmental summaries  

---

## 🧩 Database Schema

**Tables**
- `departments(dept_id, dept_name)`  
- `roles(role_id, role_name)`  
- `employees(emp_id, first_name, last_name, email, phone, dept_id, role_id, hire_date)`  
- `attendance(attendance_id, emp_id, check_in, check_out, status, work_hours)`  

---

## 🧠 Features

✅ Auto-calculated work hours via trigger  
✅ Late detection if check-in > 9:00 AM  
✅ Monthly total hours per employee function  
✅ Reports grouped by employee and department  
✅ 200+ dummy employee records for realistic data  

---

## 📊 Reports

### 1. Monthly Attendance Count
```sql
SELECT emp_id, COUNT(*) AS days_present
FROM attendance
WHERE status = 'Present'
GROUP BY emp_id
ORDER BY days_present DESC;
```

### 2. Late Arrivals Report
```sql
SELECT emp_id, COUNT(*) AS late_days
FROM attendance
WHERE status = 'Late'
GROUP BY emp_id
HAVING COUNT(*) > 2
ORDER BY late_days DESC;
```

### 3. Department-wise Work Hours
```sql
SELECT d.dept_name, SUM(EXTRACT(EPOCH FROM a.work_hours)/3600) AS total_hours
FROM attendance a
JOIN employees e ON a.emp_id = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name;
```

---

## 🧮 Function Example
```sql
SELECT total_monthly_hours(5, 10, 2025);
```

This returns total working hours for employee ID 5 in October 2025.

---

## 📦 Deliverables
| File | Description |
|------|--------------|
| `schema.sql` | Table structure |
| `data.sql` | Dummy employee + attendance data |
| `triggers.sql` | Trigger for work hours & lateness |
| `functions.sql` | Monthly total work hours function |
| `reports.sql` | Ready-to-run report queries |
| `README.md` | Project setup and guide |
