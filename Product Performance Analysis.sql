with product_segments as
(
select
f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
f.quantity,
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost
from gold.fact_sales f
left join gold.dim_products p
on f.product_key = p.product_key
where order_date is not null
)
, base_query as
(
select
product_name,
product_key,
category,
subcategory,
cost,
sum(sales_amount) total_revenue,
sum(quantity) total_quantity,
count(distinct order_number) total_orders,
count(distinct customer_key) total_customers,
max(order_date) last_ordered,
datediff(month,min(order_date),max(order_date)) lifespan,
round(avg(cast(sales_amount as float)/nullif (quantity,0)),1) avg_selling_price

from product_segments
group by
product_name,
product_key,
category,
subcategory,
cost
)
select
product_name,
product_key,
category,
subcategory,
cost,
last_ordered,
total_revenue,
total_quantity,
total_orders,
total_customers,
datediff(month, last_ordered,getdate()) recency,
lifespan,
avg_selling_price,
case 
    when total_revenue >=50000 then 'High Performer'
	when total_revenue < 10000 then 'Mid Performer'
	else 'Low Performer'
end product_segment,
case
    when total_orders = 0 then 0
	else total_revenue/total_orders
end avg_order_revenue,
case
    when lifespan = 0 then total_revenue
	else total_revenue/lifespan
end avg_monthly_revenue
from base_query
 
