SELECT CAST(event_ts AS DATE) AS "Day", COUNT(DISTINCT user_id) AS "Number of Players" 
FROM retention
WHERE Day BETWEEN '2019-09-01' AND '2019-10-31' -- OPTIONAL, in every request
	AND event_name = 'open_app'
GROUP BY Day
ORDER BY Day;

SELECT to_char(CAST(event_ts AS DATE), 'dd-mm') AS "Date", SUM(sku_price) AS "Total Gained per Day"
FROM purchases
GROUP BY date
ORDER BY date;

SELECT user_id, 
SUM(sku_price) as tot_spent
FROM purchases 
GROUP BY user_id
ORDER BY tot_spent DESC
LIMIT 10;


/********************/




SELECT first_join, COUNT(DISTINCT user_id)
FROM (
	SELECT user_id, MIN(CAST(event_ts AS DATE)) AS first_join
	FROM retention
	GROUP BY user_id

)
GROUP BY first_join
ORDER BY first_join;

SELECT fj_date as Day, 
Users as "Users",
Users || '/' || (
    SELECT MAX(Users) 
    FROM (
          SELECT CAST(event_ts AS DATE) AS fj_date, COUNT(DISTINCT  players) AS Users
    FROM retention
    INNER JOIN  (
          SELECT user_id AS players, MIN(CAST(event_ts AS DATE)) AS first_join
	        FROM retention
	        GROUP BY players
	        HAVING MIN(CAST(event_ts AS DATE)) = '2019-09-15'
          ) AS sub
    ON retention.user_id = sub.players
    GROUP BY fj_date
    ORDER BY fj_date
          )
  ) AS "Calculation",
round((CAST(Users AS FLOAT )/(
    SELECT MAX(Users) 
    FROM (
          SELECT CAST(event_ts AS DATE) AS fj_date, COUNT(DISTINCT  players) AS Users
    FROM retention
    INNER JOIN  (
          SELECT user_id AS players, MIN(CAST(event_ts AS DATE)) AS first_join
	        FROM retention
	        GROUP BY players
	        HAVING MIN(CAST(event_ts AS DATE)) = '2019-09-15'
          ) AS sub
    ON retention.user_id = sub.players
    GROUP BY fj_date
    ORDER BY fj_date
          )
  ))*100,
  2)||'%' AS "Retention"

FROM (
    SELECT CAST(event_ts AS DATE) AS fj_date, COUNT(DISTINCT  players) AS Users
    FROM retention
    INNER JOIN  (
          SELECT user_id AS players, MIN(CAST(event_ts AS DATE)) AS first_join
	        FROM retention
	        GROUP BY players
	        HAVING MIN(CAST(event_ts AS DATE)) = '2019-09-15'
          ) AS sub
    ON retention.user_id = sub.players
    GROUP BY fj_date
    ORDER BY fj_date)
WHERE fj_date BETWEEN '2019-09-15' AND '2019-09-21'
GROUP BY fj_date, Users
ORDER BY fj_date




SELECT day, Player_Count "New Players", Player_Count_in_sev AS "New Players still playing in a week", Round(CAST(Player_Count_in_sev AS FLOAT )/Player_Count*100,2)||'%' AS "retention on day 7"
FROM
(
	SELECT first_join AS day, COUNT(DISTINCT user_id) AS Player_Count
	FROM (
		SELECT user_id, MIN(CAST(event_ts AS DATE)) AS first_join
		FROM retention
		WHERE CAST(event_ts AS DATE) BETWEEN '2019-09-01' AND '2019-09-30'
		GROUP BY user_id

	)
	GROUP BY first_join
	ORDER BY first_join
	) AS tab1
INNER JOIN (
	SELECT first_join, COUNT(DISTINCT player)  AS Player_Count_in_sev
	FROM
			(SELECT user_id AS new_player, MIN(CAST(event_ts AS DATE)) AS first_join, first_join+13 AS sev_days_after
			FROM retention
			WHERE CAST(event_ts AS DATE) BETWEEN '2019-09-01' AND '2019-09-30'
			GROUP BY user_id) as subtab1
		  INNER JOIN (
		  SELECT user_id AS player,CAST(event_ts AS DATE) as day
		  FROM retention ) as subtab2
  ON subtab1.sev_days_after = subtab2.day
  WHERE subtab1.new_player = subtab2.player
  GROUP By first_join
  ORDER By first_join
  ) AS tab2
ON tab1.day = tab2.first_join
ORDER BY day





How many users purchase IAPs and how much do they pay every day in total?






/**/
SELECT CAST(event_ts AS DATE) AS DAY, COUNT(DISTINCT user_id) AS "n° Utenti Paganti", SUM(sku_price) AS "Guadagno tot"
FROM purchases 
GROUP BY DAY
ORDER BY DAY

--
SELECT * 
FROM 
(
(SELECT EXTRACT(Month FROM event_ts) AS month, sku, COUNT(sku) AS "n° tot acquisti", SUM(sku_price) AS "Guadagno tot"
FROM purchases 
WHERE month = '9'
GROUP BY month, sku
ORDER BY COUNT(sku) DESC
LIMIT 5)
UNION 
(SELECT EXTRACT(Month FROM event_ts) AS month, sku, COUNT(sku) AS "n° tot acquisti", SUM(sku_price) AS "Guadagno tot"
FROM purchases 
WHERE month = '10'
GROUP BY month, sku
ORDER BY COUNT(sku) DESC
LIMIT 5)
)
ORDER BY month

--

SELECT EXTRACT(Month FROM event_ts) AS month, COUNT(sku)
FROM purchases 
GROUP BY month
ORDER BY COUNT(sku)

--

SELECT purchases.user_id as player, SUM(sku_price) AS "Tot Spent in first week" --SUM(sku_price) AS "Fisrt week spending"
FROM purchases 
INNER JOIN (
	SELECT user_id, MIN(CAST(event_ts AS DATE)) AS first_join
	FROM purchases 
	GROUP BY user_id
) AS tab
ON tab.user_id = purchases.user_id 
WHERE CAST(event_ts AS DATE) BETWEEN first_join AND first_join+6
GROUP BY player
ORDER BY SUM(sku_price) DESC

--

SELECT purchases.user_id as player, SUM(sku_price) AS "Tot Spent in first week" --SUM(sku_price) AS "Fisrt week spending"
FROM purchases 
INNER JOIN (
	SELECT user_id, MIN(CAST(event_ts AS DATE)) AS first_join
	FROM purchases 
	GROUP BY user_id
) AS tab
ON tab.user_id = purchases.user_id 
WHERE CAST(event_ts AS DATE) BETWEEN first_join AND first_join+7
GROUP BY player
ORDER BY SUM(sku_price) DESC
