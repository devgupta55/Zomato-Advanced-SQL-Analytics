-- Q1. Top 5 Most Frequently Ordered Dishes
-- Question:
-- Write a query to find the top 5 most frequently ordered dishes by the customer "Arjun Mehta" in the last 1 year.

/* 
with CTE as(
	select 
		cs.customer_id,
		cs.customer_name,
		os.order_item as "Dish", 
		count(*) as Count,
		dense_rank() over (order by count(*) desc) as Rank
		-- cs.reg_date,
		-- os.order_date,
		-- os.order_date-cs.reg_date as interval
	from customers cs
		inner join orders os
		on cs.customer_id = os.customer_id
	where os.order_date >= current_date - Interval '1.5 Year' AND customer_name = 'Arjun Mehta'
	group by 1,2,3
)
select 
	* 
from CTE 
where Rank<=5 
*/

-----------------------------------------------------------------------------------
-- Q2. Popular Time Slots
-- Question:
-- Identify the time slots during which the most orders are placed, based on 2-hour intervals.

/*
select 
	CASE  
	    WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'  
	    WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'  
	    WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'  
	    WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'  
	    WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'  
	    WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'  
	    WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'  
	    WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'  
	    WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'  
	    WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'  
	    WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'  
	    WHEN EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'  
	END AS Time_Slot,
	count(*) as Frequency
from orders

group by 1
order by 2 desc
*/

--------------------------------------------------------------------------------------------------------
-- Q3. Order Value Analysis
-- Question:
-- Find the average order value (AOV) per customer who has placed more than 750 orders.
-- Return: customer_name, aov (average order value).

/*
with CTE as(
	select
		cs.customer_id,
		cs.customer_name,
		count(os.order_id) as OrderCount,
		Avg(os.total_amount) as AvgAmount
	from customers cs
		inner join orders os
		on cs.customer_id = os.customer_id
	
	group by 1,2
)
select 
	*
from CTE 
where OrderCount>750
*/

---------------------------------------------------------------------------------
-- Q4. High-Value Customers
-- Question:
-- List the customers who have spent more than 100K in total on food orders.
-- Return: customer_name, customer_id.
/*
with CTE as(
	select
		cs.customer_id,
		cs.customer_name,
		sum(os.total_amount) as TotalAmount
	from customers cs
		inner join orders os
		on cs.customer_id = os.customer_id
	group by 1,2
)

select 
	* 
from CTE
where TotalAmount>100000

*/

-------------------------------------------------------------------------
-- Q5. Orders Without Delivery
-- Question:
-- Write a query to find orders that were placed but not delivered.
-- Return: restaurant_name, city, and the number of not delivered orders.

/* 
select
	rs.restaurant_id,
	rs.restaurant_name,
	rs.city,
	ds.delivery_status,
	os.order_status,
	count(os.order_id) as NotDelivered
from orders os
	left join deliveries ds
	on os.order_id = ds.order_id
	left join restaurants rs
	on os.restaurant_id = rs.restaurant_id

where ds.delivery_id is null

group by 1,2,3,4,5

order by 6 desc
*/
-------------------------------------------------------------------------
-- Q6. Restaurant Revenue Ranking
-- Question:
-- Rank restaurants by their total revenue from the last year.
-- Return: restaurant_name, total_revenue, and their rank within their city.

/*
with CTE as(
	select
		rs.city,
		rs.restaurant_name,
		sum(total_amount) as Total_Revenue,
		rank() over (partition by rs.city order by sum(total_amount) desc)
	from orders os
		inner join restaurants rs
		on os.restaurant_id = rs.restaurant_id
		
	group by 1,2	
)
select 
	* 
from CTE
where rank<=1
*/

-----------------------------------------------------------------------
-- Q7. Most Popular Dish by City
-- Question:
-- Identify the most popular dish in each city based on the number of orders.

/*
with CTE as(
	select
		os.order_item as Dish,
		rs.city as City,
		count(os.order_id) as Count,
		rank() over(partition by rs.city order by count(os.order_id) desc) as Rank
	from orders os
		inner join restaurants rs
		on os.restaurant_id = rs.restaurant_id
	group by 1,2
)

select 
* 
from CTE
where rank=1
*/
---------------------------------------------------------------------------------
-- Q8. Customer Churn
-- Question:
-- Find customers who haven’t placed an order in 2024 but did in 2023.
/*
select distinct
	customer_id
from orders
where
	extract(year from order_date) = 2023
	AND
	customer_id not in 
		(select 
			customer_id 
		from orders 
		where extract (year from order_date) = 2024
		)
*/

