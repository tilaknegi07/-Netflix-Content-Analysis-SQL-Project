select * from netflix
--1. Count the Number of Movies vs TV Shows
select type,count(*) from netflix
group by type

--2. Find the Most Common Rating for Movies and TV Shows
with ratingcount as (
select 
	type,
	rating,
	count(rating) AS rating_count 
	from netflix
	group by 
	type, rating
),
ranking_count as (
select 
	type,
	rating,
	rating_count,
	rank() over (partition by type order by rating_count desc) as rnk 
	from ratingcount
)
select type,
rating as most_frequently_rating 
from ranking_count
where rnk =1

--3. List All Movies Released in a Specific Year (e.g., 2020)
select * from netflix
where release_year =2020 

--4. Find the Top 5 Countries with the Most Content on Netflix
select * from (
select country,
count(show_id) as total_contant
from netflix
group by country) as t1
where country is not null
order by total_contant desc
limit 5

--5Identify the Longest Movie
select * from netflix
where type ='Movie'
order by split_part(Duration,' ',1)::int desc 

--6. Find Content Added in the Last 5 Years
select * from netflix
where date_added::date>=(select MAX(date_added) from netflix)::date	- INTERVAL '5 YEAR'


--7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
select * from netflix
where director like '%Rajiv Chilaka%'

--8. List All TV Shows with More Than 5 Seasons
select *  from netflix
where type = 'TV Show' 
and split_part(duration,' ',1)::int >=5

--9. Count the Number of Content Items in Each Genre
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;

--10.Find each year and the average numbers of content release in India on netflix.
   --return top 5 year with highest avg content release!
select 
country,
release_year,
count(show_id) as total_release,
round(count(show_id)::numeric/
(select count(show_id) from netflix where country= 'India')::numeric*100,2) as avg_release
from netflix
where country='India'
group by country,release_year
order by avg_release desc
limit 5

--11. List All Movies that are Documentaries
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

--12. Find All Content Without a Director
SELECT * 
FROM netflix
WHERE director IS NULL;

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
  
--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
 select 
 unnest(string_to_array(casts,',')) as  actor,
 count(*)
 from netflix
 where country = 'India'
 group by actor
 order by count(*) desc 
 limit 10
 
 --15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
 SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;



	