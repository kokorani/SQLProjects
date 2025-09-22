--q1 Show unique birth years from patients and order them by ascending.

select 
	distinct year (birth_date) as birth_year
    from patients
    order by year (birth_date)

--q2 Show unique first names from the patients table which only occurs once in the list.
-- For example, if two or more people are named 'John' in the first_name column then don't include their name in the output list. 
-- If only 1 person is named 'Leo' then include them in the output.

select 
	distinct first_name
    from patients
    group by first_name
    having count(*)=1

--q3 Show patient_id and first_name from patients where their first_name start and ends with 's' and is at least 6 characters long.

select 
	patient_id, first_name
    from patients
    where LOWER(first_name) like 's%s' and len(first_name)>=6

--q4 Show patient_id, first_name, last_name from patients whos diagnosis is 'Dementia'.
-- Primary diagnosis is stored in the admissions table.

select 
	p.patient_id, first_name, last_name
    from patients p
    inner join admissions a
    on p.patient_id=a.patient_id
    where a.diagnosis = 'Dementia'

--q5 Display every patient's first_name. Order the list by the length of each name and then by alphabetically.

select 
	first_name
    from patients 
    order by len(first_name),first_name

--q6 Show the total amount of male patients and the total amount of female patients in the patients table. 
-- Display the two results in the same row.

select 
	sum(case when gender='M' then 1 else 0 end)as male_count,
    sum(case when gender='F' then 1 else 0 end)as female_count
    from patients

--q7 Show first and last name, allergies from patients which have allergies to either 'Penicillin' or 'Morphine'.
-- Show results ordered ascending by allergies then by first_name then by last_name.

select 
	first_name,
    last_name,
    allergies
    from patients
    where allergies in('Penicillin','Morphine')
    order by allergies, first_name, last_name

--q8 Show patient_id, diagnosis from admissions. Find patients admitted multiple times for the same diagnosis.

select 
	patient_id,
    diagnosis
    from admissions
    group by patient_id,diagnosis
    having count(*)>1

--q9 Show the city and the total number of patients in the city. Order from most to least patients and then by city name ascending.

select 
	city,
    count(*) as num_patients
    from patients
    group by city
    order by num_patients desc ,city

--q10 Show first name, last name and role of every person that is either patient or doctor. The roles are either "Patient" or "Doctor"
-- STAR

select 
	first_name,
    last_name,
    'Patient' as role
    from patients
    union all 
select
	first_name,
    last_name,
    'Doctor' AS role
    from doctors

--q11 Show all allergies ordered by popularity. Remove NULL values from query.

select 
	allergies,
    count(*) as total_diagnosis
    from patients
    where allergies is not null 
    group by allergies
    order by total_diagnosis desc

--q12 Show all patient's first_name, last_name, and birth_date who were born in the 1970s decade. 
-- Sort the list starting from the earliest birth_date.

select 
	first_name,
    last_name,
    birth_date
    from patients
    where year(birth_date)>=1970 and year(birth_date)<1980
    order by birth_date

--q13 We want to display each patient's full name in a single column. Their last_name in all upper letters must appear first, 
-- then first_name in all lower case letters. Separate the last_name and first_name with a comma. 
-- Order the list by the first_name in decending order. EX: SMITH,jane

select 
	concat(upper(last_name),',',lower(first_name))
    from patients
    order by first_name desc
  

--q14 Show the province_id(s), sum of height; where the total sum of its patient's height is greater than or equal to 7,000.
-- STAR: Need to use sum(height) in having as select runs after having

select 
	province_id,
    sum(height) as sum_height
    from patients
    group by province_id
    having sum(height)>7000

--q15 Show the difference between the largest weight and smallest weight for patients with the last name 'Maroni'

select 
	max(weight)-min(weight) as weight_delta
    from patients
    where last_name = 'Maroni'

--q16 Show all of the days of the month (1-31) and how many admission_dates occurred on that day. 
-- Sort by the day with most admissions to least admissions.

select 
	day(admission_date) as day_number,
    count(*) as number_of_admissions
    from admissions
    group by day(admission_date)
    order by number_of_admissions desc

--q17 Show all columns for patient_id 542's most recent admission_date.

