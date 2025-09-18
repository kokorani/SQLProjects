/*
select * from hotel_cities;

select * from hotel_names;

alter table hotel_names
drop column column5;

select * from hotel_customers

alter table hotel_customers
drop column temp_date;

UPDATE [hotel_customers]
SET dob = CONVERT(DATE, dob, 1);

*/

-- 1 write a sql to find top 5 customers who did most number booking in the same city where they live.
--Display customer id and percent of those bookings compare to total number of bookings done by them.

select * from hotel_bookings;

with customer_bookings as(
    --total bookings for each customer
    SELECT
        customer_id,
        count(*) as total_bookings
        from hotel_bookings
        group by customer_id
),
same_city_bookings as(
    --bookings in city same as customer city
    select 
    hb.customer_id,
    count(*) as bookings_in_home_city
    from hotel_bookings hb
    inner join hotel_names hn on hb.hotel_id=hn.id
    inner join hotel_customers hcu on hb.customer_id=hcu.customer_id
    where hn.city_id=hcu.city_id
    group by hb.customer_id
),
booking_percentage as(
    select 
        scb.customer_id,
        scb.bookings_in_home_city,
        cb.total_bookings,
        (scb.bookings_in_home_city*100.0/cb.total_bookings) as home_city_booking_percentage,
        dense_rank() over(order by scb.bookings_in_home_city desc) as rnk
    from same_city_bookings scb 
    inner join customer_bookings cb on scb.customer_id=cb.customer_id
)
select customer_id,bookings_in_home_city,total_bookings, home_city_booking_percentage
from booking_percentage
where rnk<=5
order by rnk;

--2 write a sql to find percent contribution by females in terms of revenue and no of bookings for each hotel

with cte1 as(
select 
    hotel_id,
    count(booking_id) as total_bookings,
    sum(number_of_nights*per_night_rate) as revenue
    from hotel_bookings
    group by hotel_id
),
cte2 as(
    select hb.hotel_id,
    count(hb.booking_id) as female_bookings,
    sum(number_of_nights*per_night_rate) as f_revenue
    from hotel_bookings hb
    inner join hotel_customers hc
    on hb.customer_id=hc.customer_id 
    where hc.gender='F'
    group by hb.hotel_id
)
select cte1.hotel_id,
cte2.female_bookings,
cte1.total_bookings,
(female_bookings*100.0/total_bookings) as female_booking_percentage,
cte2.f_revenue,
cte1.revenue,
(f_revenue/revenue)*100.0 as precent_contribution
from cte1 inner join cte2
on cte1.hotel_id=cte2.hotel_id
order by cte1.hotel_id asc;

--3 for each hotel find number of bookings for customers who visit from a different state 
--check

select * from hotel_bookings;

with cte1 as(
    --get hotel information by city and state
    select hb.hotel_id,
    hn.city_id as hotel_city_id,
    hci.state as hotel_state
    from hotel_bookings hb inner join hotel_names hn on hb.hotel_id=hn.id
    inner join hotel_cities hci on hn.city_id=hci.id
    group by hb.hotel_id,hn.city_id,hci.state
),
cte2 as(
    --get customer information by city and state
    select 
        hb.booking_id,
        hb.hotel_id,
        hcu.city_id as customer_city_id,
        hci.state as customer_state
    from hotel_bookings hb 
    inner join hotel_customers hcu on hb.customer_id=hcu.customer_id
    inner join hotel_cities hci on hcu.city_id=hci.id
)
select
    c1.hotel_id,
    c1.hotel_city_id,
    c1.hotel_state,
    count(c2.booking_id) as different_state_bookings
from cte1 c1 
inner join cte2 c2 on c1.hotel_id = c2.hotel_id
WHERE c1.hotel_state <> c2.customer_state
group by c1.hotel_id, c1.hotel_city_id, c1.hotel_state
order by different_state_bookings desc;

--4 for each hotel find the date when occupancy was maximum (a customer should not be considered in hotel on the checkout date)

select * from hotel_bookings;

select * from (
select 
    hotel_id,
    stay_start_date,
    COUNT(*) as no_of_guests,
    rank() over(partition by hotel_id order by COUNT(*) desc) as rn
from hotel_bookings
group by hotel_id,stay_start_date
) a
where rn=1;


--5 find customers who have booked hotels in atleast 3 different states

select * from hotel_bookings;

with cte1 as(
select 
    hb.customer_id,
    hb.hotel_id,
    hn.city_id as hotel_city_id,
    hci.state as hotel_state
from hotel_bookings hb
inner join hotel_names hn on hb.hotel_id=hn.id
inner join hotel_cities hci on hn.city_id=hci.id
)
select customer_id,
count(distinct hotel_state) as total_states
from cte1
group by customer_id
having count(distinct hotel_state)>=3;

