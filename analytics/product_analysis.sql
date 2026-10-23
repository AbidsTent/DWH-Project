-- top 10 products

select top 10
	p.product_name,
	p.product_category,
	sum(s.total) as total_revenue,
	sum(s.quantity) as total_units
from gold.fact_sales s
left join gold.dim_products p
on p.product_key=s.product_key
group by 
	p.product_name,
	p.product_category
order by
	total_revenue desc;


-- revenue by category

select
	p.product_category,
	sum(s.total) as total_revenue,
	sum(s.quantity) as total_units_sold,
	count(distinct s.order_id) as total_orders
from gold.dim_products p
left join gold.fact_sales s
	on p.product_key=s.product_key
group by
	p.product_category
order by 
	total_revenue desc;

select distinct product_category
from gold.dim_products


with product_sales as(
select
	p.product_category,
	p.product_name,
	sum(s.total) as total_revenue
from gold.fact_sales s
left join gold.dim_products p
on p.product_key=s.product_key
group by p.product_category, p.product_name
)
select 
	product_category,
	product_name,
	total_revenue,
	dense_rank() over (partition by product_category order by total_revenue desc) as product_rank
from product_sales 
order by product_category, product_rank

