-- Exploring data 

select * 
from production.brands

select * 
from production.categories


select * 
from production.products


select * 
from production.stocks

select * from 
sales.customers


select * from 
sales.order_items


select * from 
sales.orders

select * from 
sales.staffs


select * from 
sales.stores

--1 Which bike is most expensive? What could be the motive behind pricing this bike at the high price?
select top 1 product_name , list_price 
from production.products
order by list_price DESC

-- because this bike from the most expensive category and brand and from a new model
--2 How many total customers does BikeStore have? Would you consider people with order status 3 as customers substantiate your answer?

select	count(distinct customer_id) as '#Customers'
from sales.customers

--3 How many stores does BikeStore have?
select count(store_id) '#Stores' from 
sales.stores

--4 What is the total price spent per order?

select order_id,(list_price*quantity*(1 - discount)) as Total_Sales from 
sales.order_items
order by Total_Sales DESC

--5 What’s the sales/revenue per store?

select S.store_name, sum((list_price*quantity*(1 - discount))) as Sales_Revenue 
from sales.order_items OI
join sales.orders O on OI.order_id = O.order_id
join sales.stores S on O.store_id = S.store_id 
group by rollup(store_name)
order by Sales_Revenue ASC

--6 Which category is most sold?

select top 1 C.category_name ,  sum(quantity) 'Quantity Sold' 
from sales.order_items OI
join production.products P on OI.product_id = P.product_id
join production.categories C on P.category_id = C.category_id
group by C.category_name
order by [Quantity Sold] DESC

--7 Which category rejected more orders?


select top 1 C.category_name ,  sum(quantity) 'Quantity Sold' 
from sales.order_items OI
join production.products P on OI.product_id = P.product_id
join production.categories C on P.category_id = C.category_id
where OI.order_id in(select order_id from Sales.orders where order_status = 3)
group by C.category_name
order by [Quantity Sold] DESC


--8 Which bike is the least sold?

select product_name , sum(quantity) 'Units Sold'
from sales.order_items O
join production.products P on O.product_id = P.product_id
group by product_name
ORDER BY [Units Sold]

-- 9 What’s the full name of a customer with ID 259?

select concat(first_name,' ' , last_name) 'Customer name'
from sales.customers
where customer_id = 259

-- 10 What did the customer on question 9 buy and when? What’s the status of this order?

select product_name ,  order_date ,
case when order_status = 4 then 'Completed'
when order_status = 3 then 'rejected'
when order_status = 2 then 'Processing'
else 'Pending'
end as 'Order Status'
from sales.orders O
join sales.order_items OI 
on O.order_id = OI.order_id
join production.products P on OI.product_id = P.product_id 
where customer_id = 259

-- 11 Which staff processed the order of customer 259? And from which store?

select concat(first_name , ' ' ,last_name) as 'Staff Name' , store_name
from sales.orders O
join sales.staffs Sf on O.staff_id = Sf.staff_id
join sales.stores S on O.store_id = S.store_id 
where customer_id = 259

-- 12 How many staff does BikeStore have? Who seems to be the lead Staff at BikeStore
select count(distinct staff_id) '#Staffs'
from sales.staffs

select concat(first_name , ' ' ,last_name) 'Staff Name'
from sales.staffs
where manager_id is null

--Fabiolo Jackson seems to be the lead because he has no manager

-- 13 Which brand is the most liked?
 
-- to know the most liked brand we may look at the number of Unit Sold

select top 1 brand_name , sum(quantity) 'Units Sold'
from sales.order_items O
join production.products P on O.product_id = P.product_id
join production.brands B on P.brand_id = B.brand_id
group by brand_name 
order by [Units Sold] DESC


-- 14 How many categories does BikeStore have, and which one is the least liked?

-- we can notice the least liked also by looking at units Sold

select count(distinct Category_id) '#Categories'
from production.categories 

select top 1 category_name , sum(quantity) 'Units Sold'
from sales.order_items O
join production.products P on O.product_id = P.product_id
join production.categories C on P.category_id= C.category_id
group by category_name 
order by [Units Sold] ASC


-- 15 Which store still have more products of the most liked brand?

select top 1 store_name, sum(quantity) '#products'
from production.stocks S
join production.products P
on S.product_id = P.product_id
join production.brands B
on P.brand_id = B.brand_id
join sales.stores ST
on S.store_id = ST.store_id
where P.brand_id = (select brand_id from production.brands where brand_name like 'Electra')
group by store_name
order by #products DESC

-- 16 Which state is doing better in terms of sales?

select top 1 state, sum((list_price*quantity*(1 - discount))) as Sales_Revenue
from Sales.order_items OI
join Sales.orders O 
on OI.order_id = O.order_id
join sales.stores S
on  O.store_id = S.store_id
group by state 
order by Sales_Revenue DESC


--17 What’s the discounted price of product id 259?

select quantity,list_price ,discount , list_price *(1- discount) 'Discounted Price'
from Sales.order_items
where product_id = 259

-- product 259 appear twice , one with 0.07 discount and another with 0.20 discount
-- and that can be explained by as quantity increases --> the discount increase 

-- 18 What’s the product name, quantity, price, category, model year and brand name of product number 44?

select product_name , list_price , category_name , brand_name,model_year , sum(quantity) 'Quantity' 
from production.products P
join production.categories C on P.category_id = C.category_id
join production.brands B on P.brand_id = B.brand_id
join production.stocks S on P.product_id = S.product_id
where P.product_id = 44
group by product_name  , list_price , category_name , brand_name,model_year


--19 What’s the zip code of CA?

select State , zip_code
from sales.stores
where State like 'CA'

-- 20 How many states does BikeStore operate in?

select count(distinct state) '#States'
from sales.stores

-- 21 How many bikes under the children category were sold in the last 8 months?

declare @maxdate date; 
select  @maxdate =  max(order_date) from Sales.orders

select sum(quantity) 'Units Sold'
from Sales.order_items OI
join Sales.orders O
on OI.order_id = O.order_id
join production.products P
on OI.product_id = P.product_id
join production.categories C
on P.category_id = C.category_id
where category_name like 'Children%' and 
O.order_date > DATEADD(month,-8,@maxdate) 


-- 22 What’s the shipped date for the order from customer 523

select shipped_date
from sales.orders
where customer_id = 523

--  23 How many orders are still pending?

select count(distinct order_id) '#Pending orders'
from sales.orders 
where order_status = 1

-- 24 What’s the names of category and brand does "Electra white water 3i - 2018" fall under?

select product_name , brand_name , category_name 
from production.products P
join production.brands B
on P.brand_id = B.brand_id
join production.categories C
on P.category_id = C.category_id
where product_name like 'Electra white Water 3i - 2018'

