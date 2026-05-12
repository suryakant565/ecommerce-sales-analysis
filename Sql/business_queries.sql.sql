use project;

-- 1. What is total revenue over time (daily/monthly/yearly)?
select 
	  date_format(order_date , '%Y-%M') as order_date,
      sum(revenue) as total_revenue
from orders
group by order_date
order by order_date;
      
-- 2. Which product categories generate the highest revenue?
select 
	 p.category , 
	 round(sum(o.revenue)) as total_revenue
from orders o 
join products p on o.product_id = p.product_id
group by p.category
order by total_revenue desc;

-- 3. What are the top 10 products by revenue?
select p.product_id ,
	   sum(o.revenue) as total_revenue,
       count(o.order_id) as total_orders,
       sum(o.quantity) as total_quantity,
       p.category
from orders o 
join products p on o.product_id = p.product_id
group by p.product_id , p.category
order by total_revenue desc limit 10;

-- 4. What is the average order value (AOV)?
select 
      sum(revenue)/count(order_id) as avg_order_value
from orders;

-- 5. How does revenue vary by sales channel (Online vs Store)?
select channel_1 ,sum(revenue) as total_revenue
from orders
group by channel_1 
order by total_revenue;

-- 6. Which customer segments (age, gender) spend the most?
select
	  case
		  when c.age between 18 and 25 then '18-25'
          WHEN c.age BETWEEN 26 AND 35 THEN '26-35'
          WHEN c.age BETWEEN 36 AND 45 THEN '36-45'
          else '+46'
	  end as age_group,
      c.gender,
      sum(o.revenue) as total_revenue,
      avg(o.revenue) as avg_revenue,
      count(o.order_id) as total_orders
from orders o 
join customers c on o.customer_id = c.customer_id
group by age_group , c.gender
order by total_revenue desc;

-- 7. What is the repeat purchase rate?
SELECT 
    channel_1,
    COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_id END) * 100.0 
    / COUNT(DISTINCT customer_id) AS repeat_rate
FROM (
    SELECT customer_id, channel_1, COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id, channel_1
) t
GROUP BY channel_1;

-- 8. Which cities/regions generate the highest revenue?
select c.region, c.city , round(sum(o.revenue)) as total_revenue
from orders o 
join customers c on o.customer_id = c.customer_id
group by c.region, c.city
order by total_revenue desc;

-- 9. What is the customer lifetime value (CLV) distribution?

SELECT 
    clv_segment,
    COUNT(*) AS customer_count,
    AVG(clv) AS avg_clv,
    SUM(clv) AS total_revenue
FROM (
    SELECT 
        customer_id,
        SUM(revenue) AS clv,
        CASE 
            WHEN SUM(revenue) < 1000 THEN 'Low Value'
            WHEN SUM(revenue) BETWEEN 1000 AND 5000 THEN 'Medium Value'
            ELSE 'High Value'
        END AS clv_segment
    FROM orders
    GROUP BY customer_id
) t
GROUP BY clv_segment
ORDER BY round(total_revenue) DESC;

-- 10. How does signup date correlate with spending behavior?
select 
	  date_format(c.signup_date,'%y-%m') as signup_month,
      round(sum(o.revenue)) as total_revenue,
      count(distinct c.customer_id) as total_customers,
      round(sum(o.revenue) / count(distinct c.customer_id),2) as revenue_per_customer,
      round(avg(o.revenue)) as avg_order_value
from orders o
join customers c on o.customer_id = c.customer_id
group by signup_month
order by signup_month;
      
-- 11. Which categories have the highest demand (quantity sold)?
select p.category , sum(o.quantity) as total_quantity , count(distinct o.order_id) as total_orders
from orders o
join products p on o.product_id = p.product_id
group by p.category
order by total_quantity desc;

-- 12. What is the price vs quantity relationship?
select 
	   case
		   when price < 1000 then 'low Price'
           when price between 500 and 2000 then 'medium price'
           else 'high price'
	   end as price_range ,
sum(quantity) as total_quanity,
avg(quantity) as avg_quantity
from orders o
group by price_range;

-- 13. Which products are frequently discounted?
select 
	product_id,
    count(case when discount > 0 then 1 end) as discounted_orders,
    count(order_id) as total_orders,
    count(case when discount > 0 then 1 end) * 1.0 / count(order_id) as discount_rate
from orders
group by product_id
order by discount_rate;

-- 14. Do higher discounts actually increase sales volume?
select 
	case
		when discount <= 0 then 'No discount'
		when discount between 0.1 and 0.10 then 'low discount'
        when discount between 0.11 and 0.20 then 'modrate discount'
        else 'hight discount'
	end as discount_range,
    count(order_id) as total_orders,
    sum(quantity) as total_quantity,
    avg(quantity) as avg_quantity_per_order
from orders
group by discount_range
order by avg_quantity_per_order desc;

-- 15. Which payment methods are most used?
select payment_method , count(order_id) as total_orders ,round(sum(revenue)) AS total_revenue,
round(AVG(revenue)) AS avg_order_value
from orders
group by payment_method
order by total_orders desc;

-- 16. Does payment method impact order value?
SELECT 
    payment_method,
    COUNT(order_id) AS total_orders,
    SUM(revenue) AS total_revenue,
    AVG(revenue) AS avg_order_value
FROM orders
GROUP BY payment_method
ORDER BY avg_order_value DESC;

-- 17. Which channel + payment combinations drive the most revenue?
select channel_1 , payment_method , sum(revenue) as total_revenue
from orders
group by channel_1 , payment_method
order by total_revenue desc;

-- 18. Are there seasonal trends in orders and revenue?
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(order_id) AS total_orders,
    SUM(revenue) AS total_revenue
FROM orders
GROUP BY order_month
ORDER BY order_month;

-- 19. What is the trend of discount vs revenue over time?
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    AVG(discount) AS avg_discount,
    SUM(revenue) AS total_revenue,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_month
ORDER BY order_month;

-- 20. Which regions show declining or growing performance?
SELECT 
    c.region,
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    SUM(o.revenue) AS total_revenue,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id
GROUP BY c.region, order_month
ORDER BY c.region, order_month;






	