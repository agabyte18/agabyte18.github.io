DROP DATABASE IF EXISTS `DWM_store`;
CREATE DATABASE `DWM_store`;
USE `DWM_store`;

CREATE TABLE `products` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `quantity_in_stock` int NOT NULL,
  `unit_price` decimal(4,2) NOT NULL,
  PRIMARY KEY (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `products` VALUES (1,'Broom - Push',6,1.09);
INSERT INTO `products` VALUES (2,'Longan',67,2.26);
INSERT INTO `products` VALUES (3,'Island Oasis - Raspberry',26,0.74);
INSERT INTO `products` VALUES (4,'Sweet Pea Sprouts',98,3.29);
INSERT INTO `products` VALUES (5,'Petit Baguette',14,2.39);
INSERT INTO `products` VALUES (6,'Sauce - Ranch Dressing',94,1.63);
INSERT INTO `products` VALUES (7,'Brocolinni - Gaylan, Chinese',90,4.53);
INSERT INTO `products` VALUES (8,'Lettuce - Romaine, Heart',38,3.35);
INSERT INTO `products` VALUES (9,'Pork - Bacon,back Peameal',49,4.65);
INSERT INTO `products` VALUES (10,'Foam Dinner Plate',70,1.21);


CREATE TABLE `shippers` (
  `shipper_id` smallint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`shipper_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `shippers` VALUES (1,'Maersk LLC');
INSERT INTO `shippers` VALUES (2,'Afreman Shipping Co');
INSERT INTO `shippers` VALUES (3,'Costco Shipping Lines');
INSERT INTO `shippers` VALUES (4,'Marag-Floyd');
INSERT INTO `shippers` VALUES (5,'Everblu Marina');


CREATE TABLE `customers` (
  `customer_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `birth_date` date DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `address` varchar(50) NOT NULL,
  `city` varchar(50) NOT NULL,
  `state` char(2) NOT NULL,
  `points` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `customers` VALUES (1,'Rebecca','MacCrawley','1986-03-28','781-932-6654','0 Mage Trail','Waltham','MA',2273);
INSERT INTO `customers` VALUES (2,'Greg','Ines','1986-04-13','804-427-1156','14187 Private Junction','Hampton','VA',947);
INSERT INTO `customers` VALUES (3,'Freddie','Mercury','1985-02-07','719-724-7080','251 Lake Terrace','Colorado Springs','CO',2967);
INSERT INTO `customers` VALUES (4,'Amber','Rosenblatt','1974-04-14','407-231-1708','30 Arapahoe Lane','Orlando','FL',457);
INSERT INTO `customers` VALUES (5,'Clem','Ohamezie','1973-11-07',NULL,'5 Spohn Circle','Darlington Crossing','TX',3675);
INSERT INTO `customers` VALUES (6,'Olga','Rydell','1991-09-04','312-480-5508','7 Mangrove Road','Chicago','IL',3073);
INSERT INTO `customers` VALUES (7,'Eilene','Dawson','1964-08-30','615-614-1112','50 Lillith Drive','Nashville','TN',1672);
INSERT INTO `customers` VALUES (8,'Maggie','Wyatt','1993-07-17','941-527-4066','538 Mosaic Center','Sarasota','FL',205);
INSERT INTO `customers` VALUES (9,'Romola','Moshood','1992-05-23','559-181-5544','3520 Ohio Drive','Visalia','CA',1486);
INSERT INTO `customers` VALUES (10,'Levy','Eugene','1969-10-13','404-246-7099','68 Lawnville','Atlanta','GA',796);


CREATE TABLE `order_statuses` (
  `order_status_id` tinyint NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`order_status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `order_statuses` VALUES (1,'Processed');
INSERT INTO `order_statuses` VALUES (2,'Shipped');
INSERT INTO `order_statuses` VALUES (3,'Delivered');


CREATE TABLE `orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `order_date` date NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `comments` varchar(2000) DEFAULT NULL,
  `shipped_date` date DEFAULT NULL,
  `shipper_id` smallint DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  KEY `fk_orders_customers_idx` (`customer_id`),
  KEY `fk_orders_shippers_idx` (`shipper_id`),
  KEY `fk_orders_order_statuses_idx` (`status`),
  CONSTRAINT `fk_orders_customers` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_order_statuses` FOREIGN KEY (`status`) REFERENCES `order_statuses` (`order_status_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_shippers` FOREIGN KEY (`shipper_id`) REFERENCES `shippers` (`shipper_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `orders` VALUES (1,6,'2019-01-30',1,NULL,NULL,NULL);
INSERT INTO `orders` VALUES (2,7,'2018-08-02',2,NULL,'2018-08-03',4);
INSERT INTO `orders` VALUES (3,8,'2017-12-01',1,NULL,NULL,NULL);
INSERT INTO `orders` VALUES (4,2,'2017-01-22',1,NULL,NULL,NULL);
INSERT INTO `orders` VALUES (5,5,'2017-08-25',2,'','2017-08-26',3);
INSERT INTO `orders` VALUES (6,10,'2018-11-18',1,'Duis facilisis tincidunt mi, et eleifend dolor porttitor in.',NULL,NULL);
INSERT INTO `orders` VALUES (7,2,'2018-09-22',2,NULL,'2018-09-23',4);
INSERT INTO `orders` VALUES (8,5,'2018-06-08',1,'Nam arcu nunc, porttitor maximus enim a, congue vulputate tortor.',NULL,NULL);
INSERT INTO `orders` VALUES (9,10,'2017-07-05',2,'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae.','2017-07-06',1);
INSERT INTO `orders` VALUES (10,6,'2018-04-22',2,NULL,'2018-04-23',2);


CREATE TABLE `order_items` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(4,2) NOT NULL,
  PRIMARY KEY (`order_id`,`product_id`),
  KEY `fk_order_items_products_idx` (`product_id`),
  CONSTRAINT `fk_order_items_orders` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_order_items_products` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `order_items` VALUES (1,4,4,3.74);
INSERT INTO `order_items` VALUES (2,1,2,9.10);
INSERT INTO `order_items` VALUES (2,4,4,1.66);
INSERT INTO `order_items` VALUES (2,6,2,2.94);
INSERT INTO `order_items` VALUES (3,3,10,9.12);
INSERT INTO `order_items` VALUES (4,3,7,6.99);
INSERT INTO `order_items` VALUES (4,10,7,6.40);
INSERT INTO `order_items` VALUES (5,2,3,9.89);
INSERT INTO `order_items` VALUES (6,1,4,8.65);
INSERT INTO `order_items` VALUES (6,2,4,3.28);
INSERT INTO `order_items` VALUES (6,3,4,7.46);
INSERT INTO `order_items` VALUES (6,5,1,3.45);
INSERT INTO `order_items` VALUES (7,3,7,9.17);
INSERT INTO `order_items` VALUES (8,5,2,6.94);
INSERT INTO `order_items` VALUES (8,8,2,8.59);
INSERT INTO `order_items` VALUES (9,6,5,7.28);
INSERT INTO `order_items` VALUES (10,1,10,6.01);
INSERT INTO `order_items` VALUES (10,9,9,4.28);

CREATE TABLE `DWM_store`.`order_item_notes` (
  `note_id` INT NOT NULL,
  `order_Id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `note` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`note_id`));

INSERT INTO `order_item_notes` (`note_id`, `order_Id`, `product_id`, `note`) VALUES ('1', '1', '2', 'first note');
INSERT INTO `order_item_notes` (`note_id`, `order_Id`, `product_id`, `note`) VALUES ('2', '1', '2', 'second note');
