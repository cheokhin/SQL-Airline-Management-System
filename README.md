# SQL Airline Management System

## 1. Project Objective
Engineered a comprehensive relational database management system designed to handle the complex operations of an airline. The system successfully manages flight routing, passenger bookings, frequent flyer tier statuses, and payment processing while generating actionable business insights through advanced data analytics.

## 2. Tech Stack
* **Language:** SQL (T-SQL)
* **Database Concepts:** Data Normalization, Relational Database Design, Advanced Data Extraction
* **Tools/Environments:** SQL Server Management Studio (SSMS) / Standard SQL Environments

## 3. Core Features & Architecture
* **Relational Database Design:** Built a robust schema utilizing strict Primary Key (PK) and Foreign Key (FK) relationships across 17 distinct tables to ensure complete data integrity.
* **Data Normalization:** Applied strict normalization rules to eliminate data redundancy across passenger records, flight routes, ticket classes, and reward redemptions.
* **Advanced Analytical Querying:** Developed 15 complex `SELECT` queries utilizing Common Table Expressions (CTEs), multi-table `JOIN`s, date filtering (`DATEDIFF`, `DATEADD`), and aggregations (`SUM`, `AVG`) to extract real-world business metrics such as:
  * Total revenue generated per flight route and ticket class.
  * Customer loyalty insights and top frequent flyer miles balances.
  * Automated tracking of pending payment refunds and operational bottlenecks.
* **Data Constraints:** Implemented `CHECK` and `UNIQUE` constraints to enforce logical data entry (e.g., ensuring flight departure times strictly precede arrival times and negative baggage fees are blocked).

## 4. Setup & Execution (How to Run)
1. Clone this repository to your local machine.
2. Open the `airline_management.sql` file in SQL Server Management Studio (SSMS) or any compatible SQL environment.
3. Execute the script from top to bottom. The script will automatically create the `airline_database`, establish the table schemas, insert all mock data, and run the analytical queries at the end of the file to output the business reports.
