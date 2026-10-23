# SQL Server Data Warehouse Project

This project is a hands-on implementation of a complete SQL Server data warehouse built from CRM and ERP source data.

The main goal of this project was to understand how a data warehouse is designed and built in practice rather than only learning the theoretical concepts. I followed a guided project from Data With Baraa and recreated the pipeline myself while working through the SQL, transformations, data-quality issues, and dimensional modelling.

The project follows the Medallion architecture.
**Bronze → Silver → Gold** 


## Project Overview

The warehouse takes raw CSV files from two separate source systems:

- CRM
- ERP

The data is first loaded into the Bronze layer, then cleaned and standardized in the Silver layer, and finally combined into business-ready fact and dimension models in the Gold layer.

The general flow is:
Raw Files -> Raw data into Tables(Bronze Layer)--> Data Transformation and Cleaning(Silver Layer) --> Business-usable tables/view (Gold Layer) --> Analytics/Reporting

## Main Objectives

The project focuses on:

- Building a SQL Server data warehouse from raw files
- Creating a structured ETL pipeline
- Cleaning and standardizing inconsistent source data
- Combining CRM and ERP datasets
- Performing data-quality validation
- Creating dimensional models for analytics
- Understanding fact tables, dimension tables, surrogate keys, and star schemas
- Practicing stored procedures, SQL transformations, error handling, and testing


## Tools Used

- Microsoft SQL Server
- SQL Server Management Studio
- T-SQL
- Git
- GitHub
- CSV source files

# Data Architecture

The project uses three logical layers.

![Data Warehouse Architecture](docs/Architecture diagram.drawio (1).svg)

The architecture shows the full flow of data from the CRM and ERP source files through the Bronze, Silver, and Gold layers before the final data is used for analytics and reporting.

## Bronze Layer

The Bronze layer stores the raw data coming from the source systems.

The goal at this stage is to keep the source data close to its original form and avoid unnecessary transformations.

Data is loaded using SQL Server BULK INSERT.

The current project uses a **full batch load**, meaning the Bronze tables are truncated and loaded again during each pipeline execution.

Main responsibilities:

- Create raw source tables
- Load CRM and ERP CSV files
- Track load execution time
- Handle errors using TRY/CATCH
- Preserve the raw structure of the source data

Example flow:
CSVs -> Bulk Insert -> Bronze Tables

## Silver Layer

The Silver layer is where most of the cleaning and transformation takes place.

Data from the Bronze layer is transformed into a more consistent and usable format before it is used for analytics.

Some of the transformations performed include:

- Removing duplicate customer records
- Trimming unnecessary spaces
- Standardizing gender values
- Standardizing marital status
- Replacing missing or invalid values
- Cleaning customer IDs
- Correcting invalid sales values
- Validating sales price and quantity
- Converting integer-based dates into proper date values
- Removing or correcting invalid future dates
- Creating product category IDs
- Deriving product end dates
- Standardizing country values

Example:

M → Married
S → Single

M / MALE → Male
F / FEMALE → Female

US / USA → United States
DE → Germany


Duplicate customer records are handled using "ROW_NUMBER()" so that the most recent record for each customer is retained.



## Gold Layer

The Gold layer contains the final business-ready analytical model.
The data is represented using dimension and fact views.

Current Gold objects include:

- gold.dim_customers
- gold.dim_products
- gold.fact_sales

The Gold layer combines data from both CRM and ERP systems.

For example, customer information mainly comes from CRM, while additional information such as birth date and country comes from ERP.

For gender information, CRM is treated as the primary source and ERP is used as a fallback when necessary.


# Data Model

The Gold layer follows a basic star-schema design.

![Gold Layer Star Schema](docs/star_schema.svg)

The Gold layer uses a simple star schema where `fact_sales` represents sales transactions and connects to the customer and product dimensions through surrogate keys.

Each row in `fact_sales` represents a sales transaction associated with a customer and product, allowing the warehouse to support customer, product, and sales-performance analysis.

