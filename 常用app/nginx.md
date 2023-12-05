
1、进入到压缩包所在目录
cd /usr/local/nginx
2、解压Nginx压缩包
tar -zxvf nginx-1.25.3.tar.gz
3、进入nginx目录
cd /usr/local/nginx/nginx-1.22.1
4、执行configure命令
./configure
5、执行make命令
make
6、确认是否安装
make install

-z: 表示使用 gzip 解压。
-x: 表示提取文件。
-v: 表示显示详细信息，即解压的过程中显示文件名。
-f: 表示后面紧跟的是要解压的文件。
vim /etc/systemd/system/nginx.service

[Unit]
Description=nginx service
After=network.target

[Service]
User=root
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s stop
ExecStartPre=/bin/sleep 10

[Install]
WantedBy=multi-user.target

echo 'export PATH=$PATH:/usr/local/nginx/sbin' >> ~/.bashrc
source ~/.bashrc

sudo ln -s /usr/local/nginx/sbin/nginx /usr/local/bin/nginx


curl http://59.64.4.210

# 停止 firewalld 服务
sudo systemctl stop firewalld

# 禁止 firewalld 开机启动
sudo systemctl disable firewalld

