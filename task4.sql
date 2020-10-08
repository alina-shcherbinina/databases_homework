--Создайте триггер на изменение цены в таблице товаров таким образом, чтобы в дополнительную таблицу сохранялись: 
--дата изменения, старая цена, новая цена.
--Дополнительную таблицу (это будет некий журнал изменения цен) нужно предварительно создать.

CREATE TABLE `recorded_prices` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`product_id` INT NOT NULL,
	`date` DATE,
	`old_price` INT,
	`new_price` INT,
	PRIMARY KEY (`id`)
);

ALTER TABLE `recorded_prices` ADD CONSTRAINT `recorded_prices_fk0` FOREIGN KEY (`product_id`) REFERENCES `products`(`id`);

DELIMITER // 
CREATE TRIGGER `save_prices` AFTER
UPDATE ON `products` FOR EACH ROW 
BEGIN    
    declare id int;
    declare date1 date;
    declare old_price int;
    declare new_price int;

    set id = OLD.`id`; 
    set date1 = NEW.`pchange`;
    set old_price = OLD.`price`;
    set new_price = NEW.`price`;

    insert into `recorded_prices` (`product_id`, `date`, `old_price`, `new_price`) values (id, date1, old_price, new_price);
END //
DELIMITER ;

--testing 
update `products` set `price` = 350, `pchange`=CURDATE() where `id` = 1;
select * from `products` limit 1;
select * from `recorded_prices`;

--Создайте триггер на удаление группы товаров таким образом,
--чтобы при ее удалении все товары из этой группы оказывались не привязанными ни к одной группе, 
--а их наличие на складе менялось в положение нет в наличии.

DELIMITER //
CREATE TRIGGER `remove_group`
BEFORE DELETE ON `groups`
FOR EACH ROW
BEGIN
	declare id int;

	set id = OLD.`id`;

    update `products` set `group` = null, `avail` = 0 where `group` = id;
END //
DELIMITER ;


