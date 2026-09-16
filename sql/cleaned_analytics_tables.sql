drop table if exists analytics.orders;

-- create new analytics table for orders after cleaning the order_date format, payment_method, status, quantity, order_amount
create table analytics.orders as
	select 
		order_id,
		customer_id,
		product_id,
		case 
			when order_date ~ '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}$' then
			to_timestamp(order_date, 'YYYY-MM-DD"T"HH24:MI:SS.US')::timestamp(0)
			when order_date ~ '^\d{4}-\d{2}-\d{2}$' then
			to_timestamp(order_date, 'YYYY-MM-DD')::timestamp(0)
			when order_date ~ '^\d{4}/\d{2}/\d{2} \d{2}:\d{2}$' then
			to_timestamp(order_date, 'YYYY/MM/DD HH24:MI')::timestamp(0)
			when order_date ~ '^\d{4}/\d{2}/\d{2}$' then
			to_timestamp(order_date, 'YYYY/DD/MM')::timestamp(0)
			when order_date ~ '^\d{2}-\d{2}-\d{4}$' then
			to_timestamp(order_date, 'DD-MM-YYYY')::timestamp(0)
			else null
		end as order_date,
		cast(
	        nullif(regexp_replace(order_amount, '[^\d\.]', '', 'g'), '') 
	    as numeric(10,2)) as order_amount, 
	    cast(
	        nullif(regexp_replace(quantity, '[^\d]', '', 'g'), '') 
	    as integer) as quantity,  
	    case 
			when lower(trim(payment_method)) in ('card', 'crad', 'c@rd', 'cd') then 'Card'
			when lower(trim(payment_method)) in ('wallet', 'wall-et') then 'Wallet'
			when lower(trim(payment_method)) in ('cash', 'notes', 'cod', 'cash on delivery') then 'Cash'
			when lower(trim(payment_method)) in ('upi', 'up-i') then 'Upi'
			else 'Unknown'
		end as payment_method,
		case 
			when lower(trim(status)) in ('success', 'suc') then 'Succeed'
			when lower(trim(status)) in ('refunded', 'ref') then 'Refunded'
			when lower(trim(status)) in ('fail', 'failed') then 'Failed'
			else 'Unknown'
		end as status
	from staging.raw_orders ro
	where order_amount !~ '^[0-9\.]+$'
		or quantity !~ '^[0-9]+$';


-- create new analytics table for customers after cleaning
drop table if exists analytics.customers;

create table analytics.customers as
	select 
		customer_id,
		initcap(trim(regexp_replace(first_name, '[^a-za-z\s\-]', '', 'g'))) as first_name,
   		initcap(trim(regexp_replace(last_name, '[^a-za-z\s\-]', '', 'g'))) as last_name,
		lower(trim(email)) as email,
		regexp_replace(phone_number, '[^\d\+]', '', 'g') as phone_number,
		case 
	        when lower(trim(gender)) in ('m', 'male') then 'Male'
	        when lower(trim(gender)) in ('f', 'female') then 'Female'
	        when lower(trim(gender)) in ('o', 'other', 'non-binary') then 'Other'
        	else 'Unknown'
    	end as gender,
		case 
			when dob ~ '^\d{2}/\d{2}/\d{4}$' then
			to_date(dob, 'mm/dd/yyyy')
		end as dob,
		case
			when signup_date ~ '^\d{2}/\d{2}/\d{4}$' then
			to_date(signup_date, 'mm/dd/yyyy')	
		end as signup_date,
		initcap(trim(address)) as address,
		initcap(trim(city)) as city,
		initcap(trim(state)) as state,
		initcap(trim(country)) as country,
		"device_id(s)",
		initcap(trim(source)) as source
	from staging.raw_customers rc;


-- create new analytics table for products after cleaning
drop table if exists analytics.products;

create table analytics.products as
	select
		product_id,
		product_name,
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
			else 'Unknown'
		end as category,
		cast(nullif(regexp_replace(price, '[^\d\.]', '', 'g'), '') as numeric(10, 2)) as price
	from staging.raw_products rp ;


-- create new analytics table for support_tickets after cleaning
drop table if exists analytics.support_tickets;

