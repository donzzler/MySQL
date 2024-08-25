CREATE TABLE contestants (
    season INT,
    id INT PRIMARY KEY,
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    sex CHAR(1),
    age INT,
    city VARCHAR(20),
    province VARCHAR(3),
    marital_status VARCHAR(15),
    kids INT,
    job VARCHAR(50)
);

CREATE TABLE episodes (
    episode_id VARCHAR(6) PRIMARY KEY,
    theme VARCHAR(30),
    signature VARCHAR(30),
    signature_time_limit FLOAT,
    technical VARCHAR(30),
    technical_time_limit FLOAT,
    1st VARCHAR(20),
    2nd VARCHAR(20),
    3rd VARCHAR(20),
    4th VARCHAR(20),
    5th VARCHAR(20),
    6th VARCHAR(20),
    7th VARCHAR(20),
    8th VARCHAR(20),
    9th VARCHAR(20),
    10th VARCHAR(20),
    show_stopper VARCHAR(30),
    show_stopper_time_limit FLOAT,
    star_baker VARCHAR(20),
    eliminated VARCHAR(20)
);

CREATE TABLE bakes (
    season INT,
    episode INT,
    episode_id VARCHAR(6),
    challenge VARCHAR(15),
    baker VARCHAR(20),
    bake VARCHAR(20),
    bake_type VARCHAR(30),
    main_flavours VARCHAR(100),
    side_flavours VARCHAR(50),
    design VARCHAR(30),
    fondant VARCHAR(3),
    tiers INT,
    theme VARCHAR(50),
    category VARCHAR(20),
    outcome VARCHAR(20)
);

CREATE TABLE technicals (
    id INT,
    technical_avg FLOAT
);

ALTER TABLE bakes
ADD FOREIGN KEY(episode_id)
REFERENCES episodes(episode_id);

ALTER TABLE technicals
ADD FOREIGN KEY(id)
REFERENCES contestants(id);

## Contestants
## Average age, minimum age and maximum age of contestants. Seasons 2-6.

SELECT ROUND(AVG(age), 1) AS avg_age, MIN(age) AS youngest, MAX(age) AS oldest
FROM contestants
WHERE age IS NOT NULL;


## Most common Province and City

SELECT province, COUNT(province) AS 'count'
FROM contestants
GROUP BY province
ORDER BY COUNT(*) DESC;

SELECT city, COUNT(city) AS 'count'
FROM contestants
GROUP BY city
ORDER BY COUNT(*) DESC;

## Number of male and female contestants

SELECT sex, COUNT(sex) AS 'count'
FROM contestants
GROUP BY sex;

## Episodes
## Average, shortest, and longest signature, technical, and show stopper time limits

SELECT ROUND(AVG(signature_time_limit), 2) AS avg_signature_time_limit, MIN(signature_time_limit) AS min_signature_time_limit,
    MAX(signature_time_limit) AS max_signature_time_limit
FROM episodes;

SELECT ROUND(AVG(technical_time_limit), 2) AS avg_technical_time_limit, MIN(technical_time_limit) AS min_technical_time_limit,
    MAX(technical_time_limit) AS max_technical_time_limit
FROM episodes;

SELECT ROUND(AVG(show_stopper_time_limit), 2) AS avg_show_stopper_time_limit, 
    MIN(show_stopper_time_limit) AS min_show_stopper_time_limit, MAX(show_stopper_time_limit) AS max_show_stopper_time_limit
FROM episodes;

## Season winners

SELECT contestants.season, episodes.star_baker AS winner
FROM contestants
JOIN episodes
ON contestants.first_name = episodes.star_baker
WHERE episodes.episode_id LIKE '%e08';

## Average age of season winners

SELECT ROUND(AVG(age), 1) AS avg_age_of_season_winner
FROM contestants
WHERE first_name IN (
    SELECT star_baker
    FROM episodes
    WHERE episode_id LIKE '%e08' AND star_baker IN (
        SELECT first_name
        FROM contestants
        WHERE id > 200
));

## Technical wins by contestant

SELECT contestants.season, episodes.1st AS name, COUNT(episodes.1st) AS technical_wins
FROM contestants
JOIN episodes
ON contestants.first_name = episodes.1st
GROUP BY episodes.1st, contestants.season
ORDER BY COUNT(*) DESC;

## Contestants that have averaged a top 3 finish in the technicals

SELECT a.season, a.first_name AS name, b.technical_avg AS technical_avg_position
FROM contestants a
JOIN technicals b
ON a.id = b.id
WHERE b.technical_avg <= 3
ORDER BY b.technical_avg ASC;

SELECT category, COUNT(category) AS 'count'
FROM bakes
GROUP BY category
ORDER BY count DESC;

SELECT COUNT(fondant) AS bakes_with_fondant
FROM bakes
WHERE fondant IS NOT NULL;

SELECT *
FROM bakes
WHERE tiers IS NOT NULL
ORDER BY tiers DESC;

## Number of successful and unsuccessful bakes

SELECT season, COUNT(outcome) AS unsuccessful_bakes
FROM bakes
WHERE outcome LIKE 'Unsuccessful'
GROUP BY season;

SELECT season, COUNT(outcome) AS successful_bakes
FROM bakes
WHERE outcome LIKE 'Successful'
GROUP BY season;

UPDATE bakes
SET category = 'Traditional'
WHERE category IS NULL;

## number of holiday themed bakes

SELECT *
FROM bakes
WHERE category LIKE 'Holiday/Item';

## Successful bakes by baker

SELECT season, baker, COUNT(outcome) AS outcome
FROM bakes
WHERE outcome LIKE 'Successful'
GROUP BY season, baker
ORDER BY COUNT(*) DESC;

## Andrei's successful bakes
SELECT * 
FROM bakes
WHERE baker LIKE 'Andrei' AND outcome LIKE 'Successful';