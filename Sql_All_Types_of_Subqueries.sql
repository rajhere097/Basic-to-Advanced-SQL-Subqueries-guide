## Sql subqueries
use internshala;

describe employees;

alter table employees 
add date_hire date;

set sql_safe_updates = 0;
update employees
set date_hire = str_to_date(hire_date, '%Y-%m-%d');

alter table employees 
drop hire_date;
select * from employees;
--------------------------

## single row subquery

/* In single-row subqueries, we mostly use aggregate functions like:

MAX() → maximum value

MIN() → minimum value

AVG() → average value

SUM() → total

COUNT() → row count

Since these aggregates return only one value, we can compare that value with columns in the outer query using operators like:

= (equal to)

> (greater than)

< (less than)

>=, <=, <>

*/


# Task 1: Find employees who earn more than the average salary

select employee_id, concat(first_name, ' ', last_name) as joinednames, salary from employees where salary >
(select avg(salary) as AvgSalary from employees);

# Task 2: Find employees who joined before the earliest hire date in their company

select employee_id, date_hire from employees where date_hire =
(select min(date_hire) as MinDate from employees);


# Task 3 Find employees who work in the same department as Neena Kochhar

select  concat(first_name, ' ', last_name) as names from employees
where department_id =
(select department_id from employees
where concat(first_name, ' ', last_name) = 'Neena Kochhar')
and concat(first_name, ' ', last_name) != 'Neena Kochhar';

# Task 4: Find employees who earn more than the average salary of their own department

select f.employee_id, f.salary, f.department_id from employees f
where f.salary >
(select avg(e.salary) as avgsalary
from employees e
where e.department_id = f.department_id);


# Task 5 Task: Find employees who earn more than the average salary of their job role (job_id).

select f.employee_id, f.salary, f.job_id from employees f
where f.salary >
(select avg(e.salary) as avgsalary
from employees e
where e.job_id = f.job_id);

# Task 6 Find employees whose salary is higher than the salary of their manager.

select e.employee_id, m.manager_id, e.salary, m.salary
from employees e join employees m
on e.manager_id = m.employee_id 
where e.salary > m.salary;

# Task 7: Find employees who were hired before their manager.

select e.employee_id, m.manager_id, e.date_hire, m.date_hire
from employees e join employees m
on e.manager_id = m.employee_id
where e.date_hire < m.date_hire;


/* Task 8 Find the employees who earn more than the average salary of their department,
 and display their name, salary, and department name. */
 
select f.employee_id, f.first_name, f.department_id
from employees f where f.salary >
(select avg(e.salary) as avgsalary
from employees e
where e.department_id = f.department_id);

# Task 9 Find the employees who have the highest salary in their department.
select f.employee_id, f.salary from employees f where f.salary =
(select max(e.salary) as maxsalary
from employees e
where e.department_id = f.department_id);


# Task 10 : Find the second highest salary in the company in the same department
select j.employee_id, j.salary, j.department_id
from employees j where j.salary =
(select max(f.salary) as second_high
from employees f where f.department_id = j.department_id
and f.salary <
(select max(e.salary) as first_high
from employees e
where e.department_id = f.department_id));


#Task 11 Find all passengers who paid a fare higher than the average fare of their passenger class (pclass).

select * from titanic;

select e.passenger_no, e.fare
from titanic e where e.fare >
(select avg(fare) as avgfare
from titanic t
where t.pclass = e.pclass);

#Task 12 Find all pairs of passengers who belong to the same passenger class (pclass) and also embarked from the same town

select t.passenger_no, e.passenger_no
from titanic t join titanic e
on t.pclass = e.pclass
and t.embark_town = e.embark_town
where t.passenger_no <> e.passenger_no;

#Task 13 Find the passengers whose fare is equal to the maximum fare paid in each passenger class (pclass).

select e.passenger_no, e.fare
from titanic e where e.fare =
(select max(fare) as maxfare
from titanic t
where t.pclass = e.pclass);


/* Task 14 Find all passengers who traveled in the same passenger class as passengers who survived.
 Display their names, class, and survival status */
 
