DROP TABLE IF EXISTS `delivered`;
DROP TABLE IF EXISTS `stored`;
DROP TABLE IF EXISTS `moved`;
DROP TABLE IF EXISTS `sold`;
DROP TABLE IF EXISTS `payment`;
DROP TABLE IF EXISTS `product`;
DROP TABLE IF EXISTS `producttype`;
DROP TABLE IF EXISTS `worker`;
DROP TABLE IF EXISTS `shop`;
DROP TABLE IF EXISTS `companies`;


CREATE TABLE `product`
(
  `id` int PRIMARY KEY ,
  `producttype_id` int,
  `name` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL
);

CREATE TABLE `shop`
(
  `id` int PRIMARY KEY ,
  `location` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL
);

CREATE TABLE `stored`
(
  `product_id` int,
  `shop_id` int,
  `amount` int
);

CREATE TABLE `worker`
(
  `id` int PRIMARY KEY ,
  `shop_id` int,
  `fullname` varchar(255) NOT NULL,
  `salary` int NOT NULL
);

CREATE TABLE `sold`
(
  `product_id` int,
  `worker_id` int,
  `solddate` datetime NOT NULL,
  `soldprice` int NOT NULL
);

CREATE TABLE `delivered`
(
  `product_id` int,
  `amount` int NOT NULL,
  `shop_id` int,
  `worker_id` int,
  `notes` varchar(255),
  `price` int NOT NULL,
  `company_id` int
);

CREATE TABLE `companies`
(
  `id` int PRIMARY KEY ,
  `name` varchar(255)
);

CREATE TABLE `moved`
(
  `from_shop_id` int,
  `to_shop_id` int,
  `mowedate` datetime,
  `product_id` int,
  `amount` int
);

CREATE TABLE `producttype`
(
  `id` int PRIMARY KEY ,
  `name` varchar(255)
);

CREATE TABLE `payment`
(
  `worker_id` int,
  `paied` int,
  `paydate` datetime
);

ALTER TABLE `product` ADD FOREIGN KEY (`producttype_id`) REFERENCES `producttype` (`id`);

ALTER TABLE `stored` ADD FOREIGN KEY (`product_id`) REFERENCES `product` (`id`);

ALTER TABLE `stored` ADD FOREIGN KEY (`shop_id`) REFERENCES `shop` (`id`);

ALTER TABLE `worker` ADD FOREIGN KEY (`shop_id`) REFERENCES `shop` (`id`);

ALTER TABLE `sold` ADD FOREIGN KEY (`product_id`) REFERENCES `product` (`id`);

ALTER TABLE `sold` ADD FOREIGN KEY (`worker_id`) REFERENCES `worker` (`id`);

ALTER TABLE `delivered` ADD FOREIGN KEY (`product_id`) REFERENCES `product` (`id`);

ALTER TABLE `delivered` ADD FOREIGN KEY (`shop_id`) REFERENCES `shop` (`id`);

ALTER TABLE `delivered` ADD FOREIGN KEY (`worker_id`) REFERENCES `worker` (`id`);

ALTER TABLE `delivered` ADD FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`);

ALTER TABLE `moved` ADD FOREIGN KEY (`from_shop_id`) REFERENCES `shop` (`id`);

ALTER TABLE `moved` ADD FOREIGN KEY (`to_shop_id`) REFERENCES `shop` (`id`);

ALTER TABLE `moved` ADD FOREIGN KEY (`product_id`) REFERENCES `product` (`id`);

ALTER TABLE `payment` ADD FOREIGN KEY (`worker_id`) REFERENCES `worker` (`id`);

DELIMITER $$
DROP PROCEDURE IF EXISTS `AddDelivery`$$
CREATE PROCEDURE `AddDelivery`( IN `product_id` INT, IN `amount` INT, IN `shop_id` INT, IN `worker_id` INT, IN `notes` VARCHAR(255), IN `price` INT, IN `company_id` INT)
BEGIN
START TRANSACTION;

insert into `delivered` (`product_id`, `amount`, `  shop_id`, `worker_id`, `notes`, `price`, `company_id`) values (product_id, amount, shop_id, worker_id, notes, price, company_id);
CALL AddStore(`product_id`, `shop_id`, `amount`);
COMMIT;
END$$
DELIMITER ;



DELIMITER $$
DROP PROCEDURE IF EXISTS `AddCompany`$$
CREATE PROCEDURE `AddCompany`( IN `id` INT, IN `name` varchar(255))
BEGIN
START TRANSACTION;

IF (id NOT IN (SELECT id FROM `companies`)) THEN
INSERT INTO `companies` (`id`, `name`) VALUES (id, name);
end if;

COMMIT;
END$$
DELIMITER ;


DROP TRIGGER store_after_deliv;
create trigger store_after_deliv after insert on `delivered`
FOR EACH ROW
insert into `stored` (`product_id`, `shop_id`, `amount`) values (new.product_id, new.shop_id, new.amount);







DELIMITER $$
DROP PROCEDURE IF EXISTS `AddStore`$$
CREATE PROCEDURE `AddStore`(IN `f_product_id` INT, IN `f_shop_id` INT, IN `f_amount` INT)
BEGIN
START TRANSACTION;

IF (f_product_id NOT IN (SELECT product_id FROM `stored`)) THEN
INSERT INTO `stored` (`product_id`, `shop_id`, `amount`) VALUES (f_product_id, f_shop_id, f_amount);
ELSEIF (f_shop_id IN (SELECT `product_id` FROM `stored` where f_product_id = `product_id`)) THEN
UPDATE `stored` SET `amount` = `amount` + f_amount WHERE (`product_id` = f_product_id and `shop_id` = f_shop_id);
end if;

COMMIT;
END$$
DELIMITER ;




DELIMITER $$
DROP PROCEDURE IF EXISTS `DelStore`$$
CREATE PROCEDURE `DelStore`(IN `f_product_id` INT, IN `f_shop_id` INT, IN `f_amount` INT)
BEGIN
START TRANSACTION;

IF (f_product_id NOT IN (SELECT product_id FROM `stored`)) THEN
SELECT "cant do this";
ELSE
UPDATE `stored` SET `amount` = `amount` - f_amount WHERE (`product_id` = f_product_id and `shop_id` = f_shop_id);
end if;

COMMIT;
END$$
DELIMITER ;
