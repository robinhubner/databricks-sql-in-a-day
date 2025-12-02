# 🧪 Lab – Wide World Importers: SQL, Functions, Stored Procedures & Governance

## 🎯 Learning Objectives

By the end of this lab, you will be able to:

- Ingest CSV data into Unity Catalog.
- Query and join tables using Databricks SQL with best practices such as explicit column selection.
- Create CTAS tables, scalar UDFs, and stored procedures in SQL.
- Apply data masking functions and explore table and column lineage in Unity Catalog.
- Build analytical SQL queries including window functions for year-over-year analysis.
- Access the same governed data from Python notebooks to enable BI + Data Science collaboration.

## Introduction

**What Is the Wide World Importers Dataset?**

Wide World Importers (WWI) is a sample OLTP dataset. It includes order, product, customer, and warehouse operational data.  
In this lab, you will ingest two WWI sales tables and walk through a realistic BI workflow in Databricks: ingestion → transformation → SQL functions → stored procedures → governance → advanced analytics → data science access.

---

# Step 1: Unity Catalog Setup

1. Open the Catalog **wide_world_importers** in the Databricks Data Explorer.
2. Create a personal working schema named `wwi_{yourname}`.

---

# Step 2: Ingest CSV Files into Unity Catalog

1. In the Databricks workspace, click **Data** → **Add Data**.
2. Choose **Create or modify table**, and upload:
   - `Sales.Orders.csv`
   - `Sales.OrderLines.csv`
3. Select ";" as the column delimiter in the advanced options
4. Select your Catalog & Schema.
5. Complete the ingestion wizard.
6. Open the tables in Unity Catalog and verify schema correctness.
7. Explore metadata such as comments, descriptions, and sample data.

**Data Question:** How many rows are contained in `sales_orders` and `sales_order_lines` after ingestion? Use the tab "Sample Data" to answer the question.

---

# Step 3: Query the Data in Databricks SQL

1. Open the **SQL Editor**.
2. Select your Catalog and Schema.
3. Explore the data by executing:
   ```sql
   SELECT * FROM sales_order_lines;
   ```
4. Join both tables using autocomplete
5. Replace the `SELECT *` with explicit columns:  
   `UnitPrice, TaxRate, PickingCompletedWhen, Description, Quantity, OrderID, OrderLineID`
6. Add a filter to remove string with the value 'NULL':
   ```sql
   WHERE PickingCompletedWhen <> 'NULL'
   ```
7. Extractc the date parts date, year, month, and day from the colum `PickingCompletedWhen`
8. Calculate gross revenue:
   ```sql
   UnitPrice * Quantity * (1 + TaxRate) AS gross_revenue
   ```
9. Ask the **Databricks Assistant** to format your SQL query.
10. Create a new table using CTAS:
    ```sql
    CREATE OR REPLACE TABLE joined_sales AS
    SELECT ...
    ```
11. Click **See performance** on the query and inspect the execution profile.
12. Verify the new table appears in the Catalog.

**Data Question:** Are there rows in `joined_sales` where the calculated gross revenue is NULL? How many?

---

# Step 4: Create a SQL Scalar Function

1. Create a scalar function for gross revenue calculation:
   ```sql
   CREATE OR REPLACE FUNCTION calc_gross_revenue(...)
   RETURNS ...
   RETURN ...;
   ```
2. Use the function when querying `joined_sales`.
3. Compare the UDF result with the CTAS revenue column.

**Data Question:** Are the results from the scalar function and the CTAS revenue column identical across all rows?

---

# Step 5: Create a Stored Procedure for Yearly Revenue

1. Create an empty table:
   ```sql
   CREATE OR REPLACE TABLE yearly_gross_revenue (
     order_year INT,
     gross_revenue DOUBLE
   );
   ```

2. Create a stored procedure `sp_refresh_yearly_gross_revenue` that upserts the gross_revenue grouped by year into the table `yearly_gross_revenue`.
3. Execute the procedure:
   ```sql
   CALL sp_refresh_yearly_gross_revenue();
   ```
4. Query the resulting table.

**Data Question:** What is the total gross revenue for the year **2016**?

---

# Step 6: Data Governance with Unity Catalog

1. Create a simple masking function:
   ```sql
   CREATE OR REPLACE FUNCTION simple_masking_function(...)
   RETURNS ...
   RETURN ...;
   ```

2. In the Catalog → Schema → Table tab, apply this masking function to a selected column.
3. Click on the Sample Data and see whether the masking function is masking the data.
4. Open the table **yearly_gross_revenue**, navigate to the **Lineage** tab, and inspect the graph.

**Data Question:** Which columns in `sales_order_lines` contribute to `yearly_gross_revenue.gross_revenue`?

---

# Step 7: Write a Complex SQL Query with Window Functions

1. Create a YoY analysis query:
   ```sql
   SELECT
     order_year,
     gross_revenue,
     ... AS yoy_difference,
     ... AS yoy_percentage
   FROM yearly_gross_revenue
   ORDER BY order_year;
   ```

**Data Question:** Which year shows the highest absolute YoY growth? Which shows the highest percentage YoY growth?

---

# Step 8: Access the Data from a Python Notebook

1. Create a new Python notebook.
2. Ask Databricks Assistant:  
   **"Display the DataFrame from the table joined_sales."**
3. Run the generated Python code, which will look like the following snippet:
   ```python
   df = spark.table("joined_sales")
   display(df)
   ```

**Data Question:** How many rows in the DataFrame contain NULL revenue values?

---

# What Happens Next?

You have now built a simple end-to-end BI workflow in Databricks:

- Ingestion into Unity Catalog  
- Transformations via SQL  
- Revenue logic encapsulated in UDFs  
- Automation with stored procedures  
- Governance via masking & lineage  
- Advanced analytics using window functions  
- Data science consumption from notebooks  

Next steps could include:

- Creating a Metric View  
- Building an AI/BI Dashboard  
- Exploring Genie for ad‑hoc analysis
- Automate the orchestation with Databricks Jobs
