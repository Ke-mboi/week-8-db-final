# Relational Database Design Project

## 📌 Project Overview
This project demonstrates the design and implementation of a relational database for a real-world use case.  
The goal was to create a **normalized database schema** with well-structured tables, relationships, and constraints.  

The chosen use case: **[Replace with your case e.g., Library Management / Student Records / Inventory Tracking]**

---

## 🗂️ Features
- Relational database schema using **MySQL**.
- Includes:
  - `CREATE DATABASE` statement  
  - `CREATE TABLE` statements  
  - Proper **constraints**:  
    - `PRIMARY KEY`  
    - `FOREIGN KEY`  
    - `NOT NULL`  
    - `UNIQUE`  
  - Different types of relationships:  
    - **One-to-One**  
    - **One-to-Many**  
    - **Many-to-Many**  

---

## 📂 Deliverables
The main deliverable is a single SQL file:

- **`database_schema.sql`**
  - Contains the `CREATE DATABASE` statement.  
  - Contains all `CREATE TABLE` statements.  
  - Includes all relationship constraints.

---

## ⚙️ How to Run
1. Open MySQL terminal or any MySQL client (e.g., MySQL Workbench).
2. Import the SQL file:
   ```sql
   SOURCE database_schema.sql;
