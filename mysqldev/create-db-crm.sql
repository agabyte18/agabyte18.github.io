DROP DATABASE IF EXISTS dwm_crm;
CREATE DATABASE dwm_crm; 
USE dwm_crm;

SET NAMES utf8mb4 ;
SET character_set_client = utf8mb4 ;

create table customers (
  id int not null,
  name varchar(10),
  bal int,
  loc char(3)
);

insert into customers values (1, 'Kate', 100, 'CA');
insert into customers values (2, 'June', 200, 'UK');
insert into customers values (3, 'Jean', 300, 'FR');
insert into customers values (4, 'Luca', 400, 'IT');
insert into customers values (5, 'Sam', 500, 'US');
insert into customers values (6, 'Ida', 600, 'DE');
insert into customers values (7, 'Aika', 700, 'JP');

create table branches (
  id int not null,
  name varchar(20),
  code char(3)
);

insert into branches values (1, 'Canada', 'CA');
insert into branches values (2, 'United Kingdom', 'UK');
insert into branches values (3, 'France', 'FR');
insert into branches values (4, 'Italy', 'IT');
insert into branches values (5, 'USA', 'US');
insert into branches values (6, 'Germany', 'DE');
insert into branches values (7, 'Japan', 'JP');