# -Netflix-Content-Analysis-SQL-Project
# 🎬 Netflix Content Analysis — SQL Project

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue?logo=postgresql&logoColor=white)
![Dataset](https://img.shields.io/badge/Dataset-Netflix%20Titles-red?logo=netflix&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

## 📌 Project Overview

This project explores the **Netflix Titles dataset** using SQL (PostgreSQL). It covers 15 business-driven queries that uncover trends in content type, ratings, country distribution, genres, cast, and content classification — ideal for analysts and data enthusiasts looking to practice real-world SQL problem-solving.

---

## 🗃️ Dataset

The analysis is performed on a table named `netflix` which contains the following key columns:

| Column | Description |
|---|---|
| `show_id` | Unique identifier for each title |
| `type` | Movie or TV Show |
| `title` | Name of the content |
| `director` | Director(s) of the content |
| `casts` | Cast members |
| `country` | Country of production |
| `date_added` | Date added to Netflix |
| `release_year` | Year of original release |
| `rating` | Content rating (e.g. PG, R, TV-MA) |
| `duration` | Duration (minutes for movies, seasons for shows) |
| `listed_in` | Genre(s) |
| `description` | Short description of the content |

---

## 🔍 Business Problems & SQL Solutions

### 1. Count Movies vs TV Shows
```sql
SELECT type, COUNT(*) FROM netflix
GROUP BY type;
```

### 2. Most Common Rating for Each Content Type
Uses a **CTE + RANK()** window function to find the top-rated category per type.
```sql
WITH ratingcount AS (
    SELECT type, rating, COUNT(rating) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
ranking_count AS (
    SELECT type, rating, rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rnk
    FROM ratingcount
)
SELECT type, rating AS most_frequently_rating
FROM ranking_count WHERE rnk = 1;
```

### 3. All Movies Released in a Specific Year
```sql
SELECT * FROM netflix
WHERE release_year = 2020;
```

### 4. Top 5 Countries with the Most Content
```sql
SELECT country, COUNT(show_id) AS total_content
FROM netflix
GROUP BY country
HAVING country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;
```

### 5. Longest Movie
Uses `split_part()` to extract and cast duration as integer for sorting.
```sql
SELECT * FROM netflix
WHERE type = 'Movie'
ORDER BY split_part(duration, ' ', 1)::int DESC;
```

### 6. Content Added in the Last 5 Years
```sql
SELECT * FROM netflix
WHERE date_added::date >= (SELECT MAX(date_added) FROM netflix)::date - INTERVAL '5 YEAR';
```

### 7. All Content by Director 'Rajiv Chilaka'
```sql
SELECT * FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';
```

### 8. TV Shows with More Than 5 Seasons
```sql
SELECT * FROM netflix
WHERE type = 'TV Show'
  AND split_part(duration, ' ', 1)::int >= 5;
```

### 9. Content Count by Genre
Uses `UNNEST` + `STRING_TO_ARRAY` to split comma-separated genres.
```sql
SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
       COUNT(*) AS total_content
FROM netflix
GROUP BY 1;
```

### 10. Top 5 Years with Highest Average Content Release in India
```sql
SELECT country, release_year, COUNT(show_id) AS total_release,
    ROUND(COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;
```

### 11. All Documentary Movies
```sql
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries';
```

### 12. Content Without a Director
```sql
SELECT * FROM netflix
WHERE director IS NULL;
```

### 13. Movies with Salman Khan in the Last 10 Years
```sql
SELECT * FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

### 14. Top 10 Actors in Indian-Produced Content
```sql
SELECT UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor, COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY count(*) DESC
LIMIT 10;
```

### 15. Content Categorized by 'Kill' or 'Violence' in Description
```sql
SELECT category, COUNT(*) AS content_count
FROM (
    SELECT CASE
        WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
```

---

## 💡 Key SQL Concepts Used

- `GROUP BY` and aggregate functions (`COUNT`, `ROUND`)
- Window functions: `RANK() OVER (PARTITION BY ...)`
- Common Table Expressions (CTEs) with `WITH`
- String functions: `split_part()`, `STRING_TO_ARRAY()`, `UNNEST()`, `ILIKE`, `LIKE`
- Type casting with `::int`, `::numeric`, `::date`
- Date arithmetic with `INTERVAL`
- Subqueries and `EXTRACT()`

---

## 🚀 How to Run

1. **Set up PostgreSQL** and create a database.
2. **Import the Netflix dataset** (available on [Kaggle](https://www.kaggle.com/datasets/shivamb/netflix-shows)).
3. **Create the table:**
```sql
CREATE TABLE netflix (
    show_id      VARCHAR(10),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```
4. **Load your data** using `COPY` or a CSV import tool.
5. **Run the queries** from the `queries.sql` file or paste them directly into your SQL client.

---

## 📊 Insights Snapshot

| Question | Insight |
|---|---|
| Content Split | Netflix has more Movies than TV Shows overall |
| Most Common Rating | `TV-MA` is the most frequent rating for both types |
| Top Country | USA leads in total content volume |
| Indian Avg Release | Identifies which years saw the highest Indian content output |
| Violent Content | Classifies content as "Good" or "Bad" using keyword detection |

---

## 🛠️ Tools & Technologies

- **PostgreSQL** — Primary query engine
- **pgAdmin / DBeaver** — Recommended SQL clients
- **Dataset** — Netflix Movies and TV Shows (Kaggle)

---

## 📁 Repository Structure

```
netflix-sql-analysis/
│
├── README.md          ← You are here
├── queries.sql        ← All 15 SQL queries
└── dataset/
    └── netflix.csv    ← Source data (download from Kaggle)
```

---

## 🤝 Contributing

Pull requests are welcome! If you have additional analysis ideas or query optimizations, feel free to open an issue or submit a PR.

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
