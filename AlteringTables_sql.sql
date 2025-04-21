select * from customers
select * from deliveries
select * from orders
select * from restaurants
select * from riders

ALTER TABLE customers
add constraint customer_pk primary key (customer_id)
ALTER COLUMN reg_date TYPE DATE
USING reg_date::DATE;

alter table orders
-- add constraint order_pk primary key (order_id),
-- add constraint customer_fk foreign key (customer_id) references customers(customer_id)
add constraint restaurant_fk foreign key (restaurant_id) references restaurants(restaurant_id)
alter column order_id set not null,
alter column customer_id type int,
alter column restaurant_id type int,
alter column order_item type varchar(50),
alter column order_status type varchar(20),
alter column total_amount type int,
alter column order_time type time
alter column order_date type date
using order_date::DATE;


Alter Table deliveries
--add constraint delivery_pk primary key (delivery_id)
--add constraint order_fk foreign key (order_id) references orders(order_id)
add constraint rider_fk foreign key (rider_id) references riders(rider_id)
alter column delivery_id set not null,
alter column order_id type int,
alter column delivery_status type varchar (25),
alter column rider_id type int,
ALTER COLUMN delivery_time TYPE time




alter table restaurants
add constraint restaurant_pk primary key (restaurant_id)
alter column restaurant_id set not null,
alter column restaurant_name type varchar(50),
alter column city type varchar(25),
alter column opening_hours type varchar(50)

alter table riders
add constraint rider_pk primary key (rider_id)
alter column rider_id set not null,
alter column rider_name type varchar (50),
alter column sign_up type date
using sign_up::date;