select passenger_no, first_name, pclass, survived
from titanic where pclass in
(select pclass
from titanic
where survived = 1);

# Task 15 Find the passengers who paid a fare greater than the overall average fare of passengers who survived.

select passenger_no, fare from titanic where fare >
(select avg(fare) as avgfare
from titanic
where survived = 1);


/* Task 16 Display passengers who embarked from the same port as at least one survivor. 
Show passenger name, embark_town, and their survival status. */

select passenger_no, first_name, embark_town, survived from titanic
where embark_town in
(select distinct embark_town
from titanic
where survived = 1);

/* Task 17 Find passengers whose fare is higher than ANY fare paid by first-class passengers. Display their name, class, and fare. */

select passenger_no, first_name, class, fare from titanic
where fare > Any
(select fare
from titanic
where pclass = 1);

/* Task 18 Identify passengers whose age is greater than ALL ages of passengers who didn't survive. 
Show their name, age, and survival status. */

select passenger_no, first_name, age, survived from titanic
where age > All
(select age
from titanic
where survived = 0);

# Task 19 Find passengers who have the same combination of class and embark_town as any survivor. Display all their details.

select * from titanic
where (pclass, embark_town) in
(select pclass, embark_town
from titanic
where survived = 1);


/* Task 20 List all passengers whose deck is NOT the same as any deck occupied by survivors. 
Show passenger name, deck, and survival status. */

select passenger_no, first_name, deck, survived from titanic
where deck not in
(select deck 
from titanic 
where survived = 1);


/* Task 21 Find passengers for whom there are NO other passengers with the same sex and higher fare who survived. 
Display name, sex, fare, and survival status. */

select * from titanic;

select e.passenger_no, e.first_name, e.sex, e.fare, e.survived
from titanic e where not exists
(select t.passenger_no
from titanic t
where t.sex = e.sex and t.fare > e.fare
and t.survived = 1);


/* Task 22 Create a query that shows passenger details only for those classes where the average age of survivors is greater than 30.
 Use a subquery in the FROM clause. */
 
select * from titanic where pclass in
(select pclass
from titanic
where survived = 1
group by pclass
having avg(age) > 30);


/* Task 23 Find all Netflix originals whose IMDB score is higher than the average IMDB score of all titles in their respective genre. 
Display the title, genre, IMDB score, and the genre average. */

select * from netflix_originals;

select f.title, f.genreid, f.imdbscore from
netflix_originals f where f.imdbscore >
(select avg(imdbscore)
from netflix_originals n
where n.genreid = f.genreid);

/* task 24 Display titles where there EXISTS at least one other title in 
the same language that has both a higher IMDB score AND longer runtime. Show title, language, runtime, and IMDB score. */

select f.title, f.language, f.runtime, f.imdbscore
from netflix_originals f where exists
(select title
from netflix_originals n
where n.language = f.language
and n.imdbscore > f.imdbscore
and n.runtime > f.runtime);

/* Task 25 Find the top 2 highest IMDB rated titles for each genre. Display genre, title, IMDB score, 
and rank within genre. Use only subqueries. */

with score as
(select title, genreid, imdbscore,
rank() over(partition by genreid order by imdbscore desc) as rn
from netflix_originals)
select * from score
where rn in (1,2);

/* Task 26 Find languages where there are NO titles 
with IMDB score below 6.0 that also have runtime longer than the average runtime of titles with IMDB score
 above 8.0 in the same language. Display language and count of titles. */

select e.language, count(title) as C
from netflix_originals e where not exists
(select f.imdbscore
from netflix_originals f where f.language = e.language and f.imdbscore < 6 and f.runtime >
(select avg(n.runtime)
from netflix_originals n
where n.imdbscore > 8
and n.language = f.language))
group by e.language;


/* Task 27 Find the top 3 longest runtime titles in each language, only among those with IMDB score ≥ 7.0.
Display Language, Title, Runtime, IMDBScore. */

with top3 as
(select title, language, runtime, imdbscore,
rank() over(partition by language order by runtime desc) as rn
from netflix_originals
where imdbscore >=7)
select * from top3
where rn in (1,2,3);

