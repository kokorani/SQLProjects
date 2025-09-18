select * from athlete_events;

--1 which team has won the maximum gold medals over the years

select top 1 team, count(distinct event) as total_medals
from athletes a1 inner join athlete_events a2
on a1.id=a2.athlete_id
where medal='Gold'
group by team
order by total_medals desc;

--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver

with cte as(
select team, year, count(distinct event) as silver_medals
from athletes a1 inner join athlete_events a2
on a1.id=a2.athlete_id
where medal='Silver'
group by team, year),
--order by team, year, silver_medals),
cte1 as(
select team, silver_medals, year, rank() over(partition by team order by silver_medals desc) as rn
from cte)
select team, sum(silver_medals) as total_silver_medals, max(case when rn=1 then year end) as year_of_max_silver
from cte1
group by team;


--3 which player has won maximum gold medals amongst the players which have won only gold medal (never won silver or bronze) over the years

with cte as(
select name, medal
from athlete_events ae
inner join athletes a
on ae.athlete_id=a.id)
select top 1 name,count(1) as no_of_gold_medals
from cte
where name not in(select distinct name from cte where medal in('Silver','Bronze'))
and medal='Gold' 
group by name
order by no_of_gold_medals desc;

--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names

with cte as(
select year, name, count(1) as golds_won_in_that_year
from athlete_events a1
inner join athletes a2
on a1.athlete_id = a2.id
where medal='Gold'
group by year, name)
--order by year)
select year,golds_won_in_that_year, STRING_AGG(name,',') as players
from(
    select *, rank() over(partition by year order by golds_won_in_that_year desc) as rn
from cte) a where rn=1
group by year, golds_won_in_that_year;

--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

with cte as(
select medal,year,event,
rank() over(partition by medal order by year) as rn
from 
athlete_events ae inner join athletes a
on ae.athlete_id=a.id
where team='India' and medal!='NA')
select distinct *
from cte where rn=1

--6 find players who won gold medal in summer and winter olympics both

select name
from athlete_events ae 
inner join athletes a
on ae.athlete_id=a.id
where medal='Gold'
group by name
having count(distinct season)=2;

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.

select name, year
from athlete_events ae
inner join athletes a
on ae.athlete_id=a.id
where medal!='NA'
group by name,year
having count(distinct medal)=3;

--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.

with cte1 as(
select name, event, year
from athlete_events ae inner JOIN
athletes a on ae.athlete_id=a.id
where year>=2000 and medal='Gold' and season='Summer'
group by name, event, year),
cte2 as(
    select *, lag(year,1) over(partition by name,event order by year) as prev_year, 
    lead(year,1) over(partition by name,event order by year) as next_year
    from cte1
)
select * from cte2 where year=prev_year+4 and year=next_year-4













