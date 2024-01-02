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

GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

要解决这个问题，您可以尝试以下步骤：

停止MySQL服务器：

systemctl stop mysqld

复制代码
以跳过授权表的方式启动MySQL服务器：

/usr/sbin/mysqld --skip-grant-tables

复制代码
连接到MySQL服务器：

mysql -u root

复制代码
执行以下命令更改root用户的密码：

UPDATE mysql.user SET authentication_string=PASSWORD('sdc@BJTU1011') WHERE User='root' AND Host='localhost';
FLUSH PRIVILEGES;

复制代码
退出MySQL客户端：

exit

复制代码
停止MySQL服务器：

systemctl stop mysqld

复制代码
以正常方式启动MySQL服务器：

systemctl start mysqld