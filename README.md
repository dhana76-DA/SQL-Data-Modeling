# SQL-Data-Modeling

1. Objective
The objective of this project was to design and implement a Star Schema data model in MySQL to analyze retail sales data efficiently and generate meaningful business insights using structured dimensional modeling.

Why Star Schema?
A Star Schema:
Improves query performance
Simplifies data analysis
Is ideal for OLAP workloads
Enables fast aggregation and slicing/dicing

To design and implement a Star Schema using SQL for the Global Superstore dataset.
Tools Used:
MySQL, dbdiagram.io

Procedure:
Studied dataset attributes.
Identified fact and dimension tables.
Designed star schema.
Created ER diagram using dbdiagram.io.
Implemented schema using SQL.
Executed analytical queries.
The Sample Superstore CSV dataset was first loaded into MySQL using a staging table to avoid data-type and format errors.
Data cleaning and transformation were performed, especially standardizing mixed date formats for accurate analysis.
A star schema was designed with one central fact table (Sales) and four dimension tables (Customer, Product, Date, Region).
Dimension tables were populated with distinct values, and the fact table was loaded using foreign key mappings.
Analytical queries were executed and results were exported as analysis_outputs.csv for reporting and validation.



🛠️ Task Information

Identified fact and dimension tables from the Superstore dataset.
Created dimension tables with primary keys and a fact table with foreign keys.
Cleaned and transformed data (especially date formats) during the ETL process.
Loaded transactional data into the fact table using proper joins.
Performed analytical queries and exported summarized results for reporting.

📊 Result / Observations
The star schema was successfully implemented without errors, and all records were properly mapped with no missing foreign keys.
Analysis revealed category-wise, region-wise, and year-wise sales trends, showing consistent business growth over time.
The final analytical outputs were validated in MySQL and exported as analysis_outputs.csv, confirming the correctness and efficiency of the star schema model.
“A star schema diagram is viewed in MySQL Workbench using the Reverse Engineer option, which generates an EER diagram showing a central fact table connected to multiple dimension tables via foreign keys.”
