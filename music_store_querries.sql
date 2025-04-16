--Q.1 Who is the senior most employee based on job title?

select * from employee
order by levels desc 
limit 1

--Q.2 Which countries have the most invoices?

select billing_country, count(*) from invoice
group by billing_country
order by count(*) desc

--Q.3 What are top 3 values of total invoice?

select total from invoice
order by total desc
limit 3

--Q.4. Which  city  has  the  best  customers?  
--We  would  like  to  throw  a  promotional  Music Festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals.
--Return both the city name & sum of all invoice totals

select billing_city, sum(total) as total_invoices from invoice
group by billing_city
order by total_invoices desc
limit 1

--Q.5. Who  is  the  best  customer?
--The  customer who  has  spent  the  most  money  will  be declared the best customer. 
--Write a query that returns the person who has spent the most money

select c.customer_id,c.first_name, c.last_name, sum(total) as total_invoices from customer as c
inner join invoice as i
on c.customer_id=i.customer_id
group by c.customer_id,c.first_name, c.last_name
order by total_invoices desc
limit 1

--Q.6. Write query to  return the email, first  name,  last  name, &  Genre of all  Rock  Music listeners. 
--Return your list ordered alphabetically by email starting with A

select distinct c.email, c.first_name, c.last_name from customer as c
inner join invoice as i on c.customer_id=i.customer_id
inner join invoice_line  as l on i.invoice_id=l.invoice_id
where track_Id In(select track_Id from track as t
				left join genre as g on t.genre_Id=g.genre_Id
				where g.name='Rock' )
order by email

--Q.7.Let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands

select ar.name as artist_name, count(*) as track_count from track as t
inner join album as a on t.album_id=a.album_id
inner join artist as ar on a.artist_id=ar.artist_id
where track_Id In(select track_Id from track as t
				left join genre as g on t.genre_Id=g.genre_Id
				where g.name='Rock' )
group by artist_name
order by track_count desc
limit 10

--Q.8 Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. 
--Order by the song length with the longest songs listed first

select name, milliseconds from track
where milliseconds>(select avg(milliseconds) as avg_song_length from track )
order by milliseconds desc

--Q.9 Find how much amount spent by each customer on artists? 
--Write a query to return customer name, artist name and total spent

with best_selling_artist as (
	select ar.artist_id, ar.name as artist_name, sum(l.unit_price*l.quantity) as total_sales
	FROM invoice_line as l
	inner join track as t on t.track_id = l.track_id
	inner join album as a on a.album_id = t.album_id
	inner join artist as ar on ar.artist_id = a.artist_id
	GROUP BY ar.artist_id, artist_name
	ORDER BY total_sales DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(l.unit_price*l.quantity) as amount_spent
FROM invoice as i
JOIN customer as c ON c.customer_id = i.customer_id
JOIN invoice_line as l ON l.invoice_id = i.invoice_id
JOIN track as t ON t.track_id = l.track_id
JOIN album as a ON a.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = a.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;

--Q.10 We want to find out the most popular music Genre for each country. 
--We determine the most popular genre as the genre with the highest amount of purchases. 
--Write a query that returns each country along with the top Genre. 
--For countries where the maximum number of purchases is shared return all Genres

with popular_genre as
(
    select count(l.quantity) as purchases, c.country, g.name, g.genre_id, 
	row_number() over(partition by c.country order by count(l.quantity) desc) as rowno 
    from invoice_line as l
	inner join invoice as i on i.invoice_id = l.invoice_id
	inner join customer as c on c.customer_id = i.customer_id
	inner join track as t on t.track_id = l.track_id
	inner join genre as g on g.genre_id = t.genre_id
	group by c.country, g.name, g.genre_id
	order by c.country asc, purchases desc
)
select * from popular_genre where rowno <= 1

--Q.11 Write a query that determines the customer that has spent the most on music for each country. 
--Write aquery that returns the country along with the top customer and how much they spent.  
--For countries where the top  amount spent is shared,  provide all customers who spent this amount

with customer_with_country as (
		select c.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
	    row_number() over(partition by billing_country order by sum(total) desc) as rowno 
		from invoice as i
		inner join customer as c on c.customer_id = i.customer_id
		group by c.customer_id,first_name,last_name,billing_country
		order by billing_country asc, total_spending desc
		)
select * from customer_with_country where rowno <= 1
