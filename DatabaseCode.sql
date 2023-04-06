CREATE DATABASE IF NOT EXISTS `grocerystore`;
USE `grocerystore`;

DROP TABLE IF EXISTS `stocks`;
DROP TABLE IF EXISTS `payments`;
DROP TABLE IF EXISTS `cartinfo`;
DROP TABLE IF EXISTS `carts`;
DROP TABLE IF EXISTS `customers`;
DROP TABLE IF EXISTS `employees`;
DROP TABLE IF EXISTS `stores`;
DROP TABLE IF EXISTS `items`;

CREATE TABLE `customers` (
`Email_address` varchar(40) NOT NULL,
`Name` varchar(30) NOT NULL,
`Zip_code` varchar(15) NOT NULL,
`Phone_number` varchar(20) NOT NULL,
`Password` varchar(30) NOT NULL,
PRIMARY KEY (`Email_address`)
);

insert  into `customers`(`Email_address`,`Name`,`Zip_code`,`Phone_number`,`Password`) values 

('rafasgj@yahoo.com','Riley Barron','34653','561-213-6974','12orange!'),

('cfhsoft@hotmail.com','Sydney Lacey','32257','386-878-6498','SafraN123'),

('speeves@aol.com','Milton Mccray','33173','386-738-9351','allIdois777'),

('juliano@yahoo.com','Julian Rodriguez','32304','727-859-0904','digitalman123'),

('drolsky@msn.com','Mahi Savage','34698','904-313-3358','Limelight123'),

('gregh@live.com','Greg Harold','32822','305-975-8326','MoNkEy454'),

('seurat@msn.com','Seb Hilton','33569','321-800-8967','blaaahh121!'),

('kewley@optonline.com','Mandeep Colley','33801','561-431-7433','1FORD1'),

('juerd@msn.com','Shakeel Newton','33615','305-285-3070','Dorbant222'),

('shaffei@aol.com','Tia Perez','33322','321-248-5784','123neverwould123'),

('drezet@gmail.com','Archer Barnes','33330','813-274-0460','TomSawyer123!'),

('dmbkiwi@msn.com','Michael Ewing','33133','561-261-3757','1Dog321!');

CREATE TABLE `stores` (
`StoreID` int(15) NOT NULL,
`Street_address` varchar(60) NOT NULL,
`City` varchar(30) NOT NULL,
`State` varchar(25) NOT NULL,
`Zip_code` varchar(15) NOT NULL,
`Service_hours` varchar(20) NOT NULL,
`Phone_number` varchar(20) NOT NULL,
`Rating` decimal(3,2) DEFAULT NULL, 
PRIMARY KEY (`StoreID`)
);

insert  into `stores`(`StoreID`,`Street_address`,`City`,`State`,`Zip_code`,`Service_hours`,`Phone_number`,`Rating`) values 

(001,'5656 S Flamingo Rd','Cooper City','Florida','33330','7:00AM to 10:00PM','954 434 8240','4.89'),

(002,'106 Ponce de Leon Blvd','Miami','Florida','33135','7:00AM to 10:00PM','305 442 6018','4.59'),

(003,'741 S Orlando Ave','Winter Park','Florida','32789','9:00AM to 9:00PM','407 622 0302','4.77');

CREATE TABLE `employees` (
`EmployeeID` int(15) NOT NULL,
`Name` varchar(30) NOT NULL,
`Date_of_birth` date NOT NULL,
`StoreID` int(15) NOT NULL,
`Position` varchar(15) NOT NULL,
`Reports_to` int(15) DEFAULT NULL,
`Email_address` varchar(40) NOT NULL,
`Phone_number` varchar(20) NOT NULL, 
`Wage` decimal(6,2) NOT NULL, 
`Hire_date` date NOT NULL, 
PRIMARY KEY (`EmployeeID`),
FOREIGN KEY (`StoreID`) REFERENCES `stores` (`StoreID`)
);

insert  into `employees`(`EmployeeID`,`Name`,`Date_of_birth`,`StoreID`,`Position`,`Reports_to`,`Email_address`,`Phone_number`,`Wage`,`Hire_date`) values 

(1076,'Eleni Mcculloch','1964-01-01',001,'Cashier',1188,'itstatus@mac.com','954-206-4335','16.78','1989-04-30'),

(1088,'Katie-Louise Mcneill','1996-06-28',002,'Cashier',1286,'szymansk@gmail.com','305-200-3050','12.07','2019-10-31'),

