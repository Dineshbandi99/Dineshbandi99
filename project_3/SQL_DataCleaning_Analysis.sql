
-----Data Engineering Project_3 Questions---------
---------------------XXXXXXXXXXXXXXXXXXX--------------------
--Q1. Handle foreign characters---
--while loading data from kaggle to SQl server foreign characters are replaced with other characters. 
--So, this can be handled by changing particular column datatype from varchar to nvarchar.
--Not sure how to change datatypes but in this project it is done by creating table with same columns and datatypes which we have in kaggle dataset.
--then we have to load data into table created in SQL server.

---------------------XXXXXXXXXXXXXXXXXXXX--------------------

--Q2.Remove duplicates
select * from netflix_raw 
where CONCAT(UPPER(title),type) in (
select CONCAT(UPPER(title),type) from netflix_raw
group by UPPER(title),type
having count(*) > 1
)
order by title

select * from 
(select *
,ROW_NUMBER() over(partition by title, type order by show_id) as rnk from netflix_raw) A
where A.rnk = 1

------------XXXXXXXXXXXXXXXXXX---------------------
--Q3.New table for listed in, director, country,cast
--drop table netflix_directors
select show_id, trim(value) as director
into netflix_directors
from netflix_raw
CROSS APPLY string_split(director, ',')

--drop table netflix_genre
select show_id, trim(value) as genre
into netflix_genre
from netflix_raw
CROSS APPLY string_split(listed_in,',')

--drop table netflix_country
select show_id, trim(value) as country
into netflix_country
from netflix_raw
CROSS APPLY string_split(country,',')

--drop table netflix_cast
select show_id, trim(value) as cast
into netflix_cast
from netflix_raw
CROSS APPLY string_split(cast,',')

-----------------XXXXXXXXXXXXXX-------------------
--Q2. Removing duplicates
--Q4.Data Type conversion for date_added
--Q5(ii).filling/populating null values for duartion column.
--Q6.drop columns director , listed_in,country,cast
select show_id, type, title, cast(date_added as date) as date_added, release_year, rating, 
case when duration is null then rating else duration end as duration, description 
into netflix
from
(select *
,ROW_NUMBER() over(partition by title, type order by show_id) as rnk from netflix_raw) A
where A.rnk = 1

select * from netflix

---------------XXXXXXXXXXXXXXXXX-----------------------
--Q5.populate missing values in country,duration columns

-----filling country missing values--------
select * from netflix_raw where country is null 
select * from netflix_raw where director = 'Ahishor Solomon'--country is null --order by director

insert into netflix_country
select nr.show_id,m.country
from netflix_raw nr
INNER JOIN(
select nd.director,nc.country from netflix_directors nd 
INNER JOIN netflix_country nc on nd.show_id = nc.show_id
group by director, country) m
on nr.director = m.director
where nr.country is null

select nd.director,nc.country from netflix_directors nd 
INNER JOIN netflix_country nc on nd.show_id = nc.show_id
group by director, country


