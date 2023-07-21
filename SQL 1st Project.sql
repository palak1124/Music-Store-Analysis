 /* que 1 Who is the senior most employee based on job title? */
 
 SELECT title, last_name , FIRST_NAME
 FROM employee 
 order by levels desc limit 1;
 
/* que 2  Which countries have the most Invoices? */

select count(invoice_id) as A, billing_country 
from invoice 
group by billing_country
order by count(invoice_id) desc 
limit 1;

/* que 3  What are top 3 values of total invoice? */ 

select total
from  invoice
order by total desc 
limit 3;  

/* que 4 Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city, sum(total) as Total_sales 
from invoice 
group by billing_city 
order by Total_sales desc 
limit 1;

/* que 5 Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money. */ 

select customer.customer_id, first_name, last_name, sum(total) as spending
from customer 
full join invoice  on customer.customer_id= invoice.customer_id 
group by customer.customer_id
order by spending  desc limit 1; 

/* que 6 Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
 
select distinct customer.email, customer.first_name, customer.last_name, genre.name as genre_nane from customer
join invoice on customer.customer_id= invoice.customer_id 
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id= track.track_id
join genre on track.genre_id= genre.genre_id
	where genre.name like'Rock'
order by email ;

/* que 7 Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands.*/

SELECT A.artist_id, A.name, COUNT(A.artist_id) as num_tracks
FROM artist AS A
JOIN album ON A.artist_id = album.artist_id
JOIN track ON album.album_id = track.album_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY A.artist_id, A.name
ORDER BY num_tracks DESC
LIMIT 10;

/* que 8 Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.  */

select track.name, track.milliseconds as song_length
from track
where milliseconds >(select avg(milliseconds) as avg_milliseconds  from track)
order by song_length desc ;
 
/* que 9  Find how much amount spent by each customer on artists?
Write a query to return customer name, artist name and total spent */

 WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* que 10  We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with popular_genre as(
select  count(invoice_line.quantity) as Purchases,  customer.country, genre.name,
row_number()  over(partition by customer.country order by sum(invoice.total) desc ) from genre
inner join track on track.genre_id= genre.genre_id
inner join invoice_line on invoice_line.track_id = track.track_id
inner join invoice on invoice.invoice_id = invoice_line.invoice_id
inner join customer on customer.customer_id = invoice.customer_id
group  by customer.country, genre.name
order by  customer.country asc, genre.name desc)
select * from popular_genre where row_number<=1;

/* que 11  Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with customer_with_country as
(select customer.customer_id, customer.first_name, customer.last_name, customer.country, sum(total),
 row_number() over(partition by country order by sum(total))
 from customer  join invoice as i on customer.customer_id= i.customer_id
 group by 1,2,3,4
 order by 4 asc , 1 desc)
 select * from customer_with_country where row_number <=1 ;
 