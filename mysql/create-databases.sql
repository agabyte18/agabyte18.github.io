DROP DATABASE IF EXISTS `DWM_invoicing`;
CREATE DATABASE `DWM_invoicing`; 
USE `DWM_invoicing`;

SET NAMES utf8mb4 ;
SET character_set_client = utf8mb4 ;

CREATE TABLE `payment_methods` (
  `payment_method_id` tinyint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`payment_method_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `payment_methods` VALUES (1,'Cash');
INSERT INTO `payment_methods` VALUES (2,'PayPal');
INSERT INTO `payment_methods` VALUES (3,'Credit Card');
INSERT INTO `payment_methods` VALUES (4,'Wire Transfer');

CREATE TABLE `clients` (
  `client_id` int NOT NULL,
  `name` varchar(50) NOT NULL,
  `address` varchar(50) NOT NULL,
  `city` varchar(50) NOT NULL,
  `state` char(2) NOT NULL,
  `phone` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `clients` VALUES (1,'Vite','8 Nevada Avenue','Syracuse','NY','315-252-8416');
INSERT INTO `clients` VALUES (2,'HopWorks','23156 Glendale Avenue','Huntington','WV','304-659-2218');
INSERT INTO `clients` VALUES (3,'Citadel','017 Pawling Street','San Francisco','CA','415-144-7147');
INSERT INTO `clients` VALUES (4,'Viddy','81674 Chesterfield Lane','Waco','TX','254-750-2902');
INSERT INTO `clients` VALUES (5,'TitleCouch','0777 Farmco Circle','Portland','OR','971-888-0368');

CREATE TABLE `invoices` (
  `invoice_id` int NOT NULL,
  `number` varchar(50) NOT NULL,
  `client_id` int NOT NULL,
  `invoice_total` decimal(9,2) NOT NULL,
  `payment_total` decimal(9,2) NOT NULL DEFAULT '0.00',
  `invoice_date` date NOT NULL,
  `due_date` date NOT NULL,
  `payment_date` date DEFAULT NULL,
  PRIMARY KEY (`invoice_id`),
  KEY `FK_client_id` (`client_id`),
  CONSTRAINT `FK_client_id` FOREIGN KEY (`client_id`) REFERENCES `clients` (`client_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `invoices` VALUES (1,'02-538-3396',2,111.79,0.00,'2019-03-09','2019-03-29',NULL);
INSERT INTO `invoices` VALUES (2,'03-898-7846',5,185.32,8.18,'2019-06-11','2019-07-01','2019-02-12');
INSERT INTO `invoices` VALUES (3,'20-339-0335',5,247.99,0.00,'2019-07-31','2019-08-20',NULL);
INSERT INTO `invoices` VALUES (4,'56-934-9581',3,152.31,0.00,'2019-03-08','2019-03-28',NULL);
INSERT INTO `invoices` VALUES (5,'87-052-2324',5,169.39,0.00,'2019-07-18','2019-08-07',NULL);
INSERT INTO `invoices` VALUES (6,'75-699-6626',1,167.78,74.55,'2019-01-29','2019-02-18','2019-01-03');
INSERT INTO `invoices` VALUES (7,'68-104-9863',3,233.87,0.00,'2019-09-04','2019-09-24',NULL);
INSERT INTO `invoices` VALUES (8,'78-562-1373',1,289.12,0.00,'2019-05-20','2019-06-09',NULL);
INSERT INTO `invoices` VALUES (9,'55-403-1181',5,172.17,0.00,'2019-07-09','2019-07-29',NULL);
INSERT INTO `invoices` VALUES (10,'78-276-1777',1,159.50,0.00,'2019-06-30','2019-07-20',NULL);
INSERT INTO `invoices` VALUES (11,'26-868-0661',3,126.15,0.03,'2019-01-07','2019-01-27','2019-01-11');
INSERT INTO `invoices` VALUES (13,'42-266-1022',5,135.01,87.44,'2019-06-25','2019-07-15','2019-01-26');
INSERT INTO `invoices` VALUES (15,'88-185-9805',3,167.29,80.31,'2019-11-25','2019-12-15','2019-01-15');
INSERT INTO `invoices` VALUES (16,'11-411-8124',1,162.92,0.00,'2019-03-30','2019-04-19',NULL);
INSERT INTO `invoices` VALUES (17,'39-615-9694',3,126.38,68.10,'2019-07-30','2019-08-19','2019-01-15');
INSERT INTO `invoices` VALUES (18,'53-269-4403',5,180.17,42.77,'2019-05-23','2019-06-12','2019-01-08');
INSERT INTO `invoices` VALUES (19,'83-549-2205',1,134.47,0.00,'2019-11-23','2019-12-13',NULL);

CREATE TABLE `payments` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `invoice_id` int NOT NULL,
  `date` date NOT NULL,
  `amount` decimal(9,2) NOT NULL,
  `payment_method` tinyint NOT NULL,
  PRIMARY KEY (`payment_id`),
  KEY `fk_client_id_idx` (`client_id`),
  KEY `fk_invoice_id_idx` (`invoice_id`),
  KEY `fk_payment_payment_method_idx` (`payment_method`),
  CONSTRAINT `fk_payment_client` FOREIGN KEY (`client_id`) REFERENCES `clients` (`client_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_payment_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`invoice_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_payment_payment_method` FOREIGN KEY (`payment_method`) REFERENCES `payment_methods` (`payment_method_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `payments` VALUES (1,5,2,'2019-02-12',8.18,1);
INSERT INTO `payments` VALUES (2,1,6,'2019-01-03',74.55,1);
INSERT INTO `payments` VALUES (3,3,11,'2019-01-11',0.03,1);
INSERT INTO `payments` VALUES (4,5,13,'2019-01-26',87.44,1);
INSERT INTO `payments` VALUES (5,3,15,'2019-01-15',80.31,1);
INSERT INTO `payments` VALUES (6,3,17,'2019-01-15',68.10,1);
INSERT INTO `payments` VALUES (7,5,18,'2019-01-08',32.77,1);
INSERT INTO `payments` VALUES (8,5,18,'2019-01-08',10.00,2);


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


DROP DATABASE IF EXISTS `DWM_hr`;
CREATE DATABASE `DWM_hr`;
USE `DWM_hr`;


CREATE TABLE `offices` (
  `office_id` int NOT NULL,
  `address` varchar(50) NOT NULL,
  `city` varchar(50) NOT NULL,
  `state` varchar(50) NOT NULL,
  PRIMARY KEY (`office_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `offices` VALUES (1,'404 Greensteam Avenue','Savannah','GA');
INSERT INTO `offices` VALUES (2,'909 Eastend Trail','Knoxville','TN');
INSERT INTO `offices` VALUES (3,'541 Grayhawk Hill','New York City','NY');
INSERT INTO `offices` VALUES (4,'434 Wayridge Plaza','Boise','ID');
INSERT INTO `offices` VALUES (5,'442 South Drive','Denver','CO');
INSERT INTO `offices` VALUES (6,'535 Maple Crossing','Minneapolis','MN');
INSERT INTO `offices` VALUES (7,'10 East Court','Cleveland','OH');
INSERT INTO `offices` VALUES (8,'49 Ropeland Way','Richmond','VA');
INSERT INTO `offices` VALUES (9,'6608 Frog Terrace','New York City','NY');
INSERT INTO `offices` VALUES (10,'03 Reinke Trail','Cincinnati','OH');



CREATE TABLE `employees` (
  `employee_id` int NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `job_title` varchar(50) NOT NULL,
  `salary` int NOT NULL,
  `reports_to` int DEFAULT NULL,
  `office_id` int NOT NULL,
  PRIMARY KEY (`employee_id`),
  KEY `fk_employees_offices_idx` (`office_id`),
  KEY `fk_employees_employees_idx` (`reports_to`),
  CONSTRAINT `fk_employees_managers` FOREIGN KEY (`reports_to`) REFERENCES `employees` (`employee_id`),
  CONSTRAINT `fk_employees_offices` FOREIGN KEY (`office_id`) REFERENCES `offices` (`office_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `employees` VALUES (48381,'Yvette','Zawaddi','Executive Secretary',63996,NULL,10);
INSERT INTO `employees` VALUES (66691,'Brian','O\'Shay','Account Executive',62871,48381,1);
INSERT INTO `employees` VALUES (55551,'Peyton','Sawyer','Statistician III',98926,48381,1);
INSERT INTO `employees` VALUES (44448,'Cindy','Ryddell','Staff Scientist',94860,48381,1);
INSERT INTO `employees` VALUES (33354,'Christian','Alonso','VP Marketing',110150,48381,1);
INSERT INTO `employees` VALUES (22296,'Alastor','Crane','Assistant Professor',32179,48381,2);
INSERT INTO `employees` VALUES (88809,'Denny','de Gaul','VP Product Management',114257,48381,2);
INSERT INTO `employees` VALUES (99970,'Maggie','Moody','Social Worker',96767,48381,2);
INSERT INTO `employees` VALUES (11149,'Nelly','Vin','Financial Advisor',52832,48381,2);
INSERT INTO `employees` VALUES (11140,'Geoffrey','Iago','Office Assistant I',117690,48381,3);
INSERT INTO `employees` VALUES (77713,'Kriss','Hedera','Computer Systems Analyst IV',96401,48381,3);
INSERT INTO `employees` VALUES (32300,'Virgo','Hendriksen','Information Systems Manager',54578,48381,3);
INSERT INTO `employees` VALUES (41996,'Milla','Perez','Cost Accountant',119241,48381,3);
INSERT INTO `employees` VALUES (20229,'Lynda','DAAron','Junior Executive',77182,48381,4);
INSERT INTO `employees` VALUES (32079,'Mildred','McKay','Geologist II',67987,48381,4);
INSERT INTO `employees` VALUES (32191,'Pepper','Potts','General Manager',93760,48381,4);
INSERT INTO `employees` VALUES (73713,'Cole','Ashley','Pharmacist',86119,48381,4);
INSERT INTO `employees` VALUES (74713,'Preston','August','Food Chemist',47354,48381,5);
INSERT INTO `employees` VALUES (75774,'Preston','July','Staff Accountant IV',70187,48381,5);
INSERT INTO `employees` VALUES (767357,'Ivy','Farrah','Structural Engineer',92710,48381,5);


DROP DATABASE IF EXISTS `DWM_inventory`;
CREATE DATABASE `DWM_inventory`;
USE `DWM_inventory`;


CREATE TABLE `products` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `quantity_in_stock` int NOT NULL,
  `unit_price` decimal(4,2) NOT NULL,
  PRIMARY KEY (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `products` VALUES (1,'Sauce - Ranch Dressing',94,1.63);
INSERT INTO `products` VALUES (2,'Brocolinni - Gaylan, Chinese',90,4.53);
INSERT INTO `products` VALUES (3,'Lettuce - Romaine, Heart',38,3.35);
INSERT INTO `products` VALUES (4,'Foam Dinner Plate',70,1.21);
INSERT INTO `products` VALUES (5,'Pork - Bacon, back Peameal',49,4.65);
INSERT INTO `products` VALUES (6,'Broom - Push',6,1.09);
INSERT INTO `products` VALUES (7,'Longan',67,2.26);
INSERT INTO `products` VALUES (8,'Island Oasis - Raspberry',26,0.74);
INSERT INTO `products` VALUES (9,'Petit Baguette',14,2.39);
INSERT INTO `products` VALUES (10,'Sweet Pea Sprouts',98,3.29);
