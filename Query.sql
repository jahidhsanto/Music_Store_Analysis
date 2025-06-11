/* ======================================== 1 - Easy ======================================== */

-- Q1: Who is the senior most employee based on job title?
SELECT EMPLOYEE_ID, TITLE, FIRST_NAME,	LAST_NAME
FROM EMPLOYEE
ORDER BY LEVELS DESC
LIMIT 1;

-- Q2: Which countries have the most Invoices?
SELECT billing_country
FROM invoice
GROUP BY billing_country
ORDER BY COUNT(billing_country) DESC
LIMIT 1;

-- Q3: What are top 3 values of total invoice?
SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
SELECT billing_city, SUM(total) AS invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY SUM(total) DESC
LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money. */
SELECT c.first_name, c.last_name, i.total AS total_spent
FROM customer c
LEFT JOIN invoice i	ON c.customer_id = i.customer_id
ORDER BY total_spent DESC
LIMIT 1;


/* ======================================== 2 - Moderate ======================================== */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT c.email, c.first_name, c.last_name, g.name
FROM customer c
JOIN invoice inv ON c.customer_id = inv.customer_id
JOIN invoice_line inv_l ON inv.invoice_id = inv_l.invoice_id
JOIN track t ON inv_l.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email ASC;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */
SELECT DISTINCT art.artist_id, art.name, count(art.artist_id) AS number_of_music 
FROM track t
JOIN genre g ON t.genre_id = g.genre_id
JOIN album al ON t.album_id = al.album_id
JOIN artist art ON al.artist_id = art.artist_id
WHERE g.name = 'Rock'
GROUP BY 1, 2
ORDER BY 3 desc
LIMIT 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
WITH avg_length AS (
	SELECT AVG(milliseconds) AS avg_ms
	FROM track
)
SELECT name, milliseconds
FROM track, avg_length
WHERE track.milliseconds > avg_length.avg_ms
ORDER BY milliseconds DESC;


/* ======================================== 3 - Advance ======================================== */

/* Q1: Find how much amount spent by each customer on top earned artists? Write a query to return customer name, artist name and total spent */
WITH top_earned_artist AS (
	SELECT art.artist_id, art.name, SUM(inv_l.unit_price * inv_l.quantity)
	FROM artist art
	JOIN album a ON art.artist_id = a.artist_id
	JOIN track t ON a.album_id = t.album_id
	JOIN invoice_line inv_l ON t.track_id = inv_l.track_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.first_name, c.last_name, art.name, SUM(inv_l.unit_price * inv_l.quantity)
FROM customer c
JOIN invoice inv ON c.customer_id = inv.customer_id
JOIN invoice_line inv_l ON inv.invoice_id = inv_l.invoice_id
JOIN track t ON inv_l.track_id = t.track_id
JOIN album a ON t.album_id = a.album_id
JOIN artist art ON a.artist_id = art.artist_id
JOIN top_earned_artist tea ON a.artist_id = tea.artist_id
GROUP BY 1, 2, 3
ORDER BY 4 DESC

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
WITH popular_genre AS(
	SELECT SUM(inv_l.quantity) AS purchases, c.country, g.name,
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY SUM(inv_l.quantity) DESC) AS RowNo
	FROM genre g
	JOIN track t ON g.genre_id = t.genre_id
	JOIN invoice_line inv_l ON t.track_id = inv_l.track_id
	JOIN invoice inv ON inv_l.invoice_id = inv.invoice_id
	JOIN customer c ON inv.customer_id = c.customer_id
	GROUP BY c.country, g.name
	ORDER BY 2 ASC
)
SELECT * 
FROM popular_genre
WHERE RowNo = 1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
WITH top_country_wise_customer AS (
	SELECT c.first_name, c.last_name, c.country, SUM(total) AS total_spend, 
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY SUM(total) DESC) AS RowNo
	FROM customer c
	JOIN invoice inv ON c.customer_id = inv.customer_id
	GROUP BY 1, 2, 3
	ORDER BY 3 ASC, 4 DESC
)
SELECT * 
FROM top_country_wise_customer 
WHERE RowNo = 1; 