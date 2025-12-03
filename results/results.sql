CREATE OR REPLACE TABLE joined_sales AS
SELECT
  a.UnitPrice, -- Unit price of the item
  a.TaxRate, -- Tax rate applied
  a.PickingCompletedWhen, -- Date/time when picking was completed
  a.Description, -- Item description
  a.Quantity, -- Quantity ordered
  a.OrderID, -- Order identifier
  b.OrderLineID, -- Joined order line identifier (from b)
  DATE(a.PickingCompletedWhen) AS date, -- Extracted date
  YEAR(a.PickingCompletedWhen) AS year, -- Extracted year
  MONTH(a.PickingCompletedWhen) AS month, -- Extracted month
  DAY(a.PickingCompletedWhen) AS day, -- Extracted day
  a.UnitPrice * a.Quantity * (1 + a.TaxRate) AS gross_revenue -- Calculated gross revenue
FROM
  sales_order_lines a
    LEFT JOIN sales_order_lines b
      ON a.OrderLineID = b.OrderLineID -- Self-join on OrderLineID
WHERE
  a.PickingCompletedWhen <> 'NULL'; -- Exclude rows where PickingCompletedWhen is 'NULL'

SELECT AVG(gross_revenue) FROM joined_sales;


CREATE OR REPLACE FUNCTION calc_gross_revenue(
  unit_price DOUBLE,
  tax_rate DOUBLE,
  quantity BIGINT
)
RETURNS DOUBLE
RETURN (unit_price * (1 + tax_rate) * quantity);

SELECT calc_gross_revenue(UnitPrice, TaxRate, Quantity) AS gross_revenue_function,
  gross_revenue
FROM joined_sales;


CREATE OR REPLACE TABLE yearly_gross_revenue (
  order_year INT,
  gross_revenue DOUBLE
);

CREATE OR REPLACE PROCEDURE sp_refresh_yearly_gross_revenue()
SQL SECURITY INVOKER
AS
BEGIN
MERGE INTO yearly_gross_revenue t
  USING (
    SELECT
      year,
      SUM(gross_revenue) AS gross_revenue
      FROM joined_sales
      GROUP BY year
  ) s
    ON t.order_year = s.year
  WHEN MATCHED THEN
    UPDATE SET gross_revenue = s.gross_revenue
  WHEN NOT MATCHED THEN INSERT (order_year, gross_revenue) VALUES (s.year, s.gross_revenue);
END;


CALL sp_refresh_yearly_gross_revenue();
SELECT * FROM yearly_gross_revenue;


CREATE OR REPLACE FUNCTION simple_masking_function(input STRING)
RETURNS STRING
RETURN '***';

SELECT
  order_year,
  gross_revenue,
  LAG(gross_revenue) OVER (ORDER BY order_year) AS gross_revenue_previous_year,
  gross_revenue - gross_revenue_previous_year AS yoy_growth
FROM yearly_gross_revenue
ORDER BY yoy_growth DESC;
