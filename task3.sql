--Функция, определяющая по дате рождения, является ли человек юбиляром в текущем году. 
--Функция возвращает возраст юбиляра, в противном случае – NULL.

DELIMITER //
CREATE FUNCTION `jubilee`(s date)
RETURNS INTEGER
BEGIN
 declare age int;
 set age = year(now()) - year(s); 
 if mod(age) = 0 then
 	return age;
 else 
 	return null;
 end if;
 END//
DELIMITER ;

select `jubilee`('2000-09-28'),`jubilee`('1999-09-28');
select `jubilee`(`dateofbirth`) from salesmen;

--Функция, преобразующая значение ФИО в фамилию с инициалами (например, Иванов Иван Сергеевич в Иванов И.С.).
--При невозможности преобразования функция возвращает строку ######.


DELIMITER //
CREATE FUNCTION `short_name`(name char(25), middle char(25), surname char(25))
RETURNS char(50)
BEGIN
  declare help1 char(25);
  declare result char(70);
  set help1 = concat_ws('. ', left(name, 1), left(middle,1));
  set result = concat(concat_ws(' ', surname, help1), '.'); 
  if length(surname) < 1 or length(name) < 1 or length(middle) < 1 then 
  	return '######';  
  else 
  	return result;
  end if;
 END//
DELIMITER ;


select `short_name`('Will', 'Hugh', 'Graham'), `short_name`('', '', 'Graham');
select `short_name`(`name`, `middlename`, `surname`) from salesmen

--Функция, высчитывающая доход торгпреда с продажи, исходя из ставки и суммы продажи.

DELIMITER //
CREATE FUNCTION `personal_income`(id int, st double, quantity int, sprice int)
RETURNS decimal
BEGIN
	declare profit decimal;
	declare summ int;
	set summ = quantity * sprice;
	set profit = summ * st; 
	return profit;
 END//
DELIMITER ;

select `representative`, `personal_income`(`sales`.`id`,`salesmen`.`salary`, `sales`.`quantity`, `sales`.`sprice`) 
from sales, salesmen

--Функция, высчитывающая доход компании с продажи, исходя из стоимости товара и проданного количества.

DELIMITER //
CREATE FUNCTION `general_income`(quantity int, sprice int)
RETURNS decimal
BEGIN
	declare summ decimal;
	set summ = quantity * sprice;
	return summ;
 END//
DELIMITER ;

select `general_income`(`sales`.`quantity`, `sales`.`sprice`) 
from sales
limit 15;

--Процедура, выводящая список всех торгпредов–юбиляров текущего года (с указанием даты юбилея и возраста).

INSERT INTO `salesmen` (`surname`, `name`, `middlename`, `dateofbirth`, `INN`, `salary`, `sfixed`)
VALUES ('Graham', 'Will', NULL, '1980-09-28', NULL, '0.6', '6000');


DELIMITER //
CREATE PROCEDURE `salesmen_jubilee`()
BEGIN
 	select `surname`, `jubilee`(`dateofbirth`),  year(now()) - year(dateofbirth) as `age`
 	from `salesmen`
 	where jubilee(`dateofbirth`) != -1;
END//
DELIMITER ;

call `salesmen_jubilee`() 


--Процедура, выводящая список всех товаров в заданной группе (по id группы) 
--в виде: товар, группа, артикул, отпускная цена, наличие на складе.

DELIMITER //
CREATE PROCEDURE `products_group`(in id int)
BEGIN
 	select `groups`.`id`, `p`.`name`, p.article, p.price, p.avail
 	from `groups`, `products` as p
 	where `groups`.`id` = id;
END//
DELIMITER ;

call `products_group`(1) 

--Процедура, выдающая по названию товара, список его продаж с указанием ФИО торгпреда (в формате Фамилия И.О.) 
--за последние 7 дней (по умолчанию) / 14 дней / 30 дней.

DELIMITER //
CREATE PROCEDURE `sale_by_name`(in name varchar(255), days int)
BEGIN
	if days is null then 
	set days = 7;
	end if;

 	select  `short_name`(`m`.`name`, `m`.`middlename`, `m`.`surname`) as `salesman`, s.date,  `p`.`name`
 	from `sales` as s, `products` as p, `salesmen` as `m`
 	where s.representative = m.salesman_id and s.product = p.id and p.name = name and timestampdiff(day, s.date,now()) <= days;
END//
DELIMITER ;

call `sale_by_name`('skirt', 140) 

--Процедура, выводящая сведения о несоответствии цены в журнале продаж заявленной цене самого товара с учетом времени последнего изменения цены 
--(если изменение цены произошло позднее даты продажи, такие данные не учитывать). 
--Если таких случаев не обнаружено, процедура должна выводить сообщение об этом.

DELIMITER //
CREATE PROCEDURE `price_isnt_equal`()
BEGIN
	if (select count(p.id)
        from products as p, sales as s
        where p.id = s.product
        and s.sprice != p.price ) then

	select p.name, s.sprice, p.price, s.date
        from products as p, sales as s
        where p.id = s.product
        and s.sprice != p.price;
	else
	select "No inconsistencies were found";
	end if;
END//
DELIMITER ;

call `price_isnt_equal`();