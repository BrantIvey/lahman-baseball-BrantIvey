/*
Q1. What range of years does the provided database cover?

SELECT MIN(yearid) as first_season, MAX(yearid) as last_season, MAX(yearid)-MIN(yearid) as year_range
FROM appearances

Answer - 145 years


Q2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT CONCAT(p.namefirst,' ', p.namelast), p.height as height, a.g_all as games, a.teamid as team
FROM people as p
	JOIN appearances as a
		ON p.playerid = a.playerid
ORDER BY height ASC
LIMIT (1);

Answer - Eddie Gaedel, 43", 1 game with SLA
*/


