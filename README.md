# Netflix Movies and TV Shows Data Analysis using SQL

![](!https://github.com/MnthnShrmaa/Netflix_Data_Analysis/blob/main/Netflix-Logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
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

```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT "type",
		COUNT(*) as Total_count
FROM netflix
GROUP BY "type";
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflix
WHERE release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as TOP_5_COUNTRIES,
	COUNT(show_id) as count_of_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT 
	title,
	MAX(CAST(SUBSTRING(duration, 1, POSITION(' ' in duration)-1) as INT)) AS movie_length
FROM netflix
WHERE type = 'Movie'
	and duration IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
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
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *,
	CAST(SUBSTRING(duration, 1, POSITION(' ' IN duration)-1) as INT) as no_of_seasons
FROM netflix
WHERE type = 'TV Show'
	and CAST(SUBSTRING(duration, 1, POSITION(' ' IN duration)-1) as INT) >=5 
	and duration is not null;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
	COUNT(show_id) as no_of_content
FROM netflix
GROUP BY 1
ORDER BY 1 ;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT 
	title,
	listed_in
FROM netflix
WHERE 
	listed_in LIKE '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT *
FROM netflix
WHERE 
	"cast" LIKE '%Salman Khan%'
	and
	release_year >= EXTRACT(YEAR FROM Current_date ) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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

```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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

```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

