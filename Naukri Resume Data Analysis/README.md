Resume Portal Analytics – SQL Project

This project simulates a resume-building platform ecosystem with multiple portals, user registrations, subscriptions, and resume document creation. It is designed to perform SQL-based analytics on user behavior and platform performance.
🛠️ Technologies Used
Database: SQL Server / MySQL
Language: SQL
Features Used: Joins, CTEs, Aggregations, Filtering, Window Functions

📁 Schema Overview
portal: List of portals (e.g., Zety, Resume Now, Live Career)
user_registration: Tracks user registration/subscription data across portals
resume_doc: Stores resumes created by users, including experience levels

🔍 Key Use Cases (Queries)

Monthly Registration Trend
Count of registrations on Resume Now portal for each month in 2024.
Top Performing Portal
Identify the portal with the highest subscription rate in the last 30 days.
Low Resume Activity Users
Count users who created fewer than 3 resumes.
Zety Subscribers' First Resume Experience
List of users who subscribed to Zety in 2024 and their experience on their first resume.

✅ Sample Query Techniques
JOIN and LEFT JOIN for merging related data
GROUP BY and HAVING for aggregations
WINDOW FUNCTIONS like ROW_NUMBER() to rank resume creation dates
Conditional aggregation using CASE WHEN
Date filtering with functions like YEAR(), MONTH(), and GETDATE()

📦 Sample Data
The project includes insert scripts for meaningful test data, covering edge cases like:
Users registered on multiple portals
Subscriptions with and without resume uploads
Future-dated resumes and cross-year scenarios
