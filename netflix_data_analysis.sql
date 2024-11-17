-- netflix Data Analysis

Drop Table if exists netflix;
Create Table netflix(
	show_id Varchar(10) Primary Key,
	"type" Varchar(10),
	title Varchar(110),
	director Varchar(210),
	"cast" Varchar(1000),
	country Varchar(150),
	date_added Varchar(50),
	release_year INT,
	rating Varchar(20),
	duration Varchar(15),
	listed_in Varchar(80),
	description Varchar(300)
	);

Select * from netflix
LIMIT 5;

SELECT COUNT(*) as total_rows
FROM netflix;

-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

SELECT "type",
		COUNT(*) as Total_count
FROM netflix
GROUP BY "type";

-- 2. Find the most common rating for movies and TV shows.

WITH ranking AS(
	SELECT 
		"type",
		rating,
		COUNT(rating) as "Count",
		RANK() OVER (PARTITION BY "type" ORDER BY COUNT(rating) DESC) AS "rank"
	FROM netflix
	GROUP BY "type", rating
	ORDER BY type, COUNT(rating) DESC
	)
SELECT type, rating as common_rating
FROM ranking
WHERE "rank" = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix

SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as TOP_5_COUNTRIES,
	COUNT(show_id) as count_of_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT 
	title,
	MAX(CAST(SUBSTRING(duration, 1, POSITION(' ' in duration)-1) as INT)) AS movie_length
FROM netflix
WHERE type = 'Movie'
	and duration IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

	
-- 6. Find content added in the last 5 years

WITH 
	ranking as(
		SELECT *,
			CAST(RIGHT(date_added,4) AS INT) AS year_added,
			DENSE_RANK() OVER (ORDER BY CAST(RIGHT(date_added,4) AS INT) DESC) AS "RANK"
		FROM netflix
		where date_added IS NOT NULL
		ORDER BY DENSE_RANK() OVER (ORDER BY CAST(RIGHT(date_added,4) AS INT)) DESC
		)
SELECT *
FROM ranking
WHERE "RANK" <6
ORDER BY "RANK" DESC;

-- ALTERNATE

SELECT *,
	TO_DATE(date_added, 'Month DD, YYYY') AS "DATE"
FROM netflix
WHERE 
	TO_DATE(date_added, 'Month DD, YYYY') > CURRENT_DATE - INTERVAL '5 YEARS'
	ORDER BY TO_DATE(date_added, 'Month DD, YYYY') ;
	
-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons

SELECT *,
	CAST(SUBSTRING(duration, 1, POSITION(' ' IN duration)-1) as INT) as no_of_seasons
FROM netflix
WHERE type = 'TV Show'
	and CAST(SUBSTRING(duration, 1, POSITION(' ' IN duration)-1) as INT) >=5 
	and duration is not null;

-- 9. Count the number of content items in each genre

SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
	COUNT(show_id) as no_of_content
FROM netflix
GROUP BY 1
ORDER BY 1 ;

-- 10.Find each year and the average numbers of content release in India on netflix.
-- return top 5 year with highest avg content release!

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

-- 11. List all movies that are documentaries

SELECT 
	title,
	listed_in
FROM netflix
WHERE 
	listed_in LIKE '%Documentaries%';

-- 12. Find all content without a director

SELECT *
FROM netflix
WHERE director IS NULL;

-- 13. Find in how many movies has actor 'Salman Khan' appeared in last 10 years!

SELECT *
FROM netflix
WHERE 
	"cast" LIKE '%Salman Khan%'
	and
	release_year >= EXTRACT(YEAR FROM Current_date ) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	UNNEST(STRING_TO_ARRAY("cast", ',')) as actors,
	COUNT(show_id) as total_movies
FROM netflix
WHERE 
	"cast" IS NOT NULL
	and
	"type" = 'Movie'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/* 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
	the description field. Label content containing these keywords as 'Bad' and all other 
	content as 'Good'. Count how many items fall into each category.*/

SELECT 
	UNNEST(STRING_TO_ARRAY("cast", ',')) as actors,
	COUNT(show_id) as total_movies
FROM netflix
WHERE 
	"cast" IS NOT NULL
	and
	"type" = 'Movie'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