(1102,'Maria Macleod','1979-06-09',003,'Cashier',1501,'harpes@outlook.com','321-200-3855','12.23','2018-02-11'),

(1143,'Elliott Ahmed','2013-10-29',001,'Stocker',1188,'pontipak@live.com','954-208-7694','12.06','2018-01-30'),

(1165,'Caoimhe Whitmore','1999-09-01',003,'Shopper',1501,'parkes@mac.com','321-201-0471','13.22','2017-10-04'),

(1166,'Marwa Melia','1999-05-11',003,'Stocker',1501,'mailarc@live.com','321-202-3492','13.09','2018-11-12'),

(1188,'Clinton Ford','1972-05-22',001,'Manager',NULL,'carcus@me.com','954-245-0198','28.12','1995-12-14'),

(1216,'Humairaa White','1958-01-21',001,'Shopper',1188,'ganter@yahoo.com','954-284-9503','14.00','2016-06-12'),

(1286,'Fleur Travis','1980-06-28',002,'Manager',NULL,'pgolle@mac.com','305-201-4006','26.88','2001-10-10'),

(1323,'Kaleb Boyce','1988-02-12',003,'Cashier',1501,'dartlife@live.com','321-206-7549','14.55','2012-06-05'),

(1337,'Jaydn Cortes','1956-09-07',002,'Stocker',1286,'lukka@hotmail.com','305-202-6479','12.99','2017-03-05'),

(1370,'Farhan Petersen','1986-09-12',003,'Shopper',1501,'sscorpio@outlook.com','321-209-1853','12.74','2008-05-01'),

(1401,'Ritchie Leonard','1987-09-17',003,'Stocker',1501,'fangorn@yahoo.com','321-217-1002','13.01','2009-04-15'),

(1501,'Marlon Gates','1981-04-14',003,'Manager',NULL,'uncle@gmail.com','321-221-6624','25.35','1992-02-26'),

(1504,'Roberto Hodge','2000-04-02',001,'Cashier',1188,'kildjean@gmail.com','954-297-8804','11.56','2019-01-22'),

(1611,'Nadeem Sharples','1990-11-13',002,'Shopper',1286,'henkp@hotmail.com','305-205-2647','12.12','2015-09-11'),

(1612,'Mahir Peel','2004-05-30',001,'Shopper',1188,'klaudon@me.com','954-302-4678','11.89','2020-09-13'),

(1619,'Caden George','1955-08-26',003,'Cashier',1501,'wetter@hotmail.com','321-229-7961','14.99','1998-04-10'),

(1621,'Asiyah Prentice','1954-06-16',002,'Shopper',1286,'pplinux@gmail.com','305-206-3507','14.45','2000-05-27'),

(1625,'Morwenna Merritt','1988-04-24',001,'Stocker',1188,'barjam@hotmail.com','954-376-0054','13.07','2010-11-15'),

(1702,'Stewart Forster','1993-12-12',002,'Cashier',1286,'bartlett@yahoo.com','305-207-8243','12.66','2019-05-26');

CREATE TABLE `carts` (
`Cart_number` int(15) NOT NULL,
`Email_address` varchar(40) NOT NULL,
`Order_date` date NOT NULL,
`StoreID` int(15) NOT NULL,
`ShopperID` int(11) NOT NULL,
`Status` varchar(20) NOT NULL,
`Delivery_time` datetime DEFAULT NULL,
`Comments` text DEFAULT NULL,
PRIMARY KEY (`Cart_number`),
FOREIGN KEY (`Email_address`) REFERENCES `customers` (`Email_address`),
FOREIGN KEY (`StoreID`) REFERENCES `stores` (`StoreID`),
FOREIGN KEY (`ShopperID`) REFERENCES `employees` (`EmployeeID`)
);

insert  into `carts`(`Cart_number`,`Email_address`,`Order_date`,`StoreID`,`ShopperID`,`Status`,`Delivery_time`,`Comments`) values 

(10003,'kewley@optonline.com','2019-01-13',001,1216,'Delivered','2019-01-13 09:55:59',NULL),

(10211,'cfhsoft@hotmail.com','2020-05-03',002,1286,'Delivered','2020-05-03 10:32:12',NULL),

(10032,'shaffei@aol.com','2020-01-17',002,1621,'Delivered','2020-01-18 07:12:29',NULL),

