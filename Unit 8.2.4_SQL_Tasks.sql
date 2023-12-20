-- Exercise 1
-- Select the match ID, country name, season, home, and away goals from the match and country tables.
-- Complete the query that calculates the average number of goals scored overall and then includes the aggregate value in each row using a window function.*/
SELECT 
    -- Select the id, country name, season, home, and away goals
    m.id, 
    c.name AS country, 
    m.season,
    m.home_goal,
    m.away_goal,
    -- Use a window to include the aggregate average in each row
    AVG(m.home_goal + m.away_goal) OVER() AS overall_avg
FROM match AS m
LEFT JOIN country AS c ON m.country_id = c.id;


-- Exercise 2
-- Select the league name and average total goals scored from league and match.
-- Complete the window function so it calculates the rank of average goals scored across all leagues in the database.
-- Order the rank by the average total of home and away goals scored.
SELECT 
    -- Select the league name and average goals scored
    l.name AS league,
    AVG(m.home_goal + m.away_goal) AS avg_goals,
    -- Rank each league according to the average goals
    RANK() OVER(ORDER BY AVG(m.home_goal + m.away_goal)) AS league_rank
FROM league AS l
LEFT JOIN match AS m 
ON l.id = m.country_id
WHERE m.season = '2011/2012'
GROUP BY l.name
-- Order the query by the rank you created
ORDER BY league_rank;


-- Exercise 3
-- Complete the window function to rank each league from highest to lowest average goals scored.
-- Order the main query by the rank you just created.
SELECT 
    -- Select the league name and average goals scored
    l.name AS league,
    AVG(m.home_goal + m.away_goal) AS avg_goals,
    -- Rank leagues in descending order by average goals
    RANK() OVER(ORDER BY AVG(M.home_goal + m.away_goal) DESC) AS league_rank
FROM league AS l
LEFT JOIN match AS m 
ON l.id = m.country_id
WHERE m.season = '2011/2012'
GROUP BY l.name
-- Order the query by the rank you created
ORDER BY league_rank;


-- Exercise 4
-- Filter the query to only include matches played by Legia Warszawa, id = 8673.
SELECT
    date,
    season,
    home_goal,
    away_goal,
    CASE WHEN hometeam_id = 8673 THEN 'home' 
         ELSE 'away' END AS warsaw_location,
    -- Calculate the average goals scored partitioned by season
    AVG(home_goal) OVER(PARTITION BY season) AS season_homeavg,
    AVG(away_goal) OVER(PARTITION BY season) AS season_awayavg
FROM match
-- Filter the data set for Legia Warszawa matches only
WHERE 
    hometeam_id = 8673
    OR awayteam_id = 8673
ORDER BY (home_goal + away_goal) DESC;


-- Exercise 5
-- Construct two window functions partitioning the average of home and away goals by season and month.
-- Filter the dataset by Legia Warszawa's team ID (8673) so that the window calculation only includes matches involving them.
SELECT 
    date,
    season,
    home_goal,
    away_goal,
    CASE WHEN hometeam_id = 8673 THEN 'home' 
         ELSE 'away' END AS warsaw_location,
    -- Calculate average goals partitioned by season and month
    AVG(home_goal) OVER(PARTITION BY season, 
            EXTRACT(MONTH FROM date)) AS season_mo_home,
    AVG(away_goal) OVER(PARTITION BY season, 
            EXTRACT(MONTH FROM date)) AS season_mo_away
FROM match
WHERE 
    hometeam_id = 8673
    OR awayteam_id = 8673
ORDER BY (home_goal + away_goal) DESC;


