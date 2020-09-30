--Торговым представителям добавьте поля:
select * from salesmen
--имя (после фамилии)
alter table `salesmen`
add `name` varchar(255)
after surname;

update salesmen set name = 'John' where salesman_id =1; 
update salesmen set name = 'Rob' where salesman_id =2; 
update salesmen set name = 'William' where salesman_id =3; 
update salesmen set name = 'Zoe' where salesman_id =4; 
update salesmen set name = 'FKA' where salesman_id =5; 

--отчество (после имени)

alter table `salesmen`
add `middlename` varchar(255)
after name;

update salesmen set middlename = 'David' where salesman_id =1; 
update salesmen set middlename = 'Douglas Thomas' where salesman_id =2; 
update salesmen set middlename = 'James' where salesman_id =3; 
update salesmen set middlename = 'Isabella' where salesman_id =4; 
update salesmen set middlename = 'Debrett' where salesman_id =5; 

--дата рождения (после отчества)

alter table `salesmen`
add `dateofbirth` date 
after middlename

update salesmen set dateofbirth = '1976-01-01' where salesman_id =1; 
update salesmen set dateofbirth = '1986-05-13' where salesman_id =2; 
update salesmen set dateofbirth = '1955-07-22' where salesman_id =3; 
update salesmen set dateofbirth = '1988-12-01' where salesman_id =4; 
update salesmen set dateofbirth = '1988-01-16' where salesman_id =5; 

--ИНН (после даты рождения)

alter table salesmen
add INN BIGINT(12)
after dateofbirth

update salesmen set INN = '277529332955' where salesman_id =1; 
update salesmen set INN = '437001865714' where salesman_id =2; 
update salesmen set INN = '227073861612' where salesman_id =3; 
update salesmen set INN = '597461619036' where salesman_id =4; 
update salesmen set INN = '396670284481' where salesman_id =5; 

--сумма оклада (после ставки)

alter table salesmen
add sfixed int
after salary;

update salesmen set sfixed = '5000' where salesman_id =1; 
update salesmen set sfixed = '5000' where salesman_id =2; 
update salesmen set sfixed = '5000' where salesman_id =3; 
update salesmen set sfixed = '5000' where salesman_id =4; 
update salesmen set sfixed = '5000' where salesman_id =5; 

--Товарам:

select * from products

--закупочная цена (перед ценой)
--заполнить по всем товарам закупочную цену с коэффициентом 0.5

alter table products 
add ogprice int 
after group;

update products set ogprice = price * 0.5;

--артикул (после названия)

alter table products
add article int
after name

update products set article = FLOOR(RAND()*(100-1+1)+1);
--флаг наличия на складе

alter table products
add `avail` bool
after name

update products set avail = FLOOR(RAND()*(1-0+1)+0);

--дата изменения цены

alter table products
add `pchange` date
after price

--В журнал продаж:

select * from sales limit 10

--цену (перед количеством)

alter table sales
add sprice int
after product

--заполнить цену по данным из таблицы товаров

update sales , products set sales.sprice = products.price where sales.product = products.id; 

--доход компании (после количества)

alter table sales
add profit int
after quantity

--заполнить все проданные по данным из таблицы товаров (кол-во * цену)

update sales set profit = quantity * sprice;

/*у меня возникли проблемы со ставкой я переделала ее*/
alter table salesmen drop `salary`;

alter table salesmen
add `salary` double;

update salesmen set salary = '0.1' where salesman_id =1; 
update salesmen set salary = '0.2' where salesman_id =2; 
update salesmen set salary = '0.3' where salesman_id =3; 
update salesmen set salary = '0.4' where salesman_id =4; 
update salesmen set salary = '0.5' where salesman_id =5; 

--доход торгпреда (после дохода компании)

alter table sales
add manprofit int
after profit

--заполнить все проданные по данным из таблицы товаров и с учетом ставки соответствующего торгпреда*/

update sales, salesmen 
set sales.manprofit = (sales.quantity * sales.sprice) * salesmen.salary 
where sales.representative = salesmen.salesman_id ;