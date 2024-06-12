------------------Project Data analsysis----------------------
--1.find top 10 highest revenue generating products
select top 10 product_id, sum(sale_price) as revenue
from df_orders 
group by product_id
order by sum(sale_price) desc

---------------------------XXXXXXXXXXXXXXXXXXXXXXXXXXX----------------------------
--2.find top 5 highest selling products in each region
with cte as(
select product_id, region, sum(sale_price) as sales
from df_orders
group by product_id, region
)
select * from (
select *,
RANK() over(partition by region order by sales desc) as rnk
from cte ) A
where A.rnk <= 5

-----------------------------XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX----------------------------
--3.find month over month growth comparsion for 2022 and 2023 sales eg: jan2022 vs jan 2023
with cte as (
select YEAR(order_date) as order_year,month(order_date) as order_month,sum(sale_price) as sales from df_orders
group by YEAR(order_date), month(order_date)
--order by YEAR(order_date), month(order_date)
)
select order_month
,sum(case when order_year = '2022' then sales else 0 end) as sales_2022
,sum(case when order_year = '2023' then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month

----------------------------XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX----------------------------
--4.for each category which month has highest sales
with cte as (
select YEAR(order_date) as order_year, month(order_date) as order_month
,category, sum(sale_price) as sales
from df_orders
group by YEAR(order_date),month(order_date),category
)
select * from (
select *,
ROW_NUMBER() over(partition by category order by sales desc) as rnk
from cte) A
where A.rnk <= 1


------------------------------XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX--------------------------------
--5.Which sub-category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category,YEAR(order_date) as order_year,sum(sale_price) as sales from df_orders
group by YEAR(order_date), sub_category
--order by YEAR(order_date), month(order_date)
)
,cte2 as(
select sub_category
,sum(case when order_year = '2022' then sales else 0 end) as sales_2022
,sum(case when order_year = '2023' then sales else 0 end) as sales_2023
from cte
group by sub_category
)
select top 1 *, (sales_2023-sales_2022)*100/sales_2022 as growth_percentage
from cte2
order by (sales_2023-sales_2022)*100/sales_2022 desc