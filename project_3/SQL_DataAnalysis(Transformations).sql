--------Data Transformations or Analysis from netflix table creating by Data Cleaning------------

------------------Question1---------------------------
--for each director count the no of movies and tv shows created by them in separate columns 
--for directors who have created tv shows and movies both

select nd.director
,count(case when n.type = 'Movie' then n.show_id end) as no_of_movies
,count(case when n.type = 'TV Show' then n.show_id else NULL end) as no_of_TV_Shows
from netflix n 
join netflix_directors nd
on n.show_id = nd.show_id
group by nd.director
having count(distinct n.type) > 1

------------------Question2----------------------------
--which country has the highest number of comedy movies

select top 1 nc.country, count(distinct ng.show_id) as no_of_comedy_movies from netflix_genre ng 
INNER JOIN netflix_country nc on ng.show_id = nc.show_id
INNER JOIN netflix n on n.show_id = ng.show_id
where genre = 'Comedies' and n.type = 'Movie'
group by nc.country
order by no_of_comedy_movies desc

-----------------------Question3------------------------
--For each year (as per date added to netflix) which director has maximum no of movies released.

with cte as (
select YEAR(n.date_added) as year,nd.director, count(nd.show_id) as no_of_movies_released from netflix n
JOIN netflix_directors nd on n.show_id = nd.show_id
where type = 'Movie'
group by YEAR(n.date_added),nd.director)
--order by year desc, no_of_movies_released desc)

select year,director,no_of_movies_released from (
select *
,ROW_NUMBER() OVER(partition by year order by no_of_movies_released desc,director) as rnk
from cte
) A
where A.rnk = 1
order by year

---------------------Question4-----------------------
--what is average duration of movies in each genre.

select ng.genre,Avg(cast(REPLACE(n.duration,' min','') as int)) as Avg_duration from netflix n
INNER JOIN netflix_genre ng on n.show_id = ng.show_id
where n.type = 'Movie'
group by ng.genre
order by Avg_duration desc

---------------------Question5------------------------

--find the list of directors who have created horror and comedy movies both.
--display director names along with number of comedy and horror movies directed by them 

select nd.director
,count(case when ng.genre = 'comedies' then 1 else 0 end) as no_of_comedy_movies
,count(case when ng.genre = 'Horror movies' then 1 else 0 end) as no_of_horror_movies
from netflix_directors nd 
INNER JOIN netflix_genre ng on nd.show_id = ng.show_id
INNER JOIN netflix n on ng.show_id = n.show_id 
where n.type = 'Movie' and ng.genre in ('Comedies','Horror Movies')
group by nd.director
having count(distinct ng.genre) = 2


