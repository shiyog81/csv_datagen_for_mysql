# csv_datagen_for_mysql

## CSV data file generator for mysql tables

using this perl script, we can generate a large csv file for mysql tables. Pls find below steps to run this script

1. connect to mysql server and create database test and table emp

```python
CREATE TABLE emp(
  empno BIGINT PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(30) NOT NULL,
  last_name VARCHAR(30) NOT NULL,
  sex CHAR(1),
  phone_no CHAR(10),
  dob date,
  hiredate date,
  job VARCHAR(30),
  dept CHAR(2),
  salary DECIMAL(9,2),
  bonus DECIMAL(9,2),
  comm DECIMAL(9,2)
 );
```
2. run the script with the command line options
   
```python
[root@ol2 csv_datagen_for_mysql]# perl csv_data_generator.pl --debug 1 --host 192.168.1.22 --port 3306 --user dba --password insT4Win# --database test --tabname emp --rows 2 --start 21 --datafile data1.csv

*******************************************************
************ generating csv file for table ************
*******************************************************
dir = /home/shiva/csv_datagen_for_mysql/
file = /home/shiva/csv_datagen_for_mysql/data1.csv
DBI available drivers
DBM, ExampleP, File, Gofer, Mem, SQLite, Sponge, mysql

dsn = dbi:mysql:host=192.168.1.22:port=3306:user=dba:password=insT4Win#:database=test:mysql_ssl_verify_server_cert=0

sql = SELECT COLUMN_NAME, DATA_TYPE, COLUMN_TYPE, EXTRA FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'test' AND TABLE_NAME = 'emp' ORDER BY ORDINAL_POSITION;

$VAR1 = [
          [
            'empno',
            'bigint',
            'bigint',
            'auto_increment'
          ],
          [
            'first_name',
            'varchar',
            'varchar(30)',
            ''
          ],
          [
            'last_name',
            'varchar',
            'varchar(30)',
            ''
          ],
          [
            'sex',
            'char',
            'char(1)',
            ''
          ],
          [
            'phone_no',
            'char',
            'char(10)',
            ''
          ],
          [
            'dob',
            'date',
            'date',
            ''
          ],
          [
            'hiredate',
            'date',
            'date',
            ''
          ],
          [
            'job',
            'varchar',
            'varchar(30)',
            ''
          ],
          [
            'dept',
            'char',
            'char(2)',
            ''
          ],
          [
            'salary',
            'decimal',
            'decimal(9,2)',
            ''
          ],
          [
            'bonus',
            'decimal',
            'decimal(9,2)',
            ''
          ],
          [
            'comm',
            'decimal',
            'decimal(9,2)',
            ''
          ]
        ];
print table structure
=====================
empno,bigint,bigint,auto_increment
first_name,varchar,varchar(30),
last_name,varchar,varchar(30),
sex,char,char(1),
phone_no,char,char(10),
dob,date,date,
hiredate,date,date,
job,varchar,varchar(30),
dept,char,char(2),
salary,decimal,decimal(9,2),
bonus,decimal,decimal(9,2),
comm,decimal,decimal(9,2),

datafile generated successfully

data file size = 239 bytes
```

3. the script generated data1.csv like this
   
```python
[root@ol2 csv_datagen_for_mysql]# cat data1.csv 
21,"Adishree","Jyotishmati","F","7964582640","2018-1-24","2000-10-30","accounts manager","03","5238119.37","0846986.70","8910478.23"
22,"Satyaki","Deepashikha","F","8693896665","1990-6-3","2010-9-26","accounts manager","73","9209135.74","1680648.55","8874744.72"
```

4. use this option to generate 100 rows starts from 1

```python
perl csv_data_generator.pl --debug 1 --host 192.168.1.22 --port 3306 --user dba --password insT4Win# --database test --tabname emp --rows 100 --start 1 --datafile data1.csv
```


