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