---------------------------------------------------------------------------------
-- Q9. Cancellation Rate Comparison
-- Question:
-- Calculate and compare the order cancellation rate for each restaurant between the current year
-- and the previous year.
/*
with CTE_2023 as(
	select 
		rs.restaurant_name as Restaurant,
		count(os.order_id) as TotalOrders2023,
		count(case when ds.delivery_id is null then 1 end) as NotDeliveredCount2023
	from orders os
		left join deliveries ds
		on os.order_id = ds.order_id
		inner join restaurants as rs
		on os.restaurant_id = rs.restaurant_id
	where extract (year from os.order_date) = 2023
	
	group by 1
	
	order by 2 desc
),
CTE_2024 as(
	select 
		rs.restaurant_name as Restaurant,
		count(os.order_id) as TotalOrders2024,
		count(case when ds.delivery_id is null then 1 end) as NotDeliveredCount2024
	from orders os
		left join deliveries ds
		on os.order_id = ds.order_id
		inner join restaurants as rs
		on os.restaurant_id = rs.restaurant_id
	where extract (year from os.order_date) = 2024
	
	group by 1
	
	order by 2 desc
)

select 
	CTE_2023.restaurant,
	round(notdeliveredcount2023::numeric/totalorders2023::numeric*100,2)as CancellationRate2023,
	round(notdeliveredcount2024::numeric/totalorders2024::numeric*100,2) as CancellationRate2024
from CTE_2023 
	inner join CTE_2024 
	on CTE_2023.Restaurant = CTE_2024.Restaurant
*/
---------------------------------------------------------------------------
--Q10. Rider Average Delivery Time
--Question:
--Determine each rider's average delivery time.
/*
SELECT 
    o.order_id,
    o.order_time,
    d.delivery_time,
    d.rider_id,
    d.delivery_time - o.order_time AS time_difference,
	EXTRACT(EPOCH FROM (d.delivery_time - o.order_time + 
	CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day' ELSE
	INTERVAL '0 day' END))/60 as time_difference_insec
FROM orders AS o
JOIN deliveries AS d
ON o.order_id = d.order_id
WHERE d.delivery_status = 'Delivered';
*/
-------------------------------------------------------------------------

-- Q11. Monthly Restaurant Growth Ratio
-- Question:
-- Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining.
/*

with CTE as(
	select
		rs.restaurant_id,
		rs.restaurant_name,
		to_char(order_date, 'mm-yy') as month,
		lag(count(os.order_id),1) over (partition by rs.restaurant_id order by to_char(order_date, 'mm-yy')) as prev_month_orders,
		count(distinct os.order_id) as current_month_orders
		
	from orders os
		inner join restaurants rs
		on os.restaurant_id = rs.restaurant_id
		inner join deliveries ds
		on os.order_id = ds.order_id
	where ds.delivery_status = 'Delivered'
		
	group by 1,2,3
		
	order by 1 asc
)

select 
	*,
	concat(round((current_month_orders::numeric-prev_month_orders::numeric)/prev_month_orders*100,2),'%') as Difference
from CTE
*/

-------------------------------------------------------------------------------------------------------
-- Q12. Customer Segmentation
-- Question:
-- Segment customers into 'Gold' or 'Silver' groups based on their total spending compared to the
-- average order value (AOV). If a customer's total spending exceeds the AOV, label them as
-- 'Gold'; otherwise, label them as 'Silver'.
-- Return: The total number of orders and total revenue for each segment.
/*
With CTE_1 as (
	select
		cs.customer_id,
		cs.customer_name,
		sum(os.total_amount) as TotalSpent
	from customers cs
		inner join orders os
		on cs.customer_id = os.customer_id
		
	where order_status = 'Completed'
		
	group by 1,2
		
	order by 1
)

select 
	CTE_1.*,
	case 
		when totalspent > (select avg(total_amount) from orders) then 'Gold'
		else 'Silver'
		end as Customer_Status
from CTE_1 

order by 1 
*/

