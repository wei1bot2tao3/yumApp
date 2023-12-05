nginx 1.25.1
mysql 8.0.34
openssl 3.1.2
openssh 9.4


yum -y install mysql-server mysql mysql-devel
1.编辑/etc/my.cnf文件，在 [mysqld] 最下面添加
skip-grant-tables #跳过数据库权限验证
ALTER USER 'root'@'localhost' IDENTIFIED BY 'sdc@BJTU1011';
openssl 3.1.2

sudo yum groupinstall "Development Tools"
sudo yum install perl perl-devel openssl-devel


tar xf openssl-3.1.0-alpha1.tar.gz
cd openssl-3.1.0-alpha1
./config && make && make install



5.优化openssl路径，依次执行下方命令
echo "/usr/local/lib64/" >> /etc/ld.so.conf
ldconfig
mv /usr/bin/openssl /usr/bin/openssl.old
ln -sv /usr/local/bin/openssl /usr/bin/openssl

cp /etc/ssh/sshd_config sshd_config.backup
cp /etc/pam.d/sshd sshd.backup
rpm -e --nodeps `rpm -qa | grep openssh`
tar -zxvf openssh.tar.gz
cd openssh-9.0p1

c
chmod 600 /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_ed25519_key
复制
复制配置文件

cp -a contrib/redhat/sshd.init /etc/init.d/sshd
chmod u+x /etc/init.d/sshd
复制
还原配置文件

mv ../sshd.backup /etc/pam.d/sshd
mv ../sshd_config.backup /etc/ssh/sshd_config
复制
添加添加自启服务ssh到开机启动项

chkconfig --add sshd
chkconfig sshd on
复制
重启服务

systemctl restart sshd
复制
验证结果
查看下安装结果：

ssh -V