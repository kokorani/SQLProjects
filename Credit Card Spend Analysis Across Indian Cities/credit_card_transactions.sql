select * from credit_card_transcations;

--1 write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

with cte1 as(
select sum(cast(amount as bigint)) as total_spend
from credit_card_transcations),
cte2 as(
select city, sum(cast(amount as bigint)) as city_cc_spends
from credit_card_transcations
group by city)
select top 5
city, city_cc_spends, round((city_cc_spends*100.0)/total_spend,2) as percent_contribution
from cte1
cross join cte2
order by city_cc_spends desc;

--2 write a query to print highest spend month and amount spent in that month for each card type

select * from credit_card_transcations;

with cte as(
select card_type,datepart(year, transaction_date) as yt, datepart(month, transaction_date) as mt, sum(amount) as card_type_spend
from credit_card_transcations
group by card_type, datepart(year, transaction_date), datepart(month, transaction_date)
--order by card_type, card_type_spend
)
select * from (select *, rank() over(partition by card_type order by card_type_spend desc) as rn from cte) a
where rn=1

--3 write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)

with cte as(
select *, sum(amount) over(partition by card_type order by transaction_date, transaction_id) as total_spend
from credit_card_transcations
--order by card_type, total_spend desc
)
select * from (select *, rank() over(partition by card_type order by total_spend) as rn
from cte where total_spend>=1000000) a where rn=1;

--4 write a query to find city which had lowest percentage spend for gold card type

with cte1 as(
select city, sum(amount) as total_city_spend
from credit_card_transcations
group by city),
cte2 as(
select city, card_type, sum(amount) as gold_cc_spend
from credit_card_transcations
where card_type='Gold'
group by city, card_type
)
select top 1 cte1.city, (gold_cc_spend*100.0/total_city_spend) as percent_spend from cte1 inner join cte2 on cte1.city=cte2.city
order by percent_spend asc;

--5 write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

with cte1 as(
select city, exp_type, sum(amount) as total_exp
from credit_card_transcations
group by city, exp_type),
--order by city, exp_type),
cte2 as(
select city , exp_type,
rank() over(partition by city order by total_exp asc) as r_asc ,
rank() over (partition by city order by total_exp desc) as r_desc
from cte1)
select city,
max(case when r_desc=1 then exp_type end) as highest_expense_type,
max(case when r_asc=1 then exp_type end) as lowest_expense_type
from cte2
group by city;

--6 write a query to find percentage contribution of spends by females for each expense type

select exp_type,
sum(case when gender='F' then amount else 0 end)*1.0/sum(amount) as percentage_female_contribution
from credit_card_transcations
group by exp_type
order by percentage_female_contribution desc;

--7 which card and expense type combination saw highest month over month growth in Jan-2014

with cte1 as(
select card_type, exp_type,
datepart(year,transaction_date) as yt,
datepart(month,transaction_date) as mt,
sum(amount) as total_spend
from credit_card_transcations
group by card_type, exp_type,
datepart(year,transaction_date),
datepart(month,transaction_date)
),
cte2 as(
    select card_type, exp_type, yt, mt, total_spend,
    lag(total_spend,1) over(partition by card_type,exp_type order by yt, mt) as prev_month_spend
    from cte1
)
select top 1*, (total_spend-prev_month_spend) as mom_growth
from cte2
where prev_month_spend is not null and yt=2014 and mt=1
order by mom_growth desc;

--8 during weekends which city has highest total spend to total no of transcations ratio 

select * from credit_card_transcations;

select top 1 city, sum(amount)*1.0/count(1) as ratio
from credit_card_transcations
where datepart(weekday, transaction_date) in (1,7)
group by city
order by ratio desc

--9 which city took least number of days to reach its 500th transaction after the first transaction in that city

with cte as(
select *, row_number() over(partition by city order by transaction_date, transaction_id) as rn
from credit_card_transcations)
select top 1 city, DATEDIFF(day, min(transaction_date), max(transaction_date)) as datediff1
from cte
where rn=1 or rn=500
group by city
having count(1)=2
order by datediff1


