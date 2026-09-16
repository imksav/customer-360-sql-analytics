


-- safely parsing order_date while isolating unparsable records
select 
	order_id,
	order_date as raw_order_date,
	case 
		when order_date ~ '^\d{4}-\d{2}-\d{2}t\d{2}:\d{2}:\d{2}\.\d{6}$' then
		to_timestamp(order_date, 'yyyy-mm-dd"t"hh24:mi:ss.us')::timestamp(0)
		when order_date ~ '^\d{4}-\d{2}-\d{2}$' then
		to_timestamp(order_date, 'yyyy-mm-dd')::timestamp(0)
		when order_date ~ '^\d{4}/\d{2}/\d{2} \d{2}:\d{2}$' then
		to_timestamp(order_date, 'yyyy/mm/dd hh24:mi')::timestamp(0)
		when order_date ~ '^\d{4}/\d{2}/\d{2}$' then
		to_timestamp(order_date, 'yyyy/dd/mm')::timestamp(0)
		when order_date ~ '^\d{2}-\d{2}-\d{4}$' then
		to_timestamp(order_date, 'dd-mm-yyyy')::timestamp(0)
		else null
	end as cleaned_order_date
from staging.raw_orders ro
limit 50;


-- business context: finding orphan orders that cannot be linked to a customer 360 profile.
select 
    count(o.order_id) as total_orders,
    sum(case when c.customer_id is null then 1 else 0 end) as orphan_orders,
    round(
        sum(case when c.customer_id is null then 1 else 0 end) * 100.0 / count(o.order_id), 
        2
    ) as orphan_percentage
from staging.raw_orders o
left join staging.raw_customers c 
    on o.customer_id = c.customer_id;


select * from raw_orders ro ;


-- business context: finding rows where the amount or quantity contains letters or weird symbols.
select 
    order_id, 
    order_amount as raw_amount, 
    cast(
        nullif(regexp_replace(order_amount, '[^\d\.]', '', 'g'), '') 
    as numeric(10,2)) as clean_order_amount,
    cast(
        nullif(regexp_replace(quantity, '[^\d]', '', 'g'), '') 
    as integer) as clean_quantity,
    quantity  as raw_quantity
from staging.raw_orders 
where order_amount !~ '^[0-9\.]+$'  -- finds rows that contain characters other than numbers and decimals
   or quantity !~ '^[0-9]+$'        -- finds rows that contain characters other than whole numbers
limit 50;


select
	product_id,
	category as old_category,
	case 
		when lower(trim(category)) in ('clothing', 'clo', 'clothing_', 'clothing-') then 'Clothing'
		when lower(trim(category)) in ('toys', 'toys-', 'toy') then 'Toys'
		when lower(trim(category)) in ('b3auty', 'beauty', 'beauty_', 'beauty-', 'bea') then 'Beauty'
		when lower(trim(category)) in ('electronics', 'ele', 'electronics_', '3l3ctronics') then 'Electronics'
		when lower(trim(category)) in ('automotive_', 'automotive-', 'automotive', 'automotiv3', 'aut') then 'Automotive'
		when lower(trim(category)) in ('home_', 'home', 'hom', 'home-', 'hom3') then 'Home'
		when lower(trim(category)) in ('kitchen-', 'kit', 'kitchen', 'kitch3n') then 'Kitchen'
		when lower(trim(category)) in ('sports', 'sport', 'sports-') then 'Sports'
		when lower(trim(category)) in ('kit', 'kits') then 'Kits'
		else 'Unkown'
	end as new_category,
	
	price as raw_price,
	cast(
	nullif(regexp_replace(price, '[^\d\.]', '', 'g'), '')
	as numeric(10, 2)) as clean_price
from
	staging.raw_products rp ;

	
select issue_type, ticket_created, ticket_resolved, resolution_time_hours, sentiment, support_agent from staging.raw_support_tickets rst ;

select source, count(*)
from staging.raw_customers rc
group by source;


-- Find names with numbers or symbols in them
SELECT first_name, last_name
FROM staging.raw_customers
WHERE first_name !~ '^[a-zA-Z]+$' OR last_name !~ '^[a-zA-Z]+$'
LIMIT 20;

-- Look at a sample of phone numbers to see formats (e.g., +1, hyphens, brackets)
SELECT * 
FROM staging.raw_customers
WHERE phone_number IS NOT NULL
LIMIT 20;


select * from staging.raw_support_tickets rst ;