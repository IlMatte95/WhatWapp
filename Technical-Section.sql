/*
The first question can be understood in two ways:
De Dicto - For each Day what is the number of unique users
De Re 	 - What is the number of the users that (each and) every day used the app
I figured the former is the most likely and useful interpretation
*/

-- call the day,
SELECT CAST(event_time as DATE) as day,
-- Count the different Users
COUNT (DISTINCT user_id) as Number_Diff_users
FROM events
-- OPTIONAL(?) in case I should not count twice all those people that opened the app before midnight and play/purchase the day after 
WHERE event_name = 'open' 
GROUP BY day;


-- sort by date & count the players from Aux
SELECT etime,
COUNT(players) as "Player>10"
FROM (
	-- Auxiliary Tab with date and players that opened the game > 10
	SELECT CAST(event_time as DATE) AS etime, 
	user_id AS players,
	COUNT(event_time) AS app_opened_by_players
	FROM events
	WHERE event_name = 'play'
	GROUP BY CAST(event_time as DATE), user_id
	HAVING COUNT(event_time) >= 10
	) as Aux
GROUP BY etime;


-- group the players, sum their spending
SELECT user_id, 
SUM(iap_price) as tot_spent
FROM events
GROUP BY user_id
-- order desc and limit to 10
ORDER BY tot_spent DESC
LIMIT 10;


/*Also this exercise seem two have two different intepretations: 
depending on what we consider the "most played game"
In one case we mean most played by different users, in another with more "event_name = 'play'" in total*/


-- most played by different players:
SELECT game_name, COUNT(DISTINCT user_id) AS players FROM events
GROUP BY game_name
ORDER BY players DESC
LIMIT 2;

-- with more "event_name = 'play'":
-- group by game and count the users from the Aux tab
SELECT game_name, COUNT(DISTINCT user_id)
FROM Events
WHERE game_name IN -- choose the top 2 games
	(SELECT game_name
	FROM Events 
	WHERE event_name = 'play' -- by checking only the "play" event
	GROUP BY game_name
	ORDER BY COUNT(event_name) DESC -- and ordering the game by their total events
	LIMIT 2) AS Aux -- top 2 
GROUP BY game_name;
