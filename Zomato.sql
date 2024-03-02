/* ---------------------------------------------------------------
1.what is total amount each customer spent on zomato ?
2.How many days has each customer visited zomato?
3.what was the first product purchased by each customer?
4.what is most purchased item on menu & how many times was it purchased by all customers ?
5.which item was most popular for each customer?
6.which item was purchased first by customer after they become a member ?
7. which item was purchased just before the customer became a member?
8. what is total orders and amount spent for each member before they become a member?
9. If buying each product generates points for eg 5rs=2 zomato point 
  and each product has different purchasing points for eg for p1 5rs=1 zomato point,
  for p2 10rs=1 zomato point and p3 5rs=1 zomato point else 2rs =1zomato point, 
  calculate points collected by each customer and for which product most points have been given till now.
-------------------------------------------------------------------- */

-- --------------------------------------
select * from goldusers_signup;
select * from sales;
select * from product;
select * from users;
-- ---------------1) Answer----------------------

select s.userid, sum(p.price) as TotalSpend from sales s
left join product p on s.product_id = p.product_id
group by s.userid;
-- user with id 1,2,3 spent total amount of 5230,4570,2510 on zomato respectively.
-- --------------2) Answer------------------------

select userid, count(distinct created_date) as Visits from sales
group by userid;
-- user with id 1,2,3 have visited zomato for 7,4,5 days respectively.

-- ------------ 3) Answer---------------------------

with cte as(
select userid,created_date,product_id, row_number()over(partition by userid order by created_date) as firstpurchase from sales)

select userid, created_date, product_id from cte 
where firstpurchase =1;
-- first product purchased by users with id 1,2,3 are products with id 1,1,1 respectively.

-- ------------ 4) Answer---------------------------

select product_id, count(product_id) as purchases from sales
group by product_id
order by purchases desc
limit 1;
-- product_id 2 has most purchases which is 7 times.

-- ------------ 5) Answer---------------------------

with cte1 as (select userid, product_id, row_number() over(partition by userid order by count(product_id) desc) as rn from sales
group by userid, product_id
order by userid asc, count(product_id) desc)

select userid, product_id from cte1
where rn =1;
-- for user 1,2,3 products with id 2,3,2 were purchased most of the time i.e their favourite products.

-- ------------ 6) Answer---------------------------

with cte2 as (select s.userid,s.created_date,s.product_id,g.gold_signup_date, row_number() over(partition by gold_signup_date order by created_date) as early from sales s 
join goldusers_signup g on s.userid = g.userid
where created_date> gold_signup_date
order by created_date asc)

select * from cte2 where early =1 order by userid;
-- First purchase after buying gold membership by user 1 and 3 are of products 3,2 on '2018-03-19','2017-12-07' respectively.

-- ------------ 7) Answer---------------------------

with cte3 as (select s.userid,s.created_date,s.product_id,g.gold_signup_date, row_number() over(partition by gold_signup_date order by created_date desc) as early from sales s 
join goldusers_signup g on s.userid = g.userid
where created_date< gold_signup_date
order by created_date asc)

select * from cte3 where early =1 order by userid;
-- First purchase before buying gold membership by user 1 and 3 are of products 2,2 on '2017-04-19','2016-12-20' respectively.

-- ------------ 8) Answer---------------------------

with cte4 as (select s.userid,s.created_date,s.product_id,g.gold_signup_date from sales s 
join goldusers_signup g on s.userid = g.userid
where created_date< gold_signup_date
order by s.userid)

select cte4.userid, count(cte4.product_id) as Total_Products, sum(p.price) as Total_spent from cte4
left join product p on cte4.product_id = p.product_id
group by cte4.userid;
-- Users 1 and 3 have bough total 5 and 3 products while spending 4030 and 2720 respectively before buying gold membership.

-- ------------ 9) Answer---------------------------

with t as(
select s.userid, s.product_id, count(p.product_id) as purchases, p.price, (count(p.product_id) * p.price) as amount 
from sales s
left join product p on p.product_id = s.product_id
group by s.userid, s.product_id,p.price
order by s.userid)

select * , 
case 
when product_id = 1 then round(amount/5,2)
when product_id = 2 then round(amount/10,2)
when product_id = 3 then round(amount/5,2)
else round(amount/2,2) end as points
from t
order by userid asc, points desc;
-- We can see that user 1,2,3 earned most points as 392,196,392 on products with id 1,1,1 respectively. 