### dim_customers

Contains customer-related information such as:

- Customer surrogate key
- Customer ID
- Customer number
- First and last name
- Country
- Marital status
- Gender
- Birth date
- Customer creation date

### dim_products

Contains product-related information such as:

- Product surrogate key
- Product ID
- Product number
- Product name
- Category
- Subcategory
- Product line
- Cost
- Start date

Only the active product record is included in the Gold layer.

### fact_sales

Contains transactional sales information such as:

- Order number
- Customer key
- Product key
- Order date
- Shipping date
- Due date
- Quantity
- Price
- Sales amount


# ETL Process

The current project mainly follows a batch ETL approach.

## Extract

Source data is provided through CSV files from CRM and ERP systems.

The extraction/loading method used here is:


Batch + Full Load + CSV Files + SQL Server BULK INSERT

At this stage, the project does not use incremental loading or Change Data Capture.

## Transform

Most transformations occur when moving data from Bronze to Silver.

Examples include:

Deduplication
Data cleaning
Standardization
Date validation
Null handling
Business-rule correction
Column derivation
Data integration

## Load

The load strategy currently works as follows:

```text
Source CSV Files
      ↓
TRUNCATE Bronze Tables
      ↓
BULK INSERT
      ↓
TRUNCATE Silver Tables
      ↓
INSERT + Transformations
      ↓
Gold Views
```

This project currently uses a **full-refresh strategy** rather than incremental processing.

# Analytics and Business Questions

After the data is cleaned, integrated, and modeled in the Gold layer, the warehouse is used to answer business questions through SQL-based analysis.

The analytics are divided into three main areas:

### Sales Analysis

The sales analysis focuses on overall business performance and trends, including:

- Total revenue
- Total orders
- Total units sold
- Average order value
- Yearly revenue trends
- Monthly revenue trends
- Year-over-year revenue growth

The year-over-year analysis uses SQL window functions such as `LAG()` to compare revenue with the previous year.

### Customer Analysis

Customer analysis is used to better understand customer behaviour and value.

Current analysis includes:

- Highest-value customers by revenue
- Customer order counts
- Revenue by country
- Revenue by gender
- Customer segmentation based on total spending

Customers are grouped into High, Medium, and Low-value segments based on their total purchase amount.

### Product Analysis

Product analysis focuses on product and category performance.

Current analysis includes:

- Top products by revenue
- Units sold by product
- Revenue by product category
- Order volume by category
- Product rankings within each category

`DENSE_RANK()` is used to rank products based on revenue within their respective product categories.

The analytical SQL files can be found under:

```text
analytics/
├── sales_analysis.sql
├── customer_analysis.sql
└── product_analysis.sql
```
# Data Quality Checks

The project contains SQL-based quality checks across both the Silver and Gold layers.

Silver-layer checks focus on data cleansing, standardization, validity, and consistency before the data reaches the analytical model.

Gold-layer checks validate the final dimensional model and include:

- Duplicate surrogate key checks
- Missing customer references in the fact table
- Missing product references in the fact table
- Sales amount validation
- Referential consistency between fact and dimension views

---


# Error Handling and Monitoring

The Bronze and Silver loading procedures use SQL Server 'TRY/CATCH' blocks to capture errors during execution.

The procedures also track how long individual tables and layers take to load.

A future improvement for this project would be adding a dedicated ETL audit table to store:

- Pipeline name
- Start time
- End time
- Rows processed
- Pipeline status
- Error message

# Repository Structure

```text
```text
DWH-Project/
│
├── analytics/
│   ├── customer_analysis.sql
│   ├── product_analysis.sql
│   └── sales_analysis.sql
│
├── datasets/
│   ├── source_crm/
│   └── source_erp/
│
├── docs/
│   └── Architecture diagram.drawio (1).svg
│   
│
├── scripts/
│   ├── init_database.sql
│   │
│   ├── bronze/
│   │   ├── ddl_bronze.sql
│   │   └── proc_load_bronze.sql
│   │
│   ├── silver/
│   │   ├── ddl_silver.sql
│   │   └── proc_load_silver.sql
│   │
│   └── gold/
│       └── ddl_gold.sql
│
├── tests/
│   ├── quality_check_silver.sql
│   └── quality_check_gold.sql
│
├── LICENSE
└── README.md
```
```

