-- Create our separate workspaces
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analytics;

create table staging.raw_customers (
	customer_id VARCHAR,
	first_name VARCHAR,
	last_name VARCHAR,
	email VARCHAR,
	phone_number VARCHAR,
	gender VARCHAR,
	dob VARCHAR,
	signup_date VARCHAR,
	address VARCHAR,
	city VARCHAR,
	state VARCHAR,
	country VARCHAR,
	"device_id(s)" VARCHAR,
	source VARCHAR,
	row_imported_at TIMESTAMP default CURRENT_TIMESTAMP
);

create table staging.raw_products (
	product_id VARCHAR,
	product_name VARCHAR,
	category VARCHAR,
	price VARCHAR,
	row_imported_at TIMESTAMP default CURRENT_TIMESTAMP
);

CREATE TABLE staging.raw_orders (
    order_id VARCHAR,
    customer_id VARCHAR,
    product_id VARCHAR,
    order_amount VARCHAR,
    order_date VARCHAR,
    payment_method VARCHAR,
    status VARCHAR,
    quantity VARCHAR,
    row_imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE staging.raw_support_tickets (
    ticket_id VARCHAR,
    customer_id VARCHAR,
    issue_type VARCHAR,
    ticket_created VARCHAR,
    ticket_resolved VARCHAR,
    resolution_time_hours VARCHAR,
    sentiment VARCHAR,
    support_agent VARCHAR,    
    row_imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE staging.raw_clickstream (
    event_id VARCHAR,
    session_id VARCHAR,
    customer_id VARCHAR,
    event_type VARCHAR,
    page_url VARCHAR,
    device_id VARCHAR,
    timestamp VARCHAR,
    ingest_run_id VARCHAR,
    row_imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);