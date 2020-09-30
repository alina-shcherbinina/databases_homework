CREATE TABLE `groups` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`name` varchar(255),
	PRIMARY KEY (`id`)
);

CREATE TABLE `products` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(255),
	`group` int,
	`price` INT,
	PRIMARY KEY (`id`)
);

CREATE TABLE `sales` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`date` DATE,
	`representative` int,
	`product` int,
	`quantity` INT,
	PRIMARY KEY (`id`)
);

CREATE TABLE `salesmen` (
	`salesman_id` INT NOT NULL AUTO_INCREMENT,
	`surname` VARCHAR(255) NOT NULL,
	`salary` INT,
	PRIMARY KEY (`salesman_id`)
);

ALTER TABLE `products` ADD CONSTRAINT `products_fk0` FOREIGN KEY (`group`) REFERENCES `groups`(`id`);

ALTER TABLE `sales` ADD CONSTRAINT `sales_fk0` FOREIGN KEY (`representative`) REFERENCES `salesmen`(`salesman_id`);

ALTER TABLE `sales` ADD CONSTRAINT `sales_fk1` FOREIGN KEY (`product`) REFERENCES `products`(`id`);


-- кол-во товаров каждой категории

select `group`, count(*) as `quantity` from `products` group by `group`;

-- среднюю цену товара каждой категории

select `group`, avg(`price`) as `average price` from `products` group by `group`;

-- общее количество единиц каждого товара проданного за все время
select `p`.`name`, sum(`s`.`quantity`) as  `all sold items` 
from `sales` as `s`, `products` as `p`
where `s`.`product` = `p`.`id`
group by `product`;

-- среднемесячное продаваемое количество единиц каждого товара

select `p`.`name`, count(`quantity`)/count(distinct(month(`s`.`date`))) as `average per month` 
from `sales` as `s` ,`products` as `p`
group by `p`.`name`;

-- отчет по продажам на каждый день каждого товара с указанием количества и выручки

select `s`.`date`, `s`.`product`, `s`.`quantity`,  `s`.`quantity` * `p`.`price` as `revenue`
from `sales` as `s`, `products` as `p`
group by `s`.`date`, `s`.`product`;

-- отчет по продажам на каждый день каждой товарной группы с указанием количества и выручки

select `s`.`date`, `p`.`group`, `s`.`quantity`,  `s`.`quantity` * `p`.`price` as `revenue`
from `sales` as `s`, `products` as `p`
group by `s`.`date`, `p`.`group`;

--кол-во товаров продаваемых каждым представителем в месяц 

 select `p`.`surname`, distinct(month(`s`.`date`)) as `month` , count(`quantity`) as `sales made`
 from `sales` as `s`, `salesmen` as `p`
 where `p`.`salesman_id` = `s`.`representative` 
 group by `representative`;

 -- среднемесячный оборот по каждому представителю 
select `m`.`surname`, (count(`quantity`) *  `p`.`price`)/count(distinct(month(`s`.`date`))) as `revenue` 
from `sales` as `s` ,`products` as `p`, `salesmen` as `m`
where `m`.`salesman_id` = `s`.`representative` 
group by `representative`;

 -- самых продаваемых товаров
select `p`.`name`, sum(`s`.`quantity`) as  `all sold items` 
from `sales` as `s`, `products` as `p`
where `s`.`product` = `p`.`id`
group by `s`.`product` order by `s`.`quantity` desc limit 5;

-- самых доходных групп товаров
select `p`.`name`, sum(`s`.`quantity`) * `p`.`price` as  `all sold items` 
from `sales` as `s`, `products` as `p`
where `s`.`product` = `p`.`id`
group by `p`.`group` order by `all sold items` desc limit 5;

-- успешных торговых представителей исходя из количества проданных товаров
select `p`.`surname`, `date`, count(`quantity`) as `sales made`
from `sales` as `s`, `salesmen` as `p`
where `p`.`salesman_id` = `s`.`representative` 
group by `representative` order by `sales made` desc;

-- успешных торговых представителей исходя из принесенного дохода
select `m`.`surname`, (count(`quantity`) *  `p`.`price`)/count(distinct(month(`s`.`date`))) as `revenue` 
from `sales` as `s` ,`products` as `p`, `salesmen` as `m`
where `m`.`salesman_id` = `s`.`representative` 
group by `representative` order by `revenue` desc;

-- успешных торговых представителей исходя из заработка
select `m`.`surname`, (((count(`quantity`) *  `p`.`price`)* 0.01 )+ `m`.`salary` ) as `revenue` 
from `sales` as `s` ,`products` as `p`, `salesmen` as `m`
where `m`.`salesman_id` = `s`.`representative` 
group by `representative` order by `revenue` desc;

-- ндфл
select `m`.`surname`, (((count(`quantity`) *  `p`.`price`)* 0.01 )+ `m`.`salary`) - (((count(`quantity`) *  `p`.`price`)* 0.01 )+ `m`.`salary` ) * 0.13 as `end salary`
from `sales` as `s` ,`products` as `p`, `salesmen` as `m`
where `m`.`salesman_id` = `s`.`representative` 
group by `representative`;