with cte as(
select 
	*
    from admissions
    where patient_id='542' 
  )
  select * from cte
  where admission_date = (select max(admission_date) from cte)

--q18 Show patient_id, attending_doctor_id, and diagnosis for admissions that match one of the two criteria:
--1. patient_id is an odd number and attending_doctor_id is either 1, 5, or 19.
--2. attending_doctor_id contains a 2 and the length of patient_id is 3 characters.

select
	patient_id,
    attending_doctor_id,
    diagnosis
    from admissions
    where (patient_id%2!=0 and attending_doctor_id in('1','5','19')) or (attending_doctor_id like '%2%' and len(patient_id)=3)
    
--q19 Show first_name, last_name, and the total number of admissions attended for each doctor.
-- Every admission has been attended by a doctor.

select
	d.first_name,
    d.last_name,
    count(*) as admissions_total
    from admissions a 
    inner join doctors d
    on a.attending_doctor_id=d.doctor_id
    group by first_name,last_name

--q20 For each doctor, display their id, full name, and the first and last admission date they attended.

select
	d.doctor_id,
	concat(d.first_name,' ', d.last_name) as full_name,
    min(admission_date) as first_admission_date, 
    max(admission_date) as last_admission_date
    from admissions a 
    inner join doctors d
    on a.attending_doctor_id=d.doctor_id
    group by d.doctor_id

--q21 Display the total amount of patients for each province. Order by descending.

select
	pn.province_name,
    count(p.patient_id) as patient_count
    from province_names pn inner join patients p 
    on pn.province_id = p.province_id
    group by pn.province_name
    order by patient_count desc
	
--q22 For every admission, display the patient's full name, their admission diagnosis, 
-- and their doctor's full name who diagnosed their problem.

select
	concat(p.first_name,' ',p.last_name),
    a.diagnosis,
    concat(d.first_name,' ',d.last_name)
    from patients p join admissions a on p.patient_id = a.patient_id
    join doctors d on a.attending_doctor_id=d.doctor_id

--q23 display the first name, last name and number of duplicate patients based on their first name and last name.
--Ex: A patient with an identical name can be considered a duplicate

select
	first_name,
    last_name,
    count(*) as num_of_duplicates
    from patients 
    group by first_name, last_name
    having num_of_duplicates>=2

--q24 Display patient's full name, height in the units feet rounded to 1 decimal, weight in the unit pounds rounded to 0 decimals,
-- birth_date, gender non abbreviated.
--Convert CM to feet by dividing by 30.48. Convert KG to pounds by multiplying by 2.205.

select
	concat(first_name,' ',last_name)as patient_name,
    round(height/30.48,1),
    round(weight*2.205,0),
    birth_date,
    case when gender='M' then 'Male' else 'Female' end as gender_type
    from patients 

--q25 Show patient_id, first_name, last_name from patients whose does not have any records in the admissions table. 
--(Their patient_id does not exist in any admissions.patient_id rows.)

select
	p.patient_id,
    p.first_name,
    p.last_name
    from patients p   
    left join admissions a
	on p.patient_id=a.patient_id
    where a.patient_id is null

--q26 Display a single row with max_visits, min_visits, average_visits where the maximum, 
--minimum and average number of admissions per day is calculated. Average is rounded to 2 decimal places.

with cte as(
select
	admission_date, 
	count(patient_id)as count_of_visits
    from admissions
    group by admission_date
  )
  select max(count_of_visits) as max_visits,
  min(count_of_visits) as min_visits,
  round(avg(count_of_visits),2) as average_visits
  from cte

--q27 Show all of the patients grouped into weight groups. Show the total amount of patients in each weight group.
-- Order the list by the weight group decending.
-- For example, if they weight 100 to 109 they are placed in the 100 weight group, 110-119 = 110 weight group, etc.

--STAR

select
	count(*) as patients_in_group,
    floor(weight/10)*10 as weight_group
    from patients
    group by floor(weight/10)*10
    order by weight_group desc

--q28 Show patient_id, weight, height, isObese from the patients table. Display isObese as a boolean 0 or 1.
-- Obese is defined as weight(kg)/(height(m)2) >= 30. weight is in units kg. height is in units cm.

select
	patient_id,
    weight,
    height,
    case when (weight/((height/100.0)*(height/100.0)))>=30 then 1 else 0 end as isObese
    from patients