-- Exercise 6
-- Assessing the running total of home goals scored by FC Utrecht.
-- Assessing the running average of home goals scored.
-- Ordering both the running average and running total by date.
SELECT 
     date, home_goal, away_goal,
    -- Create a running total and running average of home goals
    SUM(home_goal) OVER(ORDER BY date 
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
    AVG(home_goal) OVER(ORDER BY date 
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg
FROM match
WHERE hometeam_id = 9908 AND season = '2011/2012';


-- Exercise 7
-- Assessing the running total of home goals scored by FC Utrecht.
-- Assessing the running average of home goals scored.
-- Ordering both the running average and running total by date, descending.
SELECT 
     -- Select the date, home goal, and away goals
    date, home_goal, away_goal,
    -- Create a running total and running average of home goals
    SUM(home_goal) OVER(ORDER BY date DESC
         ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS running_total,
    AVG(home_goal) OVER(ORDER BY date DESC
         ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS running_avg
FROM match
WHERE awayteam_id = 9908 AND season = '2011/2012';


-- Exercise 8
-- Create a CASE statement that identifies each match as a win, lose, or tie for Manchester United.
-- Fill out the logical operators for each WHEN clause in the CASE statement (equals, greater than, less than).
-- Join the tables on home team ID from match, and team_api_id from team.
-- Filter the query to only include games from the 2014/2015 season where Manchester United was the home team.
SELECT 
    m.id, t.team_long_name,
    -- Identify matches as home/away wins or ties
    CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
        WHEN m.home_goal < m.away_goal THEN 'MU Loss'
        ELSE 'Tie' END AS outcome
FROM match AS m
-- Left join team on the home team ID and team API id
LEFT JOIN team AS t 
ON m.hometeam_id = t.team_api_id
WHERE 
    season = '2014/2015'AND t.team_long_name = 'Manchester United';


-- Exercise 9
-- Complete the CASE statement syntax.
-- Fill out the logical operators identifying each match as a win, loss, or tie for Manchester United.
-- Join the table on awayteam_id, and team_api_id.
SELECT 
    m.id, 
    t.team_long_name,
    -- Identify matches as home/away wins or ties
    CASE WHEN m.home_goal > m.away_goal THEN 'MU Loss'
        WHEN m.home_goal < m.away_goal THEN 'MU Win'
        ELSE 'Tie' END AS outcome
-- Join team table to the match table
FROM match AS m
LEFT JOIN team AS t 
ON m.awayteam_id = t.team_api_id
WHERE 
    -- Filter for 2014/2015 and Manchester United as the away team
    season = '2014/2015'
    AND t.team_long_name = 'Manchester United';


-- Exercise 10
-- Declare the home and away CTEs before your main query.
-- Join your CTEs to the match table using a LEFT JOIN.
-- Select the relevant data from the CTEs into the main query.
-- Select the date from match, team names from the CTEs, and home/ away goals from match in the main query.
-- Set up the home team CTE
WITH home AS (
  SELECT m.id, t.team_long_name,
    CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
       WHEN m.home_goal < m.away_goal THEN 'MU Loss' 
         ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.hometeam_id = t.team_api_id),
-- Set up the away team CTE
away AS (
  SELECT m.id, t.team_long_name,
    CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
       WHEN m.home_goal < m.away_goal THEN 'MU Loss' 
         ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.awayteam_id = t.team_api_id)
-- Select team names, the date and goals
SELECT DISTINCT
    m.date,
    home.team_long_name AS home_team,
    away.team_long_name AS away_team,
    m.home_goal,
    m.away_goal
-- Join the CTEs onto the match table
FROM match AS m
LEFT JOIN home ON m.id = home.id
LEFT JOIN away ON m.id = away.id
WHERE m.season = '2014/2015'
      AND (home.team_long_name = 'Manchester United' 
           OR away.team_long_name = 'Manchester United');


-- Exercise 11
-- Set up the CTEs so that the home and away teams each have a name, ID, and score associated with them.
-- Select the date, home team name, away team name, home goal, and away goals scored in the main query.
-- Rank the matches and order by the difference in scores in descending order.
-- Set up the home team CTE
WITH home AS (
  SELECT m.id, t.team_long_name,
    CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
       WHEN m.home_goal < m.away_goal THEN 'MU Loss' 
         ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.hometeam_id = t.team_api_id),
-- Set up the away team CTE
away AS (
  SELECT m.id, t.team_long_name,
    CASE WHEN m.home_goal > m.away_goal THEN 'MU Loss'
       WHEN m.home_goal < m.away_goal THEN 'MU Win' 
         ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.awayteam_id = t.team_api_id)
-- Select columns and and rank the matches by goal difference
SELECT DISTINCT
    m.date,
    home.team_long_name AS home_team,
    away.team_long_name AS away_team,
    m.home_goal, m.away_goal,
    RANK() OVER(ORDER BY ABS(home_goal - away_goal) DESC) as match_rank
-- Join the CTEs onto the match table
FROM match AS m
LEFT JOIN home ON m.id = home.id
LEFT JOIN away ON m.id = away.id
WHERE m.season = '2014/2015'
      AND ((home.team_long_name = 'Manchester United' AND home.outcome = 'MU Loss')
      OR (away.team_long_name = 'Manchester United' AND away.outcome = 'MU Loss'));
