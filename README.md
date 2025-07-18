# Lbirary_Management_SQL-Project
# 📚 Library Management System (MySQL Project)

## 📊 Overview

This project is a mini **Library Management System** built using **MySQL**. It includes a complete database schema, sample data operations, complex queries, stored procedures, and triggers to simulate real-world library functionalities like book issuing, returning, and branch management.

---

## 🧱 Database Structure

**Database**: `library`

### 📌 Tables:
- `books` — stores book details
- `branch` — stores branch information
- `employee` — stores employee data, linked to branches
- `members` — stores member registrations
- `issued_status` — tracks book issues
- `return_status` — tracks book returns

---

## 🔧 Functionalities Implemented

### ✅ Table Creation & Data Import Checks
- Creates all core tables with foreign key constraints
- Verifies data using `SELECT COUNT(*)` and `SELECT *`

### ✅ Data Operations
1. **Insert a new book**  
2. **Update a member's address**  
3. **Delete issue record safely** (using referential integrity)  
4. **List books issued by a specific employee**  
5. **List employees who issued more than one book**  
6. **Create issued book summary table**  
7. **Filter books by category**  
8. **Total rental price per category**  
9. **Total income by category** (joined with issued data)  
10. **List members registered in the last 180 days**  
11. **List employees with branch and manager details**  
12. **Create `high_cost_books` table**  
13. **List books not yet returned**  
14. **Identify overdue members (more than 25 days)**  
15. **Create `branch_report` showing branch-wise issue/return/revenue**  
16. **Create `active_members` table for last 1 year**

---

## ⚙️ Stored Procedures

### 🔹 `cat_book_count(pcategory)`
Counts number of books in a specific category.

### 🔹 `update_status_on_return(preturn_id, pissued_id)`
- Inserts a return entry
- Updates book status to "Yes"

### 🔹 `update_status_on_book_issue(pbook_id, pissued_id, pissued_member_id, pissued_emp_id)`
- Checks if book is available
- If yes: issues it and sets status to "No"
- If no: displays "Sorry, book is not available"

---

## 🧨 Triggers

### 🔹 `update_book_status_on_book_return`
- **AFTER INSERT** on `return_status`
- Automatically sets book status back to `'Yes'` when returned

---

## 📌 Example Use

```sql
CALL cat_book_count('History');

CALL update_status_on_book_issue('978-0-06-025492-6', 'IS141', 'C105', 'E105');
CALL update_status_on_return("RS120", 'IS136');

INSERT INTO return_status(return_id, issued_id, return_date, return_book_isbn) 
VALUES('RS121','IS142', CURRENT_DATE(), '978-0-06-112008-4');
```

---

## 🧠 Concepts Covered

- Relational database design
- Foreign key constraints
- Triggers and stored procedures
- Joins and aggregations
- Conditional logic in SQL (`IF`, `ELSEIF`)
- Cascading updates/deletes
- Reporting and data summaries

---

## 🧰 Tools Used

- MySQL Server / Workbench
- SQL scripting
- GitHub (for documentation and sharing)

---

## 👤 Author

Kaidampally sai kumar 
saikumarkaidampally@gmail.com  
LinkedIn] www.linkedin.com/in/ksai22

---

## ⭐ Support

If you found this helpful, please ⭐ star the repo and share!
