CREATE DATABASE restaurant;

USE restaurant;


CREATE TABLE chefmozaccepts(
placeID  INTEGER  NOT NULL,
Rpayment VARCHAR(30)
);

SELECT * FROM chefmozaccepts;


CREATE TABLE chemozcuisine(
PlaceID INTEGER NOT NULL,
Rcuisine  VARCHAR (30) NOT NULL
);

SELECT * FROM  chemozcuisine;


CREATE TABLE chefmozhours(
placeID INTEGER NOT NULL,
Start_Time  TIME,
End_Time   TIME,
days   		VARCHAR(255)
);

LOAD DATA LOCAL INFILE 'C:/Users/SUSHANT/Desktop/sql project/SQl restaurant project/chefmozhours.csv'
INTO TABLE chefmozhours
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(placeID, Start_Time, End_Time, days);


SELECT * from chefmozhours;



CREATE TABLE chefmozparking(
placID  INTEGER  NOT NULL,
parking_lot VARCHAR(50)
);

SELECT * FROM chefmozparking;



CREATE TABLE geoplace(
placeID INTEGER  NOT NULL,
Restaurant_Name  VARCHAR(50),
Address          VARCHAR(50),
city			 VARCHAR(50),
state 			VARCHAR(50),
country   		VARCHAR(50),
alchol 	        VARCHAR(50),
smoking_area   VARCHAR(50),
dress_code     VARCHAR(50),
accessibility  VARCHAR(50),
price 			VARCHAR(50),
Rambience       VARCHAR(50),
franchise       VARCHAR(10),
area			VARCHAR(50),
other_services  VARCHAR(50)
);

SELECT * FROM geoplace;




CREATE TABLE  final_rating(
userID    VARCHAR(10)  NOT NULL,
placeID   INTEGER NOT NULL,
rating   INTEGER NOT NULL,
food_rating INTEGER NOT NULL,
service_rating INTEGER NOT NULL
);

SELECT * FROM final_rating;

CREATE TABLE usercuisine(
userID    VARCHAR(50),
Rcuisine	VARCHAR(50)
);

SELECT * FROM usercuisine;

CREATE TABLE userpayment(
userID 		VARCHAR(50),
Upayment    VARCHAR(50)
);

SELECT * FROM userpayment;

CREATE TABLE userprofile(
UserId 		VARCHAR(50),
smoker      VARCHAR(50),
drink_level		VARCHAR(50),
dress_preference  VARCHAR(50),
ambience		VARCHAR(50),
transport		VARCHAR(50),
marital_status  VARCHAR(50),
hijos 			VARCHAR(50),
birth_year 		YEAR ,
interest        VARCHAR(50),
personality		VARCHAR(50),
religion		VARCHAR(50),
activity		VARCHAR(50),
color           VARCHAR(50),
weight         INTEGER NOT NULL,
budget         VARCHAR(50),
height			INTEGER NOT NULL
);

SELECT * FROM userprofile;


/*   Q1)  Finding Top 10 Restaurant name their respective State & Total Customers 
visiting that Restaurant  Based on Rating. */

SELECT
    g.Restaurant_Name AS favorite_restaurant,
    g.state,
	count(f.userid) as total_customers
FROM
    userprofile AS u
JOIN
    final_rating AS f ON u.UserId = f.userID
JOIN
    geoplace AS g ON f.placeID = g.placeID
WHERE
    f.rating = (
			SELECT MAX(rating)
			FROM final_rating AS fr
			WHERE fr.userID = f.userID
    )
GROUP BY  f.userid
ORDER BY
   count(f.userid)
    DESC limit 10;

        
/*   Q2)  Find the faviourite cuisines of customers  in Restaurants?    */
   
SELECT 
		rcuisine, 
        count(userID) As total_Customers
FROM 
	usercuisine
GROUP BY 
	rcuisine
ORDER BY
	total_customers
DESC 
LIMIT 10;
        
        
/*  Q3) Find the Top 5 City with most number of restaurants? */

SELECT
    city,
    COUNT(DISTINCT placeID) AS RestaurantCount
FROM
    geoplace
WHERE
    city IS NOT NULL
GROUP BY
    city
ORDER BY
    RestaurantCount DESC
LIMIT 5;


/*  Q4) List restaurant  with maximum wearing dress code  */
WITH DressCodeCounts AS (
    SELECT
        g.Restaurant_Name,
        g.dress_code,
        COUNT(DISTINCT u.UserId) AS UserCount
    FROM
        userprofile AS u
    JOIN
        final_rating AS f ON u.UserId = f.UserId
    JOIN
        geoplace AS g ON f.placeID = g.placeID
    WHERE
        g.dress_code IS NOT NULL
    GROUP BY
        g.Restaurant_Name, g.dress_code)
SELECT
    d.Restaurant_Name,
    d.dress_code,
    MAX(UserCount) AS MaxUserCount
FROM
    DressCodeCounts AS d
WHERE
    d.UserCount = (SELECT MAX(UserCount) FROM DressCodeCounts WHERE dress_code = d.dress_code)                                                   
GROUP BY    d.Restaurant_Name, d.dress_code;                                                                                                  



	
/* Q 5) calculate average rating service, food  rating of top 20 
restaurants along with restaurant name (here rating are 0,1,2 only)*/

SELECT 
	(ge.Restaurant_Name) AS Restaurant_Name,
	avg(fr.rating) as avg_rating
FROM
	Geoplace ge
JOIN 
	final_rating fr
ON 
	ge.placeID=fr.placeID
GROUP BY
	Restaurant_Name
ORDER BY
	avg_rating
DESC limit 20;
        