Some filenames may be cleaned up in later versions as the project continues to improve.

---

# How to Run the Project

### 1. Create the database

Run:

```text
scripts/init_database.sql
```

This creates:

- `DataWarehouse`
- Bronze schema
- Silver schema
- Gold schema

---

### 2. Create Bronze tables

Run:

```text
scripts/bronze/ddl_bronze.sql
```

---

### 3. Load Bronze data

Run:

```text
scripts/bronze/ddl_load_data.sql
```

Then execute:

```sql
EXEC bronze.load_bronze;
```

The file paths inside the stored procedure may need to be updated depending on where the dataset is stored locally.

---

### 4. Create Silver tables

Run:

```text
scripts/silver/ddl_silver.sql
```

---

### 5. Load and transform Silver data

Run:

```text
scripts/silver/proc_silver_data
```

Then execute:

```sql
EXEC silver.load_silver;
```

---

### 6. Run Silver quality checks

Run:

```text
tests/quality_check_silver
```

---

### 7. Create the Gold layer

Run:

```text
scripts/gold/gold_ddl
```

This creates the analytical dimension and fact views.
### 8. Run Gold quality checks

Run:

```text
tests/quality_check_gold.sql
```

These checks validate the final analytical model and help confirm that fact and dimension relationships are consistent.

---

### 9. Run analytical queries

The analytics scripts can be executed after the Gold layer has been created and validated.

```text
analytics/sales_analysis.sql
analytics/customer_analysis.sql
analytics/product_analysis.sql
```

These scripts generate business-focused insights from the completed warehouse.
---

# Skills Practiced

This project helped me practice and better understand:

- SQL
- T-SQL
- Data Warehousing
- ETL
- Data Cleaning
- Data Transformation
- Data Integration
- Dimensional Modeling
- Fact and Dimension Tables
- Star Schema
- Surrogate Keys
- Stored Procedures
- Window Functions
- Data Quality Testing
- Error Handling
- Batch Processing
- Full-Load Pipelines
- Git and GitHub
- - Exploratory Business Analysis
- KPI Analysis
- Trend Analysis
- Customer Segmentation
- Year-over-Year Analysis
- Analytical SQL
- Common Table Expressions (CTEs)
- Ranking Functions
- `LAG()` and `DENSE_RANK()`
- Business-Focused Data Modeling

More importantly, the project helped me understand why data is separated into different layers and how raw operational data can gradually be turned into something useful for reporting and analytics.

---

# Current Limitations

This version of the project is intentionally kept fairly simple.

It currently does not include:

- Incremental loading
- Change Data Capture
- Pipeline orchestration
- Automated scheduling
- Cloud data warehouse services
- CI/CD
- Automated testing framework
- Production monitoring
- Slowly Changing Dimension Type 2 implementation

These are areas I plan to explore as I continue learning data engineering.

---

# Planned Improvements

Possible future improvements include:

- Power BI dashboard connected to the Gold layer
- Incremental data loading
- Slowly Changing Dimension handling
- Pipeline orchestration and scheduling
- Cloud-based data warehousing
- Automated data-quality testing

---

# Learning Source and Acknowledgement

This project was developed while following the **Data With Baraa SQL Data Warehouse Project**.

Original project:

https://github.com/DataWithBaraa/sql-data-warehouse-project

I used the project as a guided learning resource and recreated the implementation myself while working through the SQL, debugging issues, understanding the transformations, and learning the reasoning behind the Bronze, Silver, and Gold architecture.

The purpose of this repository is to document my own hands-on learning and continued development in data warehousing and data engineering.
