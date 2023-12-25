yum install -y wget gcc pam-devel libselinux-devel zlib-devel openssl-devel

yum -y install mysql-server mysql mysql-devel
1.编辑/etc/my.cnf文件，在 [mysqld] 最下面添加
skip-grant-tables #跳过数据库权限验证
/usr/sbin/mysqld --skip-grant-tables

ALTER USER 'root'@'localhost' IDENTIFIED BY 'sdc@BJTU1011';
openssl 3.1.2
忽略大小写
lower_case_table_names=1

grep "password" /var/log/mysql/mysqld.log 


ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'sdc@BJTU1011';
FLUSH PRIVILEGES;
mysql -u root -p

GRANT ALL PRIVILEGES ON *.* TO 'sdc1011'@'%' IDENTIFIED BY 'sdc@BJTU1011' WITH GRANT OPTION;
FLUSH PRIVILEGES;

GRANT ALL PRIVILEGES ON *.* TO 'sdc1011'@'%' IDENTIFIED BY 'sdc@BJTU1011' WITH GRANT OPTION;
FLUSH PRIVILEGES;