/* Q6) Identify the restaurants that have the same cuisine as "Mexican" and
 also offer "alcohol" service. */

SELECT
	ge.restaurant_Name
FROM 
	geoplace ge
JOIN 
	chemozcuisine ch ON ge.placeID=ch.placeID
WHERE ch.Rcuisine = 'Mexican'
AND ge.alchol <> 'No_Alcohol_Served';




/* Q7) Find the most common method of payment used in each restaurant */

SELECT 
	up.Upayment,ge.restaurant_Name,
	count(up.userid) as Total_customer
FROM 
	  userpayment up
JOIN 
	final_rating fr ON   up.userId=fr.userid
JOIN 
	geoplace ge ON fr.placeID=ge.placeID
GROUP BY 
	up.Upayment,ge.restaurant_Name
ORDER BY
	Total_customer
DESC  LIMIT 20;

/* Q8)Find the restaurants that open earlier on sunday and closed late on sunday. */

SELECT 
	ge.restaurant_Name,
	MIN(Start_Time) as Restaurant_Opening_Time,
	MAX(End_Time) as  Restaurant_Closing_Time
FROM
	chefmozhours ch
JOIN  geoplace ge ON ch.placeID=ge.placeID
where days LIKE '%Sun%';


/* Q9) Find the marital_status,profession,budget of customers visiting top 20 resturants. */

SELECT 
		ge.restaurant_Name,
        up.userID,
        up.marital_status,
        up.activity,up.budget,
        count(up.userID) as Total_customer 
FROM 
	userprofile up
	JOIN 
		final_rating fr ON  up.userID = fr.userId
	JOIN 
		geoplace ge ON fr.placeID= ge.placeID
GROUP BY ge.restaurant_Name
ORDER BY total_customer DESC 
LIMIT 20;

/* Q10) Explore the Relationship Between Customer Visits and Purchase Price: */

SELECT 
    ge.price,
    count(up.userID) as total_customer
FROM 
	geoplace ge
JOIN 
	final_rating fr ON ge.placeID=fr.placeID
JOIN  
	userprofile up ON  fr.userID=up.userID
GROUP BY
	ge.price
ORDER BY
	total_customer DESC
LIMIT 20;

/*  Q11) Find Top 10 cuisine based on food_rating?   (here rating are 0,1,2 only) */

SELECT 
		ch.Rcuisine ,
        avg(fr.food_rating) as Average_rating
FROM 
	chemozcuisine ch
JOIN  
	final_rating fr ON  ch.placeID=fr.placeID
GROUP BY
		ch.Rcuisine
ORDER BY 
		Average_rating 
DESC LIMIT 10;

/* Q12) Find the top 3 users who have rated the most restaurants and list the number 
of restaurants they've rated.*/

WITH rankedUser AS (
	SELECT 
    userID,
    COUNT(*) AS num_ratings,
    RANK() OVER(ORDER BY COUNT(*) DESC) AS user_rank
    FROM 
		final_rating fr
	GROUP BY
		userID
)
SELECT 
     userID,
     num_ratings
FROM  rankedUser
WHERE 
	user_rank <=3;



/* Q13)Determine the users who have a rating pattern where their 
food ratings are consistently higher than their service ratings. */

SELECT f.userID as userID,
		AVG(f.food_rating) AS AVG_food_rating,
        AVG(f.service_rating) AS AVG_service_rating
FROM 
	final_rating AS f
GROUP BY 
	f.userID
HAVING 
	AVG(f.food_rating) > AVG(f.service_rating);

/* Q14) Find the  % share of Top 10 restaurant in terms of visiting customers. */

WITH RestaurantCustomerCounts AS (
    SELECT
        g.Restaurant_Name,
        COUNT(DISTINCT f.userID) AS CustomerCount
    FROM
        final_rating AS f
    JOIN
        geoplace AS g ON f.placeID = g.placeID
    GROUP BY
        g.Restaurant_Name
)

SELECT
    r.Restaurant_Name,
    r.CustomerCount,
    (r.CustomerCount / SUM(r.CustomerCount) OVER ()) * 100 AS PercentageShare
FROM
    RestaurantCustomerCounts AS r
ORDER BY
    r.CustomerCount DESC
LIMIT 10;



        

/* Q15) Determine the busiest day of the week for each restaurant based on the number of user visits.*/
WITH RestaurantVisits AS (
    SELECT
        f.placeID,
        h.days,
        COUNT(DISTINCT f.userID) AS UserVisits,
        RANK() OVER (PARTITION BY f.placeID ORDER BY COUNT(DISTINCT f.userID) DESC) AS VisitRank
    FROM
        final_rating AS f
    JOIN
        chefmozhours AS h ON f.placeID = h.placeID
    GROUP BY
        f.placeID, h.days)
SELECT
    rv.placeID,
    g.Restaurant_Name,
    rv.days AS Busiest_Day,
    rv.UserVisits AS UserVisits_Count
FROM
    RestaurantVisits AS rv
JOIN
    geoplace AS g ON rv.placeID = g.placeID
WHERE
    rv.VisitRank = 1
ORDER BY rv.UserVisits DESC  LIMIT 30;                                                                                                  

/* Q16) Most Customer preference based on parking lot  */

SELECT cp.parking_lot as Customer_parking,
		count(distinct up.userID) As Total_customers
FROM  
	chefmozparking AS cp
JOIN  
	final_rating AS fr 	ON cp.placID=fr.placeID
JOIN 
	userprofile AS up ON fr.userID=up.userID
GROUP BY 
		cp.parking_lot
ORDER BY  
		Total_customers Desc;
		

		
