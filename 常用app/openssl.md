nginx 1.25.1
mysql 8.0.34
openssl 3.1.2
openssh 9.4


2.需要将openssh升级到最新版本 直接yum安装即可
yum install openssh -y

3.安装需要的依赖包
yum -y install gcc gcc-c++ kernel-devel perl-IPC-Cmd

二、安装包准备
1.下载安装包
zlib-1.2.13.tar.gz 下载地址：https://www.zlib.net/fossils/zlib-1.2.13.tar.gz
也可以直接下载：wget https://www.zlib.net/fossils/zlib-1.2.13.tar.gz
openssl-3.1.2.tar.gz 下载地址：
wget https://www.openssl.org/source/openssl-3.1.2.tar.gz
openssh-9.5p1.tar.gz 下载地址：
http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.4p1.tar.gz
也可以直接下载：wget  http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.5p1.tar.gz

2.安装包解压到/usr/local/src下⾯
tar xf openssh-9.5p1.tar.gz -C /usr/local/src/
tar xf openssl-3.1.2.tar.gz -C /usr/local/src/
tar xf zlib-1.2.13.tar.gz -C /usr/local/src/
ll /usr/local/src/

三、安装
1、安装zlib-1.2.13.tar.gz
cd /usr/local/src/zlib-1.2.13/
./configure --prefix=/usr/local/zlib
make -j 4 && make install

2.安装 openssl-3.1.2.tar.gz
cd /usr/local/src/openssl-3.1.2/
#备份默认的openssl，防止升级失败恢复
mv /usr/bin/openssl /usr/bin/openssl.bak
rm -rf /usr/local/ssl
cd /usr/local/src/openssl-3.1.2/
mkdir /usr/local/ssl1
./config --prefix=/usr/local/ssl -d shared
make -j 4 && make install
echo '/usr/local/ssl/lib' >> /etc/ld.so.conf
ldconfig -v

ln -s /usr/local/ssl/bin/openssl  /usr/bin/openssl
ln -s /usr/local/ssl/include/openssl  /usr/include/openssl
ln -s /usr/local/ssl/lib64/libssl.so.3 /usr/lib64/libssl.so.3
ln -s /usr/local/ssl/lib64/libcrypto.so.3 /usr/lib64/libcrypto.so.3
openssl version -a

3、安装openssh-9.5p1.tar.gz
mv /etc/ssh /etc/ssh.bak
cd /usr/local/src/openssh-9.5p1/
./configure --prefix=/usr/local/openssh --sysconfdir=/etc/ssh --with-ssl-dir=/usr/local/ssl --with-zlib=/usr/local/zlib
make -j 4 && make install

sshd_config⽂件修改
echo "X11Forwarding yes" >> /etc/ssh/sshd_config
echo "X11UseLocalhost no" >> /etc/ssh/sshd_config
echo "XAuthLocation /usr/bin/xauth" >> /etc/ssh/sshd_config
echo "UseDNS no" >> /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config


备份 /etc/ssh 原有⽂件，并将新的配置复制到指定⽬录
mv /usr/sbin/sshd /usr/sbin/sshd.bak
cp -rf /usr/local/openssh/sbin/sshd /usr/sbin/sshd
mv /usr/bin/ssh /usr/bin/ssh.bak
cp -rf /usr/local/openssh/bin/ssh /usr/bin/ssh
mv /usr/bin/ssh-keygen /usr/bin/ssh-keygen.bak
cp -rf /usr/local/openssh/bin/ssh-keygen /usr/bin/ssh-keygen

查看版本
ssh -V


四、启动 sshd
1.指令 systemctl start sshd
systemctl status sshd
systemctl stop sshd


2.直接systemctl start sshd，启动不起来，报错，但⽤sshd -t检查也没有啥错，就提示timeout
问题解决：先停掉sshd服务，将systemctl原服务器删除，使⽤安装包⾥⾃带的sshd.init，复制到/etc/init.d/sshd，重启即可
systemctl stop sshd.service
rm -rf /lib/systemd/system/sshd.service
systemctl daemon-reload
cp /usr/local/src/openssh-9.5p1/contrib/redhat/sshd.init  /etc/init.d/sshd
/etc/init.d/sshd restart
systemctl status sshd