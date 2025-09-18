CREATE TABLE portal (
    portal_id INT PRIMARY KEY,
    portal_code VARCHAR(10),
    portal_name VARCHAR(50)
);

INSERT INTO portal (portal_id, portal_code, portal_name) VALUES
(1, 'MPR', 'My Perfect Resume'),
(2, 'RN',  'Resume Now'),
(3, 'ZETY','Zety'),
(4, 'LC',  'Live Career'),
(5, 'GEN', 'Resume Genius'),
(6, 'HELP','Resume Help');

CREATE TABLE user_registration (
    user_id BIGINT,
    portal_id INT,
    registration_datetime DATETIME,
    subscription_flag CHAR(1),
    subscription_datetime DATETIME NULL
);

select * from user_registration;

delete from user_registration;
INSERT INTO user_registration VALUES
-- User 1001 registers on 2 portals, subscribes only on RN
(1001, 2, '2024-01-05 09:27:44', 'Y', '2024-01-06 10:00:00'),
-- User 1002 registers on ZETY and GEN, subscribes on both
(1002, 3, '2024-02-15 14:07:11', 'Y', '2024-02-15 15:30:00'),

-- User 1003 registers on RN and MPR, no subscriptions
(1003, 2, '2024-03-10 08:00:00', 'N', NULL),

-- User 1004 registers only once, subscribed
(1004, 4, '2024-05-19 09:45:00', 'Y', '2024-05-20 10:00:00'),

-- User 1005 registers only once, no subscription
(1005, 3, '2024-12-10 12:00:00', 'Y', '2024-12-15 12:00:00'),

-- User 1006 registers on 3 portals, mixed subscription
(1006, 1, '2024-07-01 11:00:00', 'Y', '2024-07-02 09:00:00'),

-- User 1007 registers on RN in Dec 2024, subscribes in Jan 2025 (boundary case)
(1007, 2, '2024-12-31 23:59:59', 'Y', '2025-01-01 00:15:00');

insert into user_registration values 
(1008, 4, '2024-03-15 23:59:59', 'N', NULL),
(1009, 2, '2025-01-15 23:59:59', 'Y', '2025-02-01 00:15:00');

insert into user_registration values
(1010, 3, '2024-02-10 14:00:00', 'N', NULL),
(1011, 5, '2024-03-01 00:00:00', 'Y', '2024-03-02 09:00:00'),
(1012, 1, '2024-04-01 09:30:00', 'N', NULL),
(1013, 2, '2024-07-05 14:00:00', 'N', NULL),
(1014, 5, '2024-08-10 18:00:00', 'Y', '2024-08-11 08:00:00'),
(1015, 2, '2024-01-20 23:59:59', 'Y', '2025-01-01 00:15:00');

select * from user_registration;

CREATE TABLE resume_doc (
    resume_id INT PRIMARY KEY,
    user_id BIGINT,
    date_created DATETIME,
    experience_years INT
);

INSERT INTO resume_doc VALUES
-- User 1001: Multiple resumes across portals
(2001, 1001, '2024-01-07 11:00:00', 2),
(2002, 1001, '2024-02-12 12:00:00', 3),

-- User 1002: Multiple resumes, high exp
(2003, 1002, '2024-02-16 10:00:00', 5),
(2004, 1002, '2024-03-05 12:00:00', 7),

-- User 1003: No resumes (edge case)

-- User 1004: Single resume, big experience
(2005, 1004, '2024-05-21 11:00:00', 12),

-- User 1005: Has resumes but no subscription
(2006, 1005, '2024-06-15 09:00:00', 0),
(2007, 1005, '2024-06-20 10:00:00', 1),

-- User 1006: Resumes before and after subscription
(2008, 1006, '2024-07-01 15:00:00', 8),
(2009, 1006, '2024-08-12 19:00:00', 9),

-- User 1007: Future-year resume
(2010, 1007, '2025-01-02 10:00:00', 20);

INSERT INTO resume_doc VALUES
-- User 1001: Multiple resumes across portals
(2011, 1001, '2025-01-07 11:00:00', 3),
(2012, 1001, '2025-01-08 11:00:00', 3);

select * from portal;
select * from user_registration;
select * from resume_doc;

--1 what is the count of registrations every month on the 'Resume Now' portal for 2024?
--Output: Month,Registration (12 rows total)

select 
    datepart(month from registration_datetime) as month,
    count(registration_datetime) as total_registrations
from user_registration
where datepart(year from registration_datetime)=2024 and portal_id = (
    select portal_id from portal where portal_name='Resume Now'
)
group by datepart(month from registration_datetime) 

-- 1 Alt approach AB:
select MONTH(registration_datetime) as registered_month, count(*) as no_of_registrations
from portal p inner JOIN user_registration u
on p.portal_id=u.portal_id
where p.portal_name='Resume Now' and YEAR(registration_datetime)=2024
group by MONTH(registration_datetime)

--2 which portal has the highest subscription rate for users registered in the last 30 days?
--Subscription Rate = Total Subscriptions/ Total Registrations
--Output: portal_name, Subscription_rate (1 row only)

select * from portal;
select * from user_registration;
select * from resume_doc;

select 
top 1
    p.portal_name,
    count(case when subscription_flag='Y' then 1 end)*100.0 / count(*) as subscription_rate
from portal p
inner join user_registration u
on p.portal_id=u.portal_id 
--where registration_datetime>=dateadd(day,-30,getdate())
group by portal_name
order by subscription_rate desc

-- 2 Alt approach AB:

select
top 1
    p.portal_name,
    count(*) as total_registrations,
    count(subscription_datetime) as total_subscription,
    count(subscription_datetime)*100.0/count(*) as subscription_rate -- count does not count null values
from user_registration u
inner join portal p on p.portal_id=u.portal_id
--where registration_datetime>=dateadd(day,-30,getdate())
group by p.portal_name
order by subscription_rate desc

--note when there are 2 conditions in where, see if something can be moved to case when

--3 how many registered users create less than 3 resumes?
--Output: less_than_3_resumes_created_users (a single number)

select * from portal;
select * from user_registration;
select * from resume_doc;

select 
    u.user_id,
    count(r.resume_id) as total_resume
from user_registration u
left join resume_doc r
on r.user_id=u.user_id
group by u.user_id
having count(r.resume_id)<3

--4 create a list of users who subscribed in 2024 on the 'Zety' portal and get the experience_years on their first resume
--output: user_id, experience_years

select * from portal;
select * from user_registration;
select * from resume_doc;

with cte as(
select 
    u.user_id,
    r.experience_years,
    r.date_created
    from user_registration u 
    inner join portal p
    on u.portal_id=p.portal_id
    inner join resume_doc r on u.user_id=r.user_id
    where p.portal_name='Zety' and YEAR(subscription_datetime)=2024
)
select user_id,experience_years
from cte
where date_created = (select min(date_created) from cte) and experience_years>0

--4 Alt solution AB

with cte as(
select 
    u.user_id,
    r.experience_years,
    r.date_created,
    row_number() over(partition by u.user_id order by date_created) as rnk
    from user_registration u 
    inner join portal p
    on u.portal_id=p.portal_id
    inner join resume_doc r on u.user_id=r.user_id
    where p.portal_name='Zety' and YEAR(subscription_datetime)=2024
)
select 
    user_id,
    experience_years
    from cte
where rnk=1 and experience_years>0