(10031,'shaffei@aol.com','2019-12-19',001,1216,'Delivered','2019-12-19 03:27:11',NULL),

(10342,'drolsky@msn.com','2020-10-12',003,1165,'In Transit',NULL,NULL),

(10123,'kewley@optonline.com','2020-02-01',003,1370,'Delivered','2020-02-01 05:22:58','If chocolate ice cream is not available, then replace with vanilla.'),

(10187,'dmbkiwi@msn.com','2020-03-05',002,1286,'Delivered','2020-03-06 12:53:01',NULL),

(10344,'drezet@gmail.com','2020-10-12',001,1612,'Being Processed',NULL,'Please make sure that the bread is fresh. Thank you.'),

(10327,'rafasgj@yahoo.com','2020-06-06',003,1370,'Delivered','2020-06-06 09:47:16',NULL);

CREATE TABLE `items` (
`Item_number` int(15) NOT NULL,
`Item_name` varchar(30) NOT NULL,
`Brand` varchar(20) NOT NULL,
`Category` varchar(20) NOT NULL,
PRIMARY KEY (`Item_number`)
);

insert  into `items`(`Item_number`,`Item_name`,`Brand`,`Category`) values 

(101,'Bread','Nature''s Own','Bread/Grains'),

(102,'Eggs','Eggland''s Best','Breakfast'),

(103,'Chocolate Ice Cream','Blue Bell','Dairy'),

(104,'Milk','Dean''s','Dairy'),

(105,'Yogurt','Yoplait','Dairy'),

(106,'Vanilla Ice Cream','Blue Bell','Dairy'),

(107,'Cereal','Honey Nut Cheerios','Breakfast'),

(108,'Ketchup','Heinz','Condiments'),

(109,'Mustard','French''s','Condiments'),

(110,'Apples','Pink Lady','Produce'),

(111,'Bananas','Chiquita','Produce'),

(112,'Bacon','Oscar Mayer','Meat'),

(113,'Ham','Hillshire Farm','Meat'),

(114,'Cheese','Sargento','Dairy'),

(115,'Chips','Lays','Snacks'),

(116,'Pasta','Barilla','Breads/Grains'),

(117,'Chips','Doritos','Snacks'),

(118,'Chicken Breasts','Harvestland','Meat'),

(119,'Ground Beef','Cargill','Meat'),

(120,'Oatmeal','Quaker','Breakfast'),

(121,'Mayonnaise','Hellmann''s','Condiments'),

(122,'Bagels','Sara Lee','Breads/Grains'),

(123,'Torillas','Guerrero','Breads/Grains'),

(124,'Chilli','Nalley','Cans/Jars'),

(125,'Peanut Butter','Jif','Cans/Jars'),

(126,'Olive Oil','Bertolli','Condiments'),

(127,'Salt','Morton','Condiments'),

(128,'Baby Carrots','Bolthouse Farms','Produce'),

(129,'Vinegar','Heinz','Condiments'),

(130,'Grape Jelly','Smucker''s','Cans/Jars'),

(131,'Bread','Wonder','Breads/Grains'),

(132,'Cereal','Fruit Loops','Breakfast'),

(133,'Cereal','Frosted Flakes','Breakfast'),

(134,'Soda','Coca Cola','Drinks'),

(135,'Water','Zephyrhills','Drinks'),

(136,'Green Tea','Arizona','Drinks'),

(137,'Cookies','Oreo''s','Snacks');

CREATE TABLE `cartinfo` (
`Cart_number` int(15) NOT NULL,
`Item_number` int(15) NOT NULL,
`Item_price` decimal(6,2) NOT NULL,
`Quantity_ordered` int(10) NOT NULL,
PRIMARY KEY (`Cart_number`,`Item_number`),
FOREIGN KEY (`Cart_number`) REFERENCES `carts` (`Cart_number`),
FOREIGN KEY (`Item_number`) REFERENCES `items` (`Item_number`)
);

insert  into `cartinfo`(`Cart_number`,`Item_number`,`Item_price`,`Quantity_ordered`) values 

(10327,132,'2.98',1),

(10327,107,'2.44',1),

(10327,109,'1.97',1),

(10327,112,'3.47',1),

(10187,107,'2.44',2),

(10187,130,'1.98',1),

(10187,129,'4.90',1),

(10031,106,'6.97',2),

(10031,108,'6.50',1),

