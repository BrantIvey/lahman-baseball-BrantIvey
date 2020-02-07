/*
Q1
What range of years does the provided database cover?

Answer: 1871 through 2016

SELECT MIN(yearid) as first_season, MAX(yearid) as last_season, MAX(yearid)-MIN(yearid) as year_range
FROM appearances

---

Q2
Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

Answer: Eddie Gaedel, 43", 1 game with SLA

SELECT CONCAT(p.namefirst,' ', p.namelast), p.height as height, a.g_all as games, a.teamid as team
FROM people as p
	JOIN appearances as a
		ON p.playerid = a.playerid
ORDER BY height ASC
LIMIT (1);


----

Q3 
Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names 
as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which 
Vanderbilt player earned the most money in the majors?

Answer: David Price - 245,553,888


SELECT concat(p.namefirst,' ',p.namelast) as name, SUM(salaries.salary) as salary, c.schoolid as school
FROM people as p
	JOIN collegeplaying as c
		on p.playerid = c.playerid
	JOIN salaries
		on p.playerid = salaries.playerid
WHERE c.schoolid = 'vandy'
GROUP BY name, school
ORDER BY salary DESC;


---

Q4
Using the fielding table, group players into three groups based on their position: label players with position OF as 
"Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery".
Determine the number of putouts made by each of these three groups in 2016.

Answer:
	Infield - 58934
	Battery - 41424
	Outfield - 29560
	
	
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

	
----

Q5
Find the average number of strikeouts per game by decade 
since 1920. Round the numbers you report to 2 decimal places. 
Do the same for home runs per game. Do you see any trends?

Answer - K/game increased every decade since 70s. Homers increased similarly as well since the 70s, 2010s was down from 2000s
potential impact of the steroid era.

SELECT  trunc(yearid,-1) as year,round(sum(so)::decimal / sum(g)::decimal,2) as K_pergame_peryear
	FROM teams
	WHERE yearid >= 1920
	GROUP BY year
	ORDER BY year desc


SELECT  trunc(yearid,-1) as decade,round(sum(hr)::decimal / sum(g)::decimal,2) as hr_pergame_peryear
	FROM teams
	WHERE yearid >= 1920
	GROUP BY decade
	ORDER BY decade desc

----

Q6.
Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base 
attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only 
players who attempted at least 20 stolen bases.

Answer -- Chris Owings

SELECT p.namefirst,p.namelast, b.sb as total_steals,sum(b.sb+b.cs) as attempts,
	round((b.sb/(b.sb+b.cs)::decimal*100),2) as sub_pct
	FROM batting as b
		JOIN people as p
			ON b.playerid = p.playerid
	WHERE SB >0 AND CS>0 AND yearid = 2016 AND sb+cs >=20
	GROUP BY p.namefirst, p.namelast, b.sb, b.cs
	ORDER BY sub_pct DESC
	
	
----

Q7
From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of 
wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world 
series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was 
it the case that a team with the most wins also won the world series? What percentage of the time?

Answer
Max wins 1970 - 2016 did not win WS: 2001 SEA 116 wins
Min win (problem year) 1981 LAD 63 wins
Min win (problem year removed) 2006 STL  83 wins

--Max wins WS L

	SELECT name, yearid,MAX(w), wswin
	FROM teams
	WHERE yearid BETWEEN 1970 and 2016
	AND wswin = 'N'
	GROUP BY name, w,yearid,wswin
	ORDER BY w DESC
	LIMIT 1
	
--Min wins WS win

	SELECT name, yearid,MIN(w), wswin
		FROM teams
		WHERE yearid BETWEEN 1970 and 2016
		AND wswin = 'Y'
	GROUP BY name, w,yearid,wswin
	ORDER BY w
	LIMIT 1
	
-- MIN wins WS win

		SELECT name, yearid,MIN(w), wswin
			FROM teams
			WHERE yearid BETWEEN 1970 and 2016
			AND yearid <> 1981
			AND wswin = 'Y'
		GROUP BY name, w,yearid,wswin
		ORDER BY w
		LIMIT 1


How often between 1970 - 2016 did the team with the max number
of wins win the WS? What percentage of the time?

Answer:26%

			
--wswin<>maxW  34 years

with cte1 as (SELECT yearid, wswin, name,w as w_by_ws_champ
	FROM teams
	WHERE yearid between 1970 and 2016 AND wswin = 'Y'),
	
	cte2 as (SELECT
			distinct yearid,max(W) as wins
			 FROM teams
			 group by yearid)
			 
SELECT cte1.yearid,cte1.wswin, cte1.name,cte1.w_by_ws_champ, cte2.wins
	FROM teams
		inner join cte1
			on teams.yearid = cte1.yearid
		inner join cte2
			on teams.yearid = cte2.yearid
		WHERE w_by_ws_champ <> wins
		GROUP BY cte1.yearid,cte2.yearid, cte1.wswin,cte2.wins,cte1.name, cte1.w_by_ws_champ
		ORDER BY yearid
		
		
---


Q8
Using the attendance figures from the homegames table, find 
the teams and parks which had the top 5 average attendance per
game in 2016 (where average attendance is defined as total 
attendance divided by number of games). Only consider parks 
where there were at least 10 games played.Report the park name,
team name, and average attendance.

ANSWER: 
TOP 5 ATTENDANCE - LAD, StL,Tor, SF,CHC
BOTTOM 5 ATTENDANCE - TB, OAK, CLE, MIA, CHW


--MAX Attendance

SELECT p.park_name,team, SUM(h.attendance/h.games) as attendance_per_game
	FROM homegames as h
		JOIN parks as p
		ON h.park = p.park
	WHERE h.year = 2016
	AND games >= 10
	GROUP BY p.park_name, team
	ORDER BY attendance_per_game DESC
	LIMIT 5

--Smallest attendance

SELECT p.park_name,team,SUM(h.attendance/h.games) as attendance_per_game
	FROM homegames as h
		JOIN parks as p
		ON h.park = p.park
	WHERE h.year = 2016
	AND games >= 10
	GROUP BY p.park_name, team
	ORDER BY attendance_per_game 
	LIMIT 5 

---

Q9
Which managers have won the TSN Manager of the Year award 
in both the National League (NL) and the American League (AL)?
Give their full name and the teams that they were managing 
when they won the award.

ANSWER
	Jim Lealand AL - 2006; NL - 1992, 1988, 1990. PIT in AL, DET in AL
	Davey Johnson AL - 1997; NL - 2012. BAL in AL, WAS in NL


-- Find the winners
with cte1 AS(
	SELECT 
		playerid, awardid,lgid as AL, yearid as AL_year
	FROM awardsmanagers
			WHERE awardid LIKE '%TSN%' AND lgid LIKE 'AL'
		
),

 cte2 as (
	SELECT
		playerid, awardid,lgid as NL, yearid as NL_year
		FROM awardsmanagers
			WHERE awardid LIKE '%TSN%' AND lgid LIKE 'NL'
),

cte3 as (
	SELECT
		awardsmanagers.playerid,CONCAT(p.namefirst,' ',p.namelast) as name
			FROM awardsmanagers
				JOIN people as p
				on awardsmanagers.playerid = p.playerid
)

SELECT DISTINCT (awardsmanagers.playerid), cte3.name, cte1.AL, AL_year,cte2.NL, NL_year
	FROM awardsmanagers
		INNER JOIN cte1
			ON awardsmanagers.playerid = cte1.playerid
		INNER JOIN cte2
			ON awardsmanagers.playerid = cte2.playerid
		INNER JOIN cte3
			on awardsmanagers.playerid = cte3.playerid
		
--Jim Lealand team search

SELECT DISTINCT yearid,playerid, teamid
			FROM managers
			WHERE managers.playerid = 'leylaji99' 
			AND managers.yearid IN (1988,1992,1990,2006)

--Davey Johnson team search

SELECT DISTINCT yearid,playerid, teamid
			FROM managers
			WHERE managers.playerid = 'johnsda02' 
			AND managers.yearid IN (1997,2012)
*/