create table analytics.support_tickets as
	SELECT
		ticket_id,
		customer_id,
		case 
			when lower(trim(issue_type)) in ('product', 'pro', 'products', 'productx', 'product_', 'tcudorp', 'stcudorp', 'product-') then 'Product'
			when lower(trim(issue_type)) in ('refund', 'ref', 'refundx', 'r3fund', 'dnufer', 'refund_', 'refund-') then 'Refund'
			when lower(trim(issue_type)) in ('delay', 'd3lay', 'del', 'delayx', 'delay_', 'delay-', 'yaled') then 'Delay'
			when lower(trim(issue_type)) in ('payment', 'pay', 'paymentx', 'paym3nt', 'payment_', 'payment-', 'tnemyap') then 'Payment'
		end as issue_type,	
		case 
				when ticket_created ~ '^\d{4}-\d{2}-\d{2}T([01]\d|2[0-3]):[0-5]\d:[0-5]\d$' then
				to_timestamp(ticket_created, 'YYYY-MM-DD"T"HH24:MI:SS')::timestamp(0)
				when ticket_created ~ '^\d{4}/\d{2}/\d{2}$' then
				to_timestamp(ticket_created, 'YYYY/DD/MM')::timestamp(0)
				when ticket_created ~ '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}$' then
				to_timestamp(ticket_created, 'YYYY-MM-DD"T"HH24:MI:SS.US')::timestamp(0)
				when ticket_created ~ '^(0[1-9]|[12]\d|3[01])-(0[1-9]|1[0-2])-\d{4}$' then
				to_timestamp(ticket_created, 'DD-MM-YYYY')::timestamp(0)
				else null
			end as ticket_created,
		case 
				when ticket_resolved ~ '^\d{4}-\d{2}-\d{2}T([01]\d|2[0-3]):[0-5]\d:[0-5]\d$' then
				to_timestamp(ticket_resolved, 'YYYY-MM-DD"T"HH24:MI:SS')::timestamp(0)
				when ticket_resolved ~ '^\d{4}/\d{2}/\d{2}$' then
				to_timestamp(ticket_resolved, 'YYYY/DD/MM')::timestamp(0)
				when ticket_resolved ~ '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}$' then
				to_timestamp(ticket_resolved, 'YYYY-MM-DD"T"HH24:MI:SS.US')::timestamp(0)
				when ticket_resolved ~ '^(0[1-9]|[12]\d|3[01])-(0[1-9]|1[0-2])-\d{4}$' then
				to_timestamp(ticket_resolved, 'DD-MM-YYYY')::timestamp(0)
				else null
			end as ticket_resolved,
		resolution_time_hours,
		case 
			when lower(trim(sentiment)) in ('positive', 'pos', 'positiv3') then 'Positive'
			when lower(trim(sentiment)) in ('negative', 'n3gativ3', 'neg') then 'Negative'
			when lower(trim(sentiment)) in ('neutral', 'n3utral', 'neu') then 'Neutral'
		end as sentiment,	
		initcap(trim(support_agent)) as support_agent
	from staging.raw_support_tickets rst ;


drop table if exists analytics.clickstream;
create table analytics.clickstream as
	select
		event_id, session_id,
		customer_id,
		event_type,
		lower(trim(page_url)) as page_url,
		device_id,
		case
			WHEN timestamps ~ '^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])T([01]\d|2[0-3]):[0-5]\d:[0-5]\d\.\d+([+-]\d{2}:\d{2})$' THEN
            to_timestamp(timestamps, 'YYYY-MM-DD"T"HH24:MI:SS.USTZH:TZM')::timestamp(0)
            WHEN timestamps ~ '^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]) ([01]\d|2[0-3]):[0-5]\d:[0-5]\d\.\d+([+-]\d{2}:\d{2})$' THEN
            to_timestamp(timestamps, 'YYYY-MM-DD HH24:MI:SS.USTZH:TZM')::timestamp(0)
            WHEN timestamps ~ '^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])T([01]\d|2[0-3]):[0-5]\d:[0-5]\d$' THEN
            to_timestamp(timestamps, 'YYYY-MM-DD"T"HH24:MI:SS')::timestamp(0)
            else null
		end as timestamps,
		ingest_run_id
	from raw_clickstream rc;


-- Business Context: Removing duplicate customer records to enforce Primary Key integrity
delete from analytics.customers
where ctid not in (
    select min(ctid)
    from analytics.customers
    group by customer_id
);

-- 1. Define Primary Keys
ALTER TABLE analytics.customers ADD PRIMARY KEY (customer_id);
ALTER TABLE analytics.products ADD PRIMARY KEY (product_id);
ALTER TABLE analytics.orders ADD PRIMARY KEY (order_id);
ALTER TABLE analytics.support_tickets ADD PRIMARY KEY (ticket_id);
ALTER TABLE analytics.clickstream ADD PRIMARY KEY (event_id);

-- 2. Define Foreign Keys
ALTER TABLE analytics.orders 
    ADD CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) REFERENCES analytics.customers(customer_id);

ALTER TABLE analytics.orders 
    ADD CONSTRAINT fk_orders_products FOREIGN KEY (product_id) REFERENCES analytics.products(product_id);

ALTER TABLE analytics.support_tickets 
    ADD CONSTRAINT fk_tickets_customers FOREIGN KEY (customer_id) REFERENCES analytics.customers(customer_id);