--------------------------------------------------------------
-- Q13. Rider Monthly Earnings
-- Question:
-- Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.
/*
select 
	rs.rider_id,
	to_char(os.order_date, 'mm-yy') as Month,
	round(sum(os.Total_Amount)*0.08,2) as RidersMonthlyIncome
	
from orders os
	inner join deliveries ds
	on os.order_id = ds.order_id
	inner join riders rs
	on rs.rider_id = ds.rider_id

group by 1,2

order by 1,2
*/
-----------------------------------------------------------
-- Q14. Rider Ratings Analysis
-- Question:
-- Find the number of 5-star, 4-star, and 3-star ratings each rider has.
-- Riders receive ratings based on delivery time:
-- ● 5-star: Delivered in less than 15 minutes
-- ● 4-star: Delivered between 15 and 20 minutes
-- ● 3-star: Delivered after 20 minutes
/*
select
	rider_id,
	RiderRating,
	count(*)
	from
	(
		select 
			rider_id,
			TimeTaken,
			case
				when TimeTaken>20 then '3-Star'
				when TimeTaken between 15 AND 20 then '4-Star'
				when TimeTaken<15 then '5-Star'
			end as RiderRating
		from 
		(
			select
				rs.rider_id,
				rs.rider_name,
				os.order_time,
				ds.delivery_time,
				round(extract(epoch from(ds.delivery_time - os.order_time +
				case
					when ds.delivery_time<os.order_time then INTERVAL '1 Day'
				else Interval '0 Day'
				end))/60,2) as TimeTaken
			from deliveries ds
				inner join riders rs
				on ds.rider_id = rs.rider_id
				inner join orders os
				on os.order_id = ds.order_id

			where delivery_status = 'Delivered'
		) as t1
	)as t2

group by 1,2
order by 1, 3 desc
*/

-----------------------------------------------------------------------------
--Q16. Customer Lifetime Value (CLV)
--Question:
--Calculate the total revenue generated by each customer over all their orders.
/*
select
	cs.customer_id,
	cs.customer_name,
	sum(total_amount) as TotalAmountSpent
from orders os
	inner join customers cs
	on os.customer_id = cs.customer_id

group by 1,2

order by 1
*/

--------------------------------------------------------------------------------
-- Q17. Monthly Sales Trends
--Question:
--Identify sales trends by comparing each month's total sales to the previous month.
/*
select
	extract (year from order_date) as Year,
	extract (month from order_date) as Month,
	sum(total_amount) as TotalAmount,
	lag(sum(total_amount),1) over (order by extract (year from order_date), extract (month from order_date))
from orders os
group by 1,2
*/

----------------------------------------------------------------------------------------
-- Q18. Rider Efficiency
-- Question:
-- Evaluate rider efficiency by determining average delivery times and identifying those with the
-- lowest and highest averages.
/*
with CTE as(
	select
		rs.rider_id,
		order_time,
		delivery_time,
		round(extract(epoch from (ds.delivery_time-os.order_time+
		case 
			when ds.delivery_time<os.order_time then interval '1 Day' 
		else
			interval '0 Day' end))/60,2) as TimeDifference
	from orders os
		inner join deliveries ds
		on os.order_id = ds.order_id
		inner join riders rs
		on ds.rider_id = rs.rider_id

	where delivery_status = 'Delivered'
),
riders_time as (
	select 
		rider_id,
		avg(TimeDifference) as AvgTime
	from CTE
	group by 1
)

select 
	round(min(AvgTime),2) as MinTimeTaken,
	round(max(AvgTime),2) as MaxTimeTaken
from CTE 
	inner join riders_time 
	on CTE.rider_id = riders_time.rider_id
*/

------------------------------------------------------------------------------
--Q19. Order Item Popularity
--Question:
--Track the popularity of specific order items over time and identify seasonal demand spikes
/*
create view vw_Order_item_by_Season as
with CTE as(
	select
		*,
		extract (month from order_date) as Month,
		case
			when extract (month from order_date) between 4 and 6 then 'Spring'
			when extract (month from order_date) between 4 and 9 then 'Summer'
		else 'Winter'
		end as Seasons
	
	from orders
)
select 
	order_item,
	Seasons,
	count(order_id) as TotalOrders
from CTE
group by 1,2
order by 1,3 Desc
*/

---------------------------------------------------------------------
--Q20. City Revenue Ranking
--Question:
--Rank each city based on the total revenue for the last year (2023).

/*
select
	rs.city as City,
	sum(total_amount) as TotalAmount,
	extract(year from order_date) as Year,
	rank() over(order by sum(total_amount) desc)
from orders os
	inner join restaurants rs
	on os.restaurant_id = rs.restaurant_id
where extract(year from order_date) = 2023
group by 1,3
*/