-- If you divide an int by an int you will get an int. Dividing an int by a float will return a float.
-- That's why you have to divide by 100.0 and not 100.
-- Use CAST(variable_name AS FLOAT) function if you are dividing by two variables.

--q29 Show patient_id, first_name, last_name, and attending doctor's specialty.
-- Show only the patients who has a diagnosis as 'Epilepsy' and the doctor's first name is 'Lisa'
-- Check patients, admissions, and doctors tables for required information.

select
	p.patient_id,
    p.first_name,
    p.last_name,
    d.specialty
    from patients p inner join admissions a on p.patient_id=a.patient_id
    inner join doctors d on a.attending_doctor_id=d.doctor_id
    where a.diagnosis='Epilepsy' and d.first_name='Lisa'
    
--q30 All patients who have gone through admissions, can see their medical documents on our site. 
-- Those patients are given a temporary password after their first admission. Show the patient_id and temp_password.
-- The password must be the following, in order: 1. patient_id 2. the numerical length of patient's last_name 3. year of patient's birth_date

select
	distinct p.patient_id,
    concat(p.patient_id,len(p.last_name),year(birth_date)) as temp_password
    from patients p inner join admissions a on p.patient_id=a.patient_id

--q31 Each admission costs $50 for patients without insurance, and $10 for patients with insurance. 
-- All patients with an even patient_id have insurance.
-- Give each patient a 'Yes' if they have insurance, and a 'No' if they don't have insurance. 
-- Add up the admission_total cost for each has_insurance group.

with cte as(
select
	case when patient_id%2==0 then 'Yes' else 'No' end as has_insurance,
    count(*) as count_of_patients
    from admissions
    group by case when patient_id%2==0 then 'Yes' else 'No'end 
  )
  select 
  	has_insurance,
    case when has_insurance='No' then count_of_patients*50 else count_of_patients*10 end as cost_after_insurance
    from cte

--q32 Show the provinces that has more patients identified as 'M' than 'F'. Must only show full province_name

with cte as(
select 
	pn.province_name,
    sum(case when gender='M' then 1 else 0 enD) as male_patients,
    sum(case when gender='F' then 1 else 0 enD) as female_patients
    from patients p inner join province_names pn on p.province_id=pn.province_id
    group by pn.province_name
  )
  select province_name
 from cte
 where male_patients>female_patients

 --q33 We are looking for a specific patient. Pull all columns for the patient who matches the following criteria: 
 --First_name contains an 'r' after the first two letters. Identifies their gender as 'F'. Born in February, May, or December
-- Their weight would be between 60kg and 80kg. Their patient_id is an odd number. They are from the city 'Kingston'

select 
	*
    from patients
    where first_name like '__r%' and 
    gender='F'and month(birth_date) in(2,5,12)and weight between 60 and 80 and 
    patient_id%2!=0 and city='Kingston'

--q34 Show the percent of patients that have 'M' as their gender. Round the answer to the nearest hundreth number and in percent form.

select 
	round(sum(case when gender='M' then 1 else 0 end)*100.0/count(*),2)||'%'
    from patients

--q35 For each day display the total amount of admissions on that day. Display the amount changed from the previous date.

with cte as(
select 
	admission_date,
    count(*) as admission_day
    from admissions
    group by admission_date
  )
  select
  	admission_date,
    admission_day,
    admission_day - lag(admission_day,1) over(order by admission_date) as admission_count_change
    from cte
  
--q36 Sort the province names in ascending order in such a way that the province 'Ontario' is always on top.

with cte as(
select 
	province_name,
    case when province_name='Ontario' then 0 else 1 end as sort_flag
    from province_names
  )
  select province_name
  from cte
  order by sort_flag,province_name

--q37 We need a breakdown for the total amount of admissions each doctor has started each year. 
-- Show the doctor_id, doctor_full_name, specialty, year, total_admissions for that year.

select 
	doctor_id,
    concat(first_name,' ',last_name),
    specialty,
    year(admission_date) as selected_year,
    count(*)
    from admissions a inner join doctors d on a.attending_doctor_id=d.doctor_id 
    group by doctor_id,
    concat(first_name,' ',last_name),
    specialty,
    year(admission_date)

