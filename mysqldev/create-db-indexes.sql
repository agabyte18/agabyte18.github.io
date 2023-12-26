DROP DATABASE IF EXISTS dwm_indexes;
CREATE DATABASE dwm_indexes; 
USE dwm_indexes;

SET NAMES utf8mb4 ;
SET character_set_client = utf8mb4 ;


CREATE TABLE emps (
  employee_id int NOT NULL AUTO_INCREMENT,
  first_name varchar(30),
  last_name varchar(30) NOT NULL,
  email varchar(30) NOT NULL,
  phone varchar(20),
  hire_date date not null,
  job_id varchar(10) not null,
  salary decimal(8,2),
  commission_pct decimal(2,2),
  manager_id int,
  department_id int,
  PRIMARY KEY (employee_id)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

  INSERT INTO emps VALUES
      ( 100
      , 'Steven'
      , 'King'
      , 'SKING'
      , '1.515.555.0100'
      , '2013-06-17'
      , 'AD_PRES'
      , 24000
      , NULL
      , NULL
      , 90
      );

  INSERT INTO emps VALUES
      ( 101
      , 'Neena'
      , 'Yang'
      , 'NYANG'
      , '1.515.555.0101'
      , '2015-09-21'
      , 'AD_VP'
      , 17000
      , NULL
      , 100
      , 90
      );

  INSERT INTO emps VALUES
      ( 102
      , 'Lex'
      , 'Garcia'
      , 'LGARCIA'
      , '1.515.555.0102'
      , '2011-01-13'
      , 'AD_VP'
      , 17000
      , NULL
      , 100
      , 90
      );

  INSERT INTO emps VALUES
      ( 103
      , 'Alexander'
      , 'James'
      , 'AJAMES'
      , '1.590.555.0103'
      , '2016-01-03'
      , 'IT_PROG'
      , 9000
      , NULL
      , 102
      , 60
      );

  INSERT INTO emps VALUES
      ( 104
      , 'Bruce'
      , 'Miller'
      , 'BMILLER'
      , '1.590.555.0104'
      , '2017-05-21'
      , 'IT_PROG'
      , 6000
      , NULL
      , 103
      , 60
      );

  INSERT INTO emps VALUES
      ( 105
      , 'David'
      , 'Williams'
      , 'DWILLIAMS'
      , '1.590.555.0105'
      , STR_TO_DATE('25-06-2015', '%d-%m-%Y')
      , 'IT_PROG'
      , 4800
      , NULL
      , 103
      , 60
      );

  INSERT INTO emps VALUES
      ( 106
      , 'Valli'
      , 'Jackson'
      , 'VJACKSON'
      , '1.590.555.0106'
      , STR_TO_DATE('05-02-2016', '%d-%m-%Y')
      , 'IT_PROG'
      , 4800
      , NULL
      , 103
      , 60
      );

  INSERT INTO emps VALUES
      ( 107
      , 'Diana'
      , 'Nguyen'
      , 'DNGUYEN'
      , '1.590.555.0107'
      , STR_TO_DATE('07-02-2017', '%d-%m-%Y')
      , 'IT_PROG'
      , 4200
      , NULL
      , 103
      , 60
      );

  INSERT INTO emps VALUES
      ( 108
      , 'Nancy'
      , 'Gruenberg'
      , 'NGRUENBE'
      , '1.515.555.0108'
      , STR_TO_DATE('17-08-2012', '%d-%m-%Y')
      , 'FI_MGR'
      , 12008
      , NULL
      , 101
      , 100
      );

  INSERT INTO emps VALUES
      ( 109
      , 'Daniel'
      , 'Faviet'
      , 'DFAVIET'
      , '1.515.555.0109'
      , STR_TO_DATE('16-08-2012', '%d-%m-%Y')
      , 'FI_ACCOUNT'
      , 9000
      , NULL
      , 108
      , 100
      );

  INSERT INTO emps VALUES
      ( 110
      , 'John'
      , 'Chen'
      , 'JCHEN'
      , '1.515.555.0110'
      , STR_TO_DATE('28-09-2015', '%d-%m-%Y')
      , 'FI_ACCOUNT'
      , 8200
      , NULL
      , 108
      , 100
      );

  INSERT INTO emps VALUES
      ( 111
      , 'Ismael'
      , 'Sciarra'
      , 'ISCIARRA'
      , '1.515.555.0111'
      , STR_TO_DATE('30-09-2015', '%d-%m-%Y')
      , 'FI_ACCOUNT'
      , 7700
      , NULL
      , 108
      , 100
      );

  INSERT INTO emps VALUES
      ( 112
      , 'Jose Manuel'
      , 'Urman'
      , 'JMURMAN'
      , '1.515.555.0112'
      , STR_TO_DATE('07-03-2016', '%d-%m-%Y')
      , 'FI_ACCOUNT'
      , 7800
      , NULL
      , 108
      , 100
      );

  INSERT INTO emps VALUES
      ( 113
      , 'Luis'
      , 'Popp'
      , 'LPOPP'
      , '1.515.555.0113'
      , STR_TO_DATE('07-12-2017', '%d-%m-%Y')
      , 'FI_ACCOUNT'
      , 6900
      , NULL
      , 108
      , 100
      );

  INSERT INTO emps VALUES
      ( 114
      , 'Den'
      , 'Li'
      , 'DLI'
      , '1.515.555.0114'
      , STR_TO_DATE('07-12-2012', '%d-%m-%Y')
      , 'PU_MAN'
      , 11000
      , NULL
      , 100
      , 30
      );

  INSERT INTO emps VALUES
      ( 115
      , 'Alexander'
      , 'Khoo'
      , 'AKHOO'
      , '1.515.555.0115'
      , STR_TO_DATE('18-05-2013', '%d-%m-%Y')
      , 'PU_CLERK'
      , 3100
      , NULL
      , 114
      , 30
      );

  INSERT INTO emps VALUES
      ( 116
      , 'Shelli'
      , 'Baida'
      , 'SBAIDA'
      , '1.515.555.0116'
      , STR_TO_DATE('24-12-2015', '%d-%m-%Y')
      , 'PU_CLERK'
      , 2900
      , NULL
      , 114
      , 30
      );

  INSERT INTO emps VALUES
      ( 117
      , 'Sigal'
      , 'Tobias'
      , 'STOBIAS'
      , '1.515.555.0117'
      , STR_TO_DATE('24-07-2015', '%d-%m-%Y')
      , 'PU_CLERK'
      , 2800
      , NULL
      , 114
      , 30
      );

  INSERT INTO emps VALUES
      ( 118
      , 'Guy'
      , 'Himuro'
      , 'GHIMURO'
      , '1.515.555.0118'
      , STR_TO_DATE('15-11-2016', '%d-%m-%Y')
      , 'PU_CLERK'
      , 2600
      , NULL
      , 114
      , 30
      );

  INSERT INTO emps VALUES
      ( 119
      , 'Karen'
      , 'Colmenares'
      , 'KCOLMENA'
      , '1.515.555.0119'
      , STR_TO_DATE('10-08-2017', '%d-%m-%Y')
      , 'PU_CLERK'
      , 2500
      , NULL
      , 114
      , 30
      );

  INSERT INTO emps VALUES
      ( 120
      , 'Matthew'
      , 'Weiss'
      , 'MWEISS'
      , '1.650.555.0120'
      , STR_TO_DATE('18-07-2014', '%d-%m-%Y')
      , 'ST_MAN'
      , 8000
      , NULL
      , 100
      , 50
      );

  INSERT INTO emps VALUES
      ( 121
      , 'Adam'
      , 'Fripp'
      , 'AFRIPP'
      , '1.650.555.0121'
      , STR_TO_DATE('10-04-2015', '%d-%m-%Y')
      , 'ST_MAN'
      , 8200
      , NULL
      , 100
      , 50
      );

  INSERT INTO emps VALUES
      ( 122
      , 'Payam'
      , 'Kaufling'
      , 'PKAUFLIN'
      , '1.650.555.0122'
      , STR_TO_DATE('01-05-2013', '%d-%m-%Y')
      , 'ST_MAN'
      , 7900
      , NULL
      , 100
      , 50
      );

  INSERT INTO emps VALUES
      ( 123
      , 'Shanta'
      , 'Vollman'
      , 'SVOLLMAN'
      , '1.650.555.0123'
      , STR_TO_DATE('10-10-2015', '%d-%m-%Y')
      , 'ST_MAN'
      , 6500
      , NULL
      , 100
      , 50
      );

  INSERT INTO emps VALUES
      ( 124
      , 'Kevin'
      , 'Mourgos'
      , 'KMOURGOS'
      , '1.650.555.0124'
      , STR_TO_DATE('16-11-2017', '%d-%m-%Y')
      , 'ST_MAN'
      , 5800
      , NULL
      , 100
      , 50
      );

  INSERT INTO emps VALUES
      ( 125
      , 'Julia'
      , 'Nayer'
      , 'JNAYER'
      , '1.650.555.0125'
      , STR_TO_DATE('16-07-2015', '%d-%m-%Y')
      , 'ST_CLERK'
      , 3200
      , NULL
      , 120
      , 50
      );

  INSERT INTO emps VALUES
      ( 126
      , 'Irene'
      , 'Mikkilineni'
      , 'IMIKKILI'
      , '1.650.555.0126'
      , STR_TO_DATE('28-09-2016', '%d-%m-%Y')
      , 'ST_CLERK'
      , 2700
      , NULL
      , 120
      , 50
      );

  INSERT INTO emps VALUES
      ( 127
      , 'James'
      , 'Landry'
      , 'JLANDRY'
      , '1.650.555.0127'
      , STR_TO_DATE('14-01-2017', '%d-%m-%Y')
      , 'ST_CLERK'
      , 2400
      , NULL
      , 120
      , 50
      );

  INSERT INTO emps VALUES
      ( 128
      , 'Steven'
      , 'Markle'
      , 'SMARKLE'
      , '1.650.555.0128'
      , STR_TO_DATE('08-03-2018', '%d-%m-%Y')
      , 'ST_CLERK'
      , 2200
      , NULL
      , 120
      , 50
      );

  INSERT INTO emps VALUES
      ( 129
      , 'Laura'
      , 'Bissot'
      , 'LBISSOT'
      , '1.650.555.0129'
      , STR_TO_DATE('20-08-2015', '%d-%m-%Y')
      , 'ST_CLERK'
      , 3300
      , NULL
      , 121
      , 50
      );

  INSERT INTO emps VALUES
      ( 130
      , 'Mozhe'
      , 'Atkinson'
      , 'MATKINSO'
      , '1.650.555.0130'
      , STR_TO_DATE('30-10-2015', '%d-%m-%Y')
      , 'ST_CLERK'
      , 2800
      , NULL
      , 121
      , 50
      );

  INSERT INTO emps VALUES
      ( 131
      , 'James'
      , 'Marlow'
      , 'JAMRLOW'
      , '1.650.555.0131'
      , STR_TO_DATE('16-02-2015', '%d-%m-%Y')
      , 'ST_CLERK'
      , 2500
      , NULL
      , 121
      , 50
      );

  INSERT INTO emps VALUES
      ( 132
      , 'TJ'
      , 'Olson'
      , 'TJOLSON'
      , '1.650.555.0132'
      , STR_TO_DATE('10-04-2017', '%d-%m-%Y')
      , 'ST_CLERK'
      , 2100
      , NULL
      , 121
      , 50
      );

  INSERT INTO emps VALUES
      ( 133
      , 'Jason'
      , 'Mallin'
      , 'JMALLIN'
      , '1.650.555.0133'
      , STR_TO_DATE('14-06-2014', '%d-%m-%Y')
      , 'ST_CLERK'
      , 3300
      , NULL
      , 122
      , 50
      );

  INSERT INTO emps VALUES
      ( 134
      , 'Michael'
      , 'Rogers'
      , 'MROGERS'
      , '1.650.555.0134'
      , STR_TO_DATE('26-08-2016', '%d-%m-%Y')
      , 'ST_CLERK'
      , 2900
      , NULL
      , 122
      , 50
      );

  INSERT INTO emps VALUES
      ( 135
      , 'Ki'
      , 'Gee'
      , 'KGEE'
      , '1.650.555.0135'
      , STR_TO_DATE('12-12-2017', '%d-%m-%Y')
      , 'ST_CLERK'
      , 2400
      , NULL
      , 122
      , 50
      );

  INSERT INTO emps VALUES
      ( 136
      , 'Hazel'
      , 'Philtanker'
      , 'HPHILTAN'
      , '1.650.555.0136'
      , STR_TO_DATE('06-02-2018', '%d-%m-%Y')
      , 'ST_CLERK'
      , 2200
      , NULL
      , 122
      , 50
      );

  INSERT INTO emps VALUES
      ( 137
      , 'Renske'
      , 'Ladwig'
      , 'RLADWIG'
      , '1.650.555.0137'
      , STR_TO_DATE('14-07-2013', '%d-%m-%Y')
      , 'ST_CLERK'
      , 3600
      , NULL
      , 123
      , 50
      );

  INSERT INTO emps VALUES
      ( 138
      , 'Stephen'
      , 'Stiles'
      , 'SSTILES'
      , '1.650.555.0138'
      , STR_TO_DATE('26-10-2015', '%d-%m-%Y')
      , 'ST_CLERK'
      , 3200
      , NULL
      , 123
      , 50
      );

  INSERT INTO emps VALUES
      ( 139
      , 'John'
      , 'Seo'
      , 'JSEO'
      , '1.650.555.0139'
      , STR_TO_DATE('12-02-2016', '%d-%m-%Y')
      , 'ST_CLERK'
      , 2700
      , NULL
      , 123
      , 50
      );

  INSERT INTO emps VALUES
      ( 140
      , 'Joshua'
      , 'Patel'
      , 'JPATEL'
      , '1.650.555.0140'
      , STR_TO_DATE('06-04-2016', '%d-%m-%Y')
      , 'ST_CLERK'
      , 2500
      , NULL
      , 123
      , 50
      );

  INSERT INTO emps VALUES
      ( 141
      , 'Trenna'
      , 'Rajs'
      , 'TRAJS'
      , '1.650.555.0141'
      , STR_TO_DATE('17-10-2013', '%d-%m-%Y')
      , 'ST_CLERK'
      , 3500
      , NULL
      , 124
      , 50
      );

  INSERT INTO emps VALUES
      ( 142
      , 'Curtis'
      , 'Davies'
      , 'CDAVIES'
      , '1.650.555.0142'
      , STR_TO_DATE('29-01-2015', '%d-%m-%Y')
      , 'ST_CLERK'
      , 3100
      , NULL
      , 124
      , 50
      );

  INSERT INTO emps VALUES
      ( 143
      , 'Randall'
      , 'Matos'
      , 'RMATOS'
      , '1.650.555.0143'
      , STR_TO_DATE('15-03-2016', '%d-%m-%Y')
      , 'ST_CLERK'
      , 2600
      , NULL
      , 124
      , 50
      );

  INSERT INTO emps VALUES
      ( 144
      , 'Peter'
      , 'Vargas'
      , 'PVARGAS'
      , '1.650.555.0144'
      , STR_TO_DATE('09-07-2016', '%d-%m-%Y')
      , 'ST_CLERK'
      , 2500
      , NULL
      , 124
      , 50
      );

  INSERT INTO emps VALUES
      ( 145
      , 'John'
      , 'Singh'
      , 'JSINGH'
      , '44.1632.960000'
      , STR_TO_DATE('01-10-2014', '%d-%m-%Y')
      , 'SA_MAN'
      , 14000
      , .4
      , 100
      , 80
      );

  INSERT INTO emps VALUES
      ( 146
      , 'Karen'
      , 'Partners'
      , 'KPARTNER'
      , '44.1632.960001'
      , STR_TO_DATE('05-01-2015', '%d-%m-%Y')
      , 'SA_MAN'
      , 13500
      , .3
      , 100
      , 80
      );

  INSERT INTO emps VALUES
      ( 147
      , 'Alberto'
      , 'Errazuriz'
      , 'AERRAZUR'
      , '44.1632.960002'
      , STR_TO_DATE('10-03-2015', '%d-%m-%Y')
      , 'SA_MAN'
      , 12000
      , .3
      , 100
      , 80
      );

  INSERT INTO emps VALUES
      ( 148
      , 'Gerald'
      , 'Cambrault'
      , 'GCAMBRAU'
      , '44.1632.960003'
      , STR_TO_DATE('15-10-2017', '%d-%m-%Y')
      , 'SA_MAN'
      , 11000
      , .3
      , 100
      , 80
      );

  INSERT INTO emps VALUES
      ( 149
      , 'Eleni'
      , 'Zlotkey'
      , 'EZLOTKEY'
      , '44.1632.960004'
      , STR_TO_DATE('29-01-2018', '%d-%m-%Y')
      , 'SA_MAN'
      , 10500
      , .2
      , 100
      , 80
      );

  INSERT INTO emps VALUES
      ( 150
      , 'Sean'
      , 'Tucker'
      , 'STUCKER'
      , '44.1632.960005'
      , STR_TO_DATE('30-01-2015', '%d-%m-%Y')
      , 'SA_REP'
      , 10000
      , .3
      , 145
      , 80
      );

  INSERT INTO emps VALUES
      ( 151
      , 'David'
      , 'Bernstein'
      , 'DBERNSTE'
      , '44.1632.960006'
      , STR_TO_DATE('24-03-2015', '%d-%m-%Y')
      , 'SA_REP'
      , 9500
      , .25
      , 145
      , 80
      );

  INSERT INTO emps VALUES
      ( 152
      , 'Peter'
      , 'Hall'
      , 'PHALL'
      , '44.1632.960007'
      , STR_TO_DATE('20-08-2015', '%d-%m-%Y')
      , 'SA_REP'
      , 9000
      , .25
      , 145
      , 80
      );

  INSERT INTO emps VALUES
      ( 153
      , 'Christopher'
      , 'Olsen'
      , 'COLSEN'
      , '44.1632.960008'
      , STR_TO_DATE('30-03-2016', '%d-%m-%Y')
      , 'SA_REP'
      , 8000
      , .2
      , 145
      , 80
      );

  INSERT INTO emps VALUES
      ( 154
      , 'Nanette'
      , 'Cambrault'
      , 'NCAMBRAU'
      , '44.1632.960009'
      , STR_TO_DATE('09-12-2016', '%d-%m-%Y')
      , 'SA_REP'
      , 7500
      , .2
      , 145
      , 80
      );

  INSERT INTO emps VALUES
      ( 155
      , 'Oliver'
      , 'Tuvault'
      , 'OTUVAULT'
      , '44.1632.960010'
      , STR_TO_DATE('23-11-2017', '%d-%m-%Y')
      , 'SA_REP'
      , 7000
      , .15
      , 145
      , 80
      );

  INSERT INTO emps VALUES
      ( 156
      , 'Janette'
      , 'King'
      , 'JKING'
      , '44.1632.960011'
      , STR_TO_DATE('30-01-2014', '%d-%m-%Y')
      , 'SA_REP'
      , 10000
      , .35
      , 146
      , 80
      );

  INSERT INTO emps VALUES
      ( 157
      , 'Patrick'
      , 'Sully'
      , 'PSULLY'
      , '44.1632.960012'
      , STR_TO_DATE('04-03-2014', '%d-%m-%Y')
      , 'SA_REP'
      , 9500
      , .35
      , 146
      , 80
      );

  INSERT INTO emps VALUES
      ( 158
      , 'Allan'
      , 'McEwen'
      , 'AMCEWEN'
      , '44.1632.960013'
      , STR_TO_DATE('01-08-2014', '%d-%m-%Y')
      , 'SA_REP'
      , 9000
      , .35
      , 146
      , 80
      );

  INSERT INTO emps VALUES
      ( 159
      , 'Lindsey'
      , 'Smith'
      , 'LSMITH'
      , '44.1632.960014'
      , STR_TO_DATE('10-03-2015', '%d-%m-%Y')
      , 'SA_REP'
      , 8000
      , .3
      , 146
      , 80
      );

  INSERT INTO emps VALUES
      ( 160
      , 'Louise'
      , 'Doran'
      , 'LDORAN'
      , '44.1632.960015'
      , STR_TO_DATE('15-12-2015', '%d-%m-%Y')
      , 'SA_REP'
      , 7500
      , .3
      , 146
      , 80
      );

  INSERT INTO emps VALUES
      ( 161
      , 'Sarath'
      , 'Sewall'
      , 'SSEWALL'
      , '44.1632.960016'
      , STR_TO_DATE('03-11-2016', '%d-%m-%Y')
      , 'SA_REP'
      , 7000
      , .25
      , 146
      , 80
      );

  INSERT INTO emps VALUES
      ( 162
      , 'Clara'
      , 'Vishney'
      , 'CVISHNEY'
      , '44.1632.960017'
      , STR_TO_DATE('11-11-2015', '%d-%m-%Y')
      , 'SA_REP'
      , 10500
      , .25
      , 147
      , 80
      );

  INSERT INTO emps VALUES
      ( 163
      , 'Danielle'
      , 'Greene'
      , 'DGREENE'
      , '44.1632.960018'
      , STR_TO_DATE('19-03-2017', '%d-%m-%Y')
      , 'SA_REP'
      , 9500
      , .15
      , 147
      , 80
      );

  INSERT INTO emps VALUES
      ( 164
      , 'Mattea'
      , 'Marvins'
      , 'MMARVINS'
      , '44.1632.960019'
      , STR_TO_DATE('24-01-2018', '%d-%m-%Y')
      , 'SA_REP'
      , 7200
      , .10
      , 147
      , 80
      );

  INSERT INTO emps VALUES
      ( 165
      , 'David'
      , 'Lee'
      , 'DLEE'
      , '44.1632.960020'
      , STR_TO_DATE('23-02-2018', '%d-%m-%Y')
      , 'SA_REP'
      , 6800
      , .1
      , 147
      , 80
      );

  INSERT INTO emps VALUES
      ( 166
      , 'Sundar'
      , 'Ande'
      , 'SANDE'
      , '44.1632.960021'
      , STR_TO_DATE('24-03-2018', '%d-%m-%Y')
      , 'SA_REP'
      , 6400
      , .10
      , 147
      , 80
      );

  INSERT INTO emps VALUES
      ( 167
      , 'Amit'
      , 'Banda'
      , 'ABANDA'
      , '44.1632.960022'
      , STR_TO_DATE('21-04-2018', '%d-%m-%Y')
      , 'SA_REP'
      , 6200
      , .10
      , 147
      , 80
      );

  INSERT INTO emps VALUES
      ( 168
      , 'Lisa'
      , 'Ozer'
      , 'LOZER'
      , '44.1632.960023'
      , STR_TO_DATE('11-03-2015', '%d-%m-%Y')
      , 'SA_REP'
      , 11500
      , .25
      , 148
      , 80
      );

  INSERT INTO emps VALUES
      ( 169
      , 'Harrison'
      , 'Bloom'
      , 'HBLOOM'
      , '44.1632.960024'
      , STR_TO_DATE('23-03-2016', '%d-%m-%Y')
      , 'SA_REP'
      , 10000
      , .20
      , 148
      , 80
      );

  INSERT INTO emps VALUES
      ( 170
      , 'Tayler'
      , 'Fox'
      , 'TFOX'
      , '44.1632.960025'
      , STR_TO_DATE('24-01-2016', '%d-%m-%Y')
      , 'SA_REP'
      , 9600
      , .20
      , 148
      , 80
      );

  INSERT INTO emps VALUES
      ( 171
      , 'William'
      , 'Smith'
      , 'WSMITH'
      , '44.1632.960026'
      , STR_TO_DATE('23-02-2017', '%d-%m-%Y')
      , 'SA_REP'
      , 7400
      , .15
      , 148
      , 80
      );

  INSERT INTO emps VALUES
      ( 172
      , 'Elizabeth'
      , 'Bates'
      , 'EBATES'
      , '44.1632.960027'
      , STR_TO_DATE('24-03-2017', '%d-%m-%Y')
      , 'SA_REP'
      , 7300
      , .15
      , 148
      , 80
      );

  INSERT INTO emps VALUES
      ( 173
      , 'Sundita'
      , 'Kumar'
      , 'SKUMAR'
      , '44.1632.960028'
      , STR_TO_DATE('21-04-2018', '%d-%m-%Y')
      , 'SA_REP'
      , 6100
      , .10
      , 148
      , 80
      );

  INSERT INTO emps VALUES
      ( 174
      , 'Ellen'
      , 'Abel'
      , 'EABEL'
      , '44.1632.960029'
      , STR_TO_DATE('11-05-2014', '%d-%m-%Y')
      , 'SA_REP'
      , 11000
      , .30
      , 149
      , 80
      );

  INSERT INTO emps VALUES
      ( 175
      , 'Alyssa'
      , 'Hutton'
      , 'AHUTTON'
      , '44.1632.960030'
      , STR_TO_DATE('19-03-2015', '%d-%m-%Y')
      , 'SA_REP'
      , 8800
      , .25
      , 149
      , 80
      );

  INSERT INTO emps VALUES
      ( 176
      , 'Jonathon'
      , 'Taylor'
      , 'JTAYLOR'
      , '44.1632.960031'
      , STR_TO_DATE('24-03-2016', '%d-%m-%Y')
      , 'SA_REP'
      , 8600
      , .20
      , 149
      , 80
      );

  INSERT INTO emps VALUES
      ( 177
      , 'Jack'
      , 'Livingston'
      , 'JLIVINGS'
      , '44.1632.960032'
      , STR_TO_DATE('23-04-2016', '%d-%m-%Y')
      , 'SA_REP'
      , 8400
      , .20
      , 149
      , 80
      );

  INSERT INTO emps VALUES
      ( 178
      , 'Kimberely'
      , 'Grant'
      , 'KGRANT'
      , '44.1632.960033'
      , STR_TO_DATE('24-05-2017', '%d-%m-%Y')
      , 'SA_REP'
      , 7000
      , .15
      , 149
      , NULL
      );

  INSERT INTO emps VALUES
      ( 179
      , 'Charles'
      , 'Johnson'
      , 'CJOHNSON'
      , '44.1632.960034'
      , STR_TO_DATE('04-01-2018', '%d-%m-%Y')
      , 'SA_REP'
      , 6200
      , .10
      , 149
      , 80
      );

  INSERT INTO emps VALUES
      ( 180
      , 'Winston'
      , 'Taylor'
      , 'WTAYLOR'
      , '1.650.555.0145'
      , STR_TO_DATE('24-01-2016', '%d-%m-%Y')
      , 'SH_CLERK'
      , 3200
      , NULL
      , 120
      , 50
      );

  INSERT INTO emps VALUES
      ( 181
      , 'Jean'
      , 'Fleaur'
      , 'JFLEAUR'
      , '1.650.555.0146'
      , STR_TO_DATE('23-02-2016', '%d-%m-%Y')
      , 'SH_CLERK'
      , 3100
      , NULL
      , 120
      , 50
      );

  INSERT INTO emps VALUES
      ( 182
      , 'Martha'
      , 'Sullivan'
      , 'MSULLIVA'
      , '1.650.555.0147'
      , STR_TO_DATE('21-06-2017', '%d-%m-%Y')
      , 'SH_CLERK'
      , 2500
      , NULL
      , 120
      , 50
      );

  INSERT INTO emps VALUES
      ( 183
      , 'Girard'
      , 'Geoni'
      , 'GGEONI'
      , '1.650.555.0148'
      , STR_TO_DATE('03-02-2018', '%d-%m-%Y')
      , 'SH_CLERK'
      , 2800
      , NULL
      , 120
      , 50
      );

  INSERT INTO emps VALUES
      ( 184
      , 'Nandita'
      , 'Sarchand'
      , 'NSARCHAN'
      , '1.650.555.0149'
      , STR_TO_DATE('27-01-2014', '%d-%m-%Y')
      , 'SH_CLERK'
      , 4200
      , NULL
      , 121
      , 50
      );

  INSERT INTO emps VALUES
      ( 185
      , 'Alexis'
      , 'Bull'
      , 'ABULL'
      , '1.650.555.0150'
      , STR_TO_DATE('20-02-2015', '%d-%m-%Y')
      , 'SH_CLERK'
      , 4100
      , NULL
      , 121
      , 50
      );

  INSERT INTO emps VALUES
      ( 186
      , 'Julia'
      , 'Dellinger'
      , 'JDELLING'
      , '1.650.555.0151'
      , STR_TO_DATE('24-06-2016', '%d-%m-%Y')
      , 'SH_CLERK'
      , 3400
      , NULL
      , 121
      , 50
      );

  INSERT INTO emps VALUES
      ( 187
      , 'Anthony'
      , 'Cabrio'
      , 'ACABRIO'
      , '1.650.555.0152'
      , STR_TO_DATE('07-02-2017', '%d-%m-%Y')
      , 'SH_CLERK'
      , 3000
      , NULL
      , 121
      , 50
      );

  INSERT INTO emps VALUES
      ( 188
      , 'Kelly'
      , 'Chung'
      , 'KCHUNG'
      , '1.650.555.0153'
      , STR_TO_DATE('14-06-2015', '%d-%m-%Y')
      , 'SH_CLERK'
      , 3800
      , NULL
      , 122
      , 50
      );

  INSERT INTO emps VALUES
      ( 189
      , 'Jennifer'
      , 'Dilly'
      , 'JDILLY'
      , '1.650.555.0154'
      , STR_TO_DATE('13-08-2015', '%d-%m-%Y')
      , 'SH_CLERK'
      , 3600
      , NULL
      , 122
      , 50
      );

  INSERT INTO emps VALUES
      ( 190
      , 'Timothy'
      , 'Venzl'
      , 'TVENZL'
      , '1.650.555.0155'
      , STR_TO_DATE('11-07-2016', '%d-%m-%Y')
      , 'SH_CLERK'
      , 2900
      , NULL
      , 122
      , 50
      );

  INSERT INTO emps VALUES
      ( 191
      , 'Randall'
      , 'Perkins'
      , 'RPERKINS'
      , '1.650.555.0156'
      , STR_TO_DATE('19-12-2017', '%d-%m-%Y')
      , 'SH_CLERK'
      , 2500
      , NULL
      , 122
      , 50
      );

  INSERT INTO emps VALUES
      ( 192
      , 'Sarah'
      , 'Bell'
      , 'SBELL'
      , '1.650.555.0157'
      , STR_TO_DATE('04-02-2014', '%d-%m-%Y')
      , 'SH_CLERK'
      , 4000
      , NULL
      , 123
      , 50
      );

  INSERT INTO emps VALUES
      ( 193
      , 'Britney'
      , 'Everett'
      , 'BEVERETT'
      , '1.650.555.0158'
      , STR_TO_DATE('03-03-2015', '%d-%m-%Y')
      , 'SH_CLERK'
      , 3900
      , NULL
      , 123
      , 50
      );

  INSERT INTO emps VALUES
      ( 194
      , 'Samuel'
      , 'McLeod'
      , 'SMCLEOD'
      , '1.650.555.0159'
      , STR_TO_DATE('01-07-2016', '%d-%m-%Y')
      , 'SH_CLERK'
      , 3200
      , NULL
      , 123
      , 50
      );

  INSERT INTO emps VALUES
      ( 195
      , 'Vance'
      , 'Jones'
      , 'VJONES'
      , '1.650.555.0160'
      , STR_TO_DATE('17-03-2017', '%d-%m-%Y')
      , 'SH_CLERK'
      , 2800
      , NULL
      , 123
      , 50
      );

  INSERT INTO emps VALUES
      ( 196
      , 'Alana'
      , 'Walsh'
      , 'AWALSH'
      , '1.650.555.0161'
      , STR_TO_DATE('24-04-2016', '%d-%m-%Y')
      , 'SH_CLERK'
      , 3100
      , NULL
      , 124
      , 50
      );

  INSERT INTO emps VALUES
      ( 197
      , 'Kevin'
      , 'Feeney'
      , 'KFEENEY'
      , '1.650.555.0162'
      , STR_TO_DATE('23-05-2016', '%d-%m-%Y')
      , 'SH_CLERK'
      , 3000
      , NULL
      , 124
      , 50
      );

  INSERT INTO emps VALUES
      ( 198
      , 'Donald'
      , 'OConnell'
      , 'DOCONNEL'
      , '1.650.555.0163'
      , STR_TO_DATE('21-06-2017', '%d-%m-%Y')
      , 'SH_CLERK'
      , 2600
      , NULL
      , 124
      , 50
      );

  INSERT INTO emps VALUES
      ( 199
      , 'Douglas'
      , 'Grant'
      , 'DGRANT'
      , '1.650.555.0164'
      , STR_TO_DATE('13-01-2018', '%d-%m-%Y')
      , 'SH_CLERK'
      , 2600
      , NULL
      , 124
      , 50
      );

  INSERT INTO emps VALUES
      ( 200
      , 'Jennifer'
      , 'Whalen'
      , 'JWHALEN'
      , '1.515.555.0165'
      , STR_TO_DATE('17-09-2013', '%d-%m-%Y')
      , 'AD_ASST'
      , 4400
      , NULL
      , 101
      , 10
      );

  INSERT INTO emps VALUES
      ( 201
      , 'Michael'
      , 'Martinez'
      , 'MMARTINE'
      , '1.515.555.0166'
      , STR_TO_DATE('17-02-2014', '%d-%m-%Y')
      , 'MK_MAN'
      , 13000
      , NULL
      , 100
      , 20
      );

  INSERT INTO emps VALUES
      ( 202
      , 'Pat'
      , 'Davis'
      , 'PDAVIS'
      , '1.603.555.0167'
      , STR_TO_DATE('17-08-2015', '%d-%m-%Y')
      , 'MK_REP'
      , 6000
      , NULL
      , 201
      , 20
      );

  INSERT INTO emps VALUES
      ( 203
      , 'Susan'
      , 'Jacobs'
      , 'SJACOBS'
      , '1.515.555.0168'
      , STR_TO_DATE('07-06-2012', '%d-%m-%Y')
      , 'HR_REP'
      , 6500
      , NULL
      , 101
      , 40
      );

  INSERT INTO emps VALUES
      ( 204
      , 'Hermann'
      , 'Brown'
      , 'HBROWN'
      , '1.515.555.0169'
      , STR_TO_DATE('07-06-2012', '%d-%m-%Y')
      , 'PR_REP'
      , 10000
      , NULL
      , 101
      , 70
      );

  INSERT INTO emps VALUES
      ( 205
      , 'Shelley'
      , 'Higgins'
      , 'SHIGGINS'
      , '1.515.555.0170'
      , STR_TO_DATE('07-06-2012', '%d-%m-%Y')
      , 'AC_MGR'
      , 12008
      , NULL
      , 101
      , 110
      );

  INSERT INTO emps VALUES
      ( 206
      , 'William'
      , 'Gietz'
      , 'WGIETZ'
      , '1.515.555.0171'
      , STR_TO_DATE('07-06-2012', '%d-%m-%Y')
      , 'AC_ACCOUNT'
      , 8300
      , NULL
      , 205
      , 110
      );