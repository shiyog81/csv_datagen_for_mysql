# csv_datagen_for_mysql

## CSV data file generator for mysql tables

using this perl script, we can generate a large csv file for mysql tables.

How to run this script

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



