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

