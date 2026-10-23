--    Overall Sales Performance
-- Revenue
-- Orders
-- Units Sold
-- Average order value
select 
sum(total) as total_revenue,
count(Distinct order_id) as total_order,
sum(quantity) as total_quantity_sold,
round(sum(total)*1.0/ nullif(count(distinct order_id),0),2) as average_order_value  -- aov= total amount/ total sale #
from gold.fact_sales


-- Revenue by year

select
year(order_date) as sales_year,
sum(total) as total_revenue,
count(distinct order_id) as total_orders,
sum(quantity) as quantity_sold
from gold.fact_sales
where order_id is not null
group by year(order_date)
order by sales_year;

-- Revenue by month

select
year(order_date) as sales_year,
month(order_date) as sales_month,
sum(total) as revenue,
count(distinct(order_id)) as total_orders,
sum(quantity) as quantity_sold
from gold.fact_sales
where order_date is not null
group by year(order_date), month(order_date)
order by sales_year, sales_month;

-- year-over-year growth

WITH yearly_sales AS (
    SELECT
        YEAR(order_date) AS sales_year,
        SUM(total) AS total_revenue
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date)
),

sales_with_previous_year AS (
    SELECT
        sales_year,
        total_revenue,
        LAG(total_revenue) OVER (
            ORDER BY sales_year
        ) AS previous_year_revenue
    FROM yearly_sales
)

SELECT
    sales_year,
    total_revenue,
    previous_year_revenue,

    ROUND(
        (
            total_revenue - previous_year_revenue
        ) * 100.0 /
        NULLIF(previous_year_revenue, 0),
        2
    ) AS yoy_growth_percentage

FROM sales_with_previous_year
ORDER BY sales_year;