--6 calculate the occupancy rate (percentage of rooms booked in respect of total rooms available) for each hotel for each month

select * from hotel_bookings;

with cte1 as(
select
    hotel_id,
    DATEPART(month, stay_start_date) as stay_month,
    count(booking_id) as total_rooms_booked,
    sum(number_of_nights) as total_room_nights
from hotel_bookings
group by hotel_id, DATEPART(month, stay_start_date)
),
cte2 as(
    select 
    id,
    capacity_no_of_rooms
    from hotel_names
)
select
    hotel_id,
    c1.stay_month,
    c1.total_rooms_booked,
    c1.total_room_nights,
    c2.capacity_no_of_rooms,
    (c1.total_room_nights*100.0)/(c2.capacity_no_of_rooms*30) as percentage_of_rooms_booked
    from cte1 c1 inner join cte2 c2 on c1.hotel_id=c2.id;

--inner join hotel_names hn on hb.hotel_id=hn.id
--7 for each hotel find dates when they were fully occupied
--check

select * from hotel_bookings;

with cte as(
select 
    hotel_id,
    stay_start_date,
    count(*) as no_of_bookings
    from hotel_bookings hb
    group by hotel_id, stay_start_date
)
select c1.*, hn.capacity_no_of_rooms
from cte c1
inner join hotel_names hn on c1.hotel_id=hn.id
where c1.no_of_bookings=hn.capacity_no_of_rooms;

--8 which booking channel has generated highest sales for each hotel in each month

select * from hotel_bookings;

with cte1 as(
select 
    hotel_id,
    booking_channel,
    datename(month,booking_date) as booking_month,
    sum(number_of_nights*per_night_rate) as revenue
from hotel_bookings
group by hotel_id, booking_channel,datename(month,booking_date)
--order by hotel_id, booking_channel,booking_month
),
cte2 as(
select hotel_id,
booking_channel,
booking_month,
DENSE_RANK() over(partition by hotel_id order by revenue desc) as rnk
from cte1
)
select hotel_id, booking_channel, booking_month
from cte2 where rnk=1;

--9 find percent share of number of bookings by each booking channel

select * from hotel_bookings;

with cte1 as(
    select count(distinct booking_id) as total_bookings
    from hotel_bookings
),
cte2 as(
select booking_channel,
count(distinct booking_id) as total_channel_bookings
from hotel_bookings
group by booking_channel
)
select c2.booking_channel, (c2.total_channel_bookings*100.0/c1.total_bookings) as percentage_share
from cte1 c1 inner join cte2 c2
on 1=1;

--10 for each hotel find the total revenue generated by millenials(born between 1980 and 1996) and  gen z (born after 1996)

select * from hotel_bookings;

with cte as(
select 
    hb.hotel_id,
    hb.number_of_nights,
    hb.per_night_rate,
    DATEPART(year,hcu.dob) as customer_birth_year
from hotel_bookings hb
inner join hotel_customers hcu on hb.customer_id=hcu.customer_id
)
select 
    hotel_id,
    sum(case when customer_birth_year BETWEEN '1980' and '1996' THEN number_of_nights*per_night_rate else 0 end) as millenial_revenue,
    sum(case when customer_birth_year > '1996' THEN number_of_nights*per_night_rate else 0 end) as genz_revenue
from cte
group by hotel_id
order by hotel_id;

--11 For each hotel find  the average stay duration

select * from hotel_bookings;

select hotel_id, avg(number_of_nights*1.0) as avg_duration
from hotel_bookings
group by hotel_id;

--12 find the average number of days customers book in advance for each hotel.

select * from hotel_bookings;

with cte as(
select hotel_id, DATEDIFF(day,booking_date,stay_start_date) as advance_days
from hotel_bookings
)
select hotel_id, avg(advance_days) as avg_advance_days
from cte
group by hotel_id;

--13 find customers who never did any booking

select hcu.customer_id
from hotel_customers hcu 
left join hotel_bookings hb on hcu.customer_id = hb.customer_id
where hb.customer_id is null;

--14 find customers who stayed in atleast 3 distinct hotel in a same month. Display  customer name , month and no of bookings.

select * from hotel_bookings;

select
    customer_id,
    datepart(month,booking_date) as stay_month,
    count(distinct hotel_id) as hotel_count
from hotel_bookings hb
group by customer_id,datepart(month,booking_date)
having count(distinct hotel_id)>=3
order by hotel_count desc;
