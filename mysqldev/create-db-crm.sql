DROP DATABASE IF EXISTS dwm_crm;
CREATE DATABASE dwm_crm; 
USE dwm_crm;

SET NAMES utf8mb4 ;
SET character_set_client = utf8mb4 ;

create table customers (
  id int not null,
  name varchar(10),
  bal decimal(8,2),
  loc char(2)
);

insert into customers values (1, 'Kate', 100, 'CA');
insert into customers values (2, 'June', 200, 'GB');
insert into customers values (3, 'Jean', 300, 'FR');
insert into customers values (4, 'Luca', 400, 'IT');
insert into customers values (5, 'Sam', 500, 'US');
insert into customers values (6, 'Ida', 600, 'DE');
insert into customers values (7, 'Aika', 700, 'JP');

commit;