(10031,110,'0.89',4),

(10031,115,'3.78',1),

(10031,116,'5.14',2),

(10031,119,'7.99',2),

(10031,130,'3.64',1),

(10031,122,'1.99',1),

(10031,127,'3.88',1),

(10031,137,'1.99',1),

(10003,101,'2.99',2),

(10003,102,'3.99',2),

(10003,109,'1.97',1),

(10003,122,'2.18',1),

(10003,129,'4.90',1),

(10003,135,'10.99',1),

(10211,134,'1.25',2),

(10211,123,'3.48',2),

(10211,105,'0.99',10),

(10211,102,'3.99',1),

(10211,101,'2.99',1),

(10211,115,'3.78',1),

(10211,117,'3.98',1),

(10344,101,'2.99',1),

(10344,102,'3.62',2),

(10344,103,'6.97',1),

(10344,115,'3.99',2),

(10344,109,'1.99',1),

(10344,131,'1.99',1),

(10032,137,'1.99',2),

(10032,116,'5.14',2),

(10032,108,'6.50',1),

(10032,105,'0.99',10),

(10032,102,'3.62',2),

(10032,103,'6.97',1),

(10032,110,'0.89',5),

(10032,117,'3.98',2),

(10032,122,'1.99',1),

(10342,130,'3.64',1),

(10342,132,'2.98',2),

(10342,136,'2.98',2),

(10342,123,'3.48',1),

(10123,119,'7.89',2),

(10123,115,'3.99',1),

(10123,105,'0.60',8),

(10123,124,'3.44',4),

(10123,116,'5.14',1),

(10123,128,'2.86',1),

(10123,106,'6.97',1),

(10123,110,'0.77',3),

(10123,133,'2.98',1),

(10123,134,'0.99',1),

(10123,137,'3.67',1),

(10123,101,'2.99',2);

CREATE TABLE `stocks` (
`StoreID` int(15) NOT NULL,
`Item_number` int(15) NOT NULL,
`Price` decimal(6,2) NOT NULL,
`Quantity` int(10) NOT NULL,
PRIMARY KEY (`StoreID`,`Item_number`),
FOREIGN KEY (`StoreID`) REFERENCES `stores` (`StoreID`),
FOREIGN KEY (`Item_number`) REFERENCES `items` (`Item_number`)
);

insert  into `stocks`(`StoreID`,`Item_number`,`Price`,`Quantity`) values 

(001,101,'2.99',97),

(001,102,'3.62',59),

(001,103,'6.97',100),

(001,104,'3.65',45),

(001,105,'0.60',123),

(001,106,'6.97',75),

(001,107,'2.44',46),

(001,108,'5.99',11),

(001,109,'1.99',14),

(001,110,'0.77',28),

(001,111,'1.58',85),

(001,112,'3.47',125),

(001,113,'3.78',45),

(001,114,'2.88',68),

(001,115,'3.99',106),

(001,116,'5.14',55),

(001,117,'4.28',78),

(001,118,'9.88',23),

(001,119,'7.89',25),

(001,120,'4.99',89),

(001,121,'2.99',147),

(001,122,'2.18',44),

(001,123,'3.48',20),

(001,124,'3.44',142),

(001,125,'4.73',103),

(001,126,'4.38',85),

(001,127,'3.88',66),

(001,128,'2.86',80),

(001,129,'4.90',101),

(001,130,'1.98',150),

(001,131,'1.99',33),

(001,132,'2.98',99),

(001,133,'2.98',123),

(001,134,'0.99',111),

(001,135,'12.38',45),

(001,136,'2.98',21),

(001,137,'3.67',28),

(002,101,'3.99',22),

(002,102,'3.62',1),

(002,103,'6.97',54),

(002,104,'3.99',108),

(002,105,'0.99',99),

(002,106,'6.97',99),

(002,107,'2.44',106),

(002,108,'6.50',45),

(002,109,'2.50',96),

(002,110,'0.89',44),

(002,111,'1.99',12),

(002,112,'3.47',83),

(002,113,'4.78',50),

(002,114,'2.99',78),

(002,115,'3.78',100),

(002,116,'5.14',65),

(002,117,'3.98',145),

(002,118,'10.02',12),

(002,119,'7.99',77),

(002,120,'4.99',98),

(002,121,'2.99',92),

(002,122,'1.99',53),

(002,123,'3.48',61),

(002,124,'3.44',66),

(002,125,'5.98',100),

(002,126,'4.78',11),

(002,127,'3.88',5),

(002,128,'3.99',13),

(002,129,'4.90',98),

(002,130,'3.64',34),

(002,131,'1.99',15),

(002,132,'2.98',45),

(002,133,'2.98',12),

(002,134,'1.25',76),

(002,135,'12.99',45),

(002,136,'2.98',44),

(002,137,'1.99',88),

(003,101,'2.99',98),

(003,102,'3.99',124),

(003,103,'6.97',47),

(003,104,'1.99',86),

(003,105,'0.99',82),

(003,106,'6.97',81),

(003,107,'2.44',50),

(003,108,'4.99',74),

(003,109,'1.97',33),

(003,110,'1.02',15),

(003,111,'1.63',15),

(003,112,'3.47',0),

(003,113,'4.78',85),

(003,114,'2.88',107),

(003,115,'3.78',23),

(003,116,'5.14',9),

(003,117,'3.98',42),

(003,118,'7.99',91),

(003,119,'7.98',80),

(003,120,'4.99',12),

(003,121,'2.99',17),

(003,122,'2.18',10),

(003,123,'3.48',85),

(003,124,'3.99',55),

(003,125,'5.64',56),

(003,126,'4.99',41),

(003,127,'3.88',20),

(003,128,'4.99',99),

(003,129,'4.90',71),

(003,130,'3.99',65),

(003,131,'1.99',22),

(003,132,'2.98',62),

(003,133,'2.98',41),

(003,134,'1.25',67),

(003,135,'10.99',16),

(003,136,'2.98',95),

(003,137,'1.99',13);

CREATE TABLE `payments` (
`Payment_number` int(15) NOT NULL,
`Email_address` varchar(40) NOT NULL,
`Cart_number` int(15) NOT NULL,
`Shipping_address` varchar(100) NOT NULL,
`Card_number` varchar(40) NOT NULL,
`Name_on_card` varchar(30) NOT NULL,
`Expiration_date` varchar(25) NOT NULL,
`Payment_amount` decimal(6,2) NOT NULL,
`Payment_date` date NOT NULL, 
PRIMARY KEY (`Payment_number`),
FOREIGN KEY (`Email_address`) REFERENCES `customers` (`Email_address`),
FOREIGN KEY (`Cart_number`) REFERENCES `carts` (`Cart_number`)
);

insert  into `payments`(`Payment_number`,`Email_address`,`Cart_number`,`Shipping_address`,`Card_number`,`Name_on_card`,`Expiration_date`,`Payment_amount`,`Payment_date`) values 

(100003,'kewley@optonline.com',10003,'927 Charles Street Hollywood, FL 33024','6225 9649 4262 0140','Mandeep Colley','10/2025','35.23','2019-01-13'),

(100245,'cfhsoft@hotmail.com',10211,'92 Adams Ave. Hialeah, FL 33016','6228 2524 5856 4978','Sydney Lacey','04/2028','35.19','2020-05-03'),

(100037,'shaffei@aol.com',10032,'8015 Elm Lane Miami, FL 33172','6227 0711 4899 1081','Tia Perez','07/2023','62.03','2020-01-17'),

(100036,'shaffei@aol.com',10031,'16 Linden Ave. Fort Lauderdale, FL 33309','6227 0711 4899 1081','Tia Perez','07/2023','68.46','2020-01-17'),

(100389,'drolsky@msn.com',10342,'836 Bridgeton Court Orlando, FL 32825','3485 2502 2795 3605','Mahi Savage','02/2024','20.01','2020-10-12'),

(100144,'kewley@optonline.com',10123,'2 College Ave. Orlando, FL 32837','6225 9649 4262 0140','Mandeep Colley','10/2025','72.56','2020-02-01'),

(100232,'dmbkiwi@msn.com',10187,'918 Circle St. Miami, FL 33161','5061 8194 2962 6524','Michael Ewing','07/2024','12.03','2020-03-05'),

(100401,'drezet@gmail.com',10344,'8054 North Orchard Street Hollywood, FL 33023','6369 9708 8792 9210','Archer Barnes','01/2028','30.98','2020-10-12'),

(100395,'rafasgj@yahoo.com',10327,'240 Berkshire Ave. Winter Park, FL 32792','3542 8947 1719 3028','Riley Barron','12/2020','11.22','2020-06-06');
