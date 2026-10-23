-- top customer by revenue

select
c.customer_key,
CONCAT(c.firstname, ' ', c.lastname) AS customer_name,
count(distinct s.order_id) as total_orders,
sum(s.total) as total_amount
from gold.dim_customers c
left join gold.fact_sales s
on c.customer_key= s.customer_key
group by c.customer_key,c.firstname,c.lastname 
order by total_amount desc

-- revenue by country
select 
c.country,
COUNT(DISTINCT c.customer_key) AS customers,
COUNT(DISTINCT s.order_id) AS orders,
sum(s.total) as total_revenue
from gold.fact_sales s
left join gold.dim_customers c
on c.customer_key=s.customer_key
group by c.country
order by total_revenue desc;

-- revenue by gender
select 
c.gender,
count(distinct c.customer_key) as customers,
sum(s.total) as total_revenue
from gold.fact_sales s
left join gold.dim_customers c
on c.customer_key=s.customer_key
group by c.gender
order by total_revenue desc;


--customer value segmentation
with customer_sales as (
select
	c.customer_key,
	concat(c.firstname, ' ', c.lastname) AS customer_name,
	count(distinct s.order_id) as total_orders,
	coalesce(sum(s.total),0) as total_amount
from gold.dim_customers c
left join gold.fact_sales s
	on c.customer_key= s.customer_key
group by c.customer_key,c.firstname,c.lastname 
) 
select 
	customer_key,
	customer_name,
	total_orders,
	total_amount,
	case when total_amount>= 10000 then 'High'
		 when total_amount>= 5000 then 'Medium'
		 else 'Low'
	end as Customer_Value
from customer_sales
order by total_amount desc;