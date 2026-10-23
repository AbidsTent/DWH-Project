-- Customers 

create or alter view gold.dim_customers as
select 
row_number() over (order by cst_id) as customer_key,  -- created a surrogate key
ci.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as firstname,
ci.cst_lastname as lastname,
lc.cntry as country,
ci.cst_marital_status as marital_status,
case when ci.cst_gndr != 'N/A' then ci.cst_gndr  -- considering CRM is the master source
	 else coalesce(ec.gen, 'N/A')                -- utilizing gender data from CRM to overwrite ERP gender data and vice-versa in view
end as gender,
ec.bdate as birthdate,
ci.cst_create_date as create_date
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ec
on ci.cst_key = ec.cid
left join silver.erp_loc_a101 lc
on ci.cst_key=lc.cid;

go
-- Products

create or alter view gold.dim_products as
select
	ROW_NUMBER() over (order by p1.prd_start_dt, p1.prd_id) as product_key, -- surrogate key
	p1.prd_id as product_id,
	p1.prd_key as product_number,
	p1.cat_id as category_id,
	p1.prd_nm as product_name,
	p1.prd_cost as cost,
	p2.cat as product_category,
	p2.subcat as product_subcategory,
	p1.prd_line as product_line,
	p1.prd_start_dt as start_date,
	p2.maintenance
from silver.crm_prd_info p1
left join silver.erp_px_cat_g1v2 p2
on p1.cat_id=p2.id
where p1.prd_end_dt is null;   -- filtering out historical data

go
-- sales fact view


create or alter view gold.fact_sales as
select
s.sls_ord_num as order_id,
p.product_key,        -- used FK [surrogate]
c.customer_key,    -- used FK [surrogate]
s.sls_price as price,
s.sls_quantity as quantity,
s.sls_sales as total,
s.sls_order_dt as order_date,
s.sls_ship_dt as shipping_date,
s.sls_due_dt as due_date
from silver.crm_sales_details s
left join gold.dim_customers c
on s.sls_cust_id= c.customer_id
left join gold.dim_products p
on s.sls_prd_key = p.product_number;

go