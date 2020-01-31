/*
Q1. What range of years does the provided database cover?

SELECT MIN(yearid) as first_season, MAX(yearid) as last_season, MAX(yearid)-MIN(yearid) as year_range
FROM appearances

Answer: 145 years


Q2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT CONCAT(p.namefirst,' ', p.namelast), p.height as height, a.g_all as games, a.teamid as team
FROM people as p
	JOIN appearances as a
		ON p.playerid = a.playerid
ORDER BY height ASC
LIMIT (1);

Answer: Eddie Gaedel, 43", 1 game with SLA


Q3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names 
as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which 
Vanderbilt player earned the most money in the majors?

SELECT concat(p.namefirst,' ',p.namelast) as name, SUM(salaries.salary) as salary, c.schoolid as school
FROM people as p
	JOIN collegeplaying as c
		on p.playerid = c.playerid
	JOIN salaries
		on p.playerid = salaries.playerid
WHERE c.schoolid = 'vandy'
GROUP BY name, school
ORDER BY salary DESC;

Answer: David Price - 245,553,888

Using the fielding table, group players into three groups based on their position: label players with position OF as 
"Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery".
Determine the number of putouts made by each of these three groups in 2016.

SELECT SUM(po) as putouts,
	CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS' THEN 'Infield'
		WHEN pos = '2B' THEN 'Infield'
		WHEN pos = '3B' THEN 'Infield'
		WHEN pos = '1B' THEN 'Infield'
		WHEN pos = 'P' THEN 'Battery'
		WHEN pos = 'C' THEN 'Battery' END as position
FROM fielding
WHERE yearid = '2016'
GROUP BY position
ORDER BY putouts DESC;

Answer:
	Infield - 58934
	Battery - 41424
	Outfield - 29560
	
*/







