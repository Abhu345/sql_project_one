3.a) select *from customers where Address  like '%NewYork';

b) select *from pizzas where price is not null;

c) select *from orders inner join orderitems on orders.orderid=orderitems.orderid inner join pizzas 
   on orderitems.pizzaid=pizzas.pizzaid where orders.customerid=2;

d)select *from orders inner join orderitems on orders.orderid=orderitems.orderid inner join pizzas  
  on orderitems.pizzaid=pizzas.pizzaid where orderitems.Subtotal>50;

e)select *from delivery where deliverystatus='completed';

4.a)select customers.customerid,customers.firstname,customers.lastname,payments.paymentamount from customers inner join payments  
    on customers.CustomerID=payments.paymentid;

b)select pizzaname,sum(quantity) over(partition by pizzaname)order_count from pizzas inner join orderitems 
    on pizzas.pizzaid=orderitems.pizzaid order by order_count desc limit 1;

b)select pizzaname,sum(quantity)order_count from pizzas inner join orderitems 
    on pizzas.pizzaid=orderitems.pizzaid group by pizzaname order by order_count desc limit 1;

c) select avg(paymentamount)from payments;

c)select pizzas.pizzaid,pizzaname,avg(price) over(partition by pizzaname)avg_price from pizzas inner join orderitems on pizzas.pizzaid=orderitems.pizzaid;

c)select pizzas.pizzaid,pizzaname,avg(price) from pizzas inner join orderitems on pizzas.pizzaid=orderitems.pizzaid group by pizzaname;

d)select pizzas.pizzaid,pizzaname,quantity from pizzas inner join orderitems on pizzas.pizzaid=orderitems.pizzaid;

e)select pizzasize,sum(quantity)order_count from pizzas inner join orderitems 
    on pizzas.pizzaid=orderitems.pizzaid group by pizzasize;

5.a)select *from customers where customerid not in(select customerid from orders);

b)select *from orders where totalprice=(select max(totalprice)from orders);

c)select *from pizzatoppings natural join ordertoppings where pizzatoppings.toppingname='cheese';

d)select *from orders where orderdate>=curdate()-orderdate;

e)select *from orderitems where orderid=(select max(orderid)from orderitems);

6.a)update orders set Status='Delivered' where orderid=2;

b)update pizzas set price =15 where pizzaname='margherita';

c)alter table pizzatoppings drop column toppingname;

d)alter table customers drop column customerid;

7.a)delimiter //
create trigger price_update
after insert on orderitems
for each row
begin
update Orders
set totalprice = totalprice + new.subtotal
where orderid = new.orderid;
end //
delimiter ;

b)delimiter //
create procedure total_earning()
begin
select sum(totalprice)from orders where MONTH(STR_TO_DATE(orderdate, '%d-%m-%Y'))=6 and status='Delivered';
end //
delimiter ;

c)create index improve_performance on orders(orderid,customerid);