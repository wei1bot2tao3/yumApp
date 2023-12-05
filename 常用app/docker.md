

270  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
275  yum list docker-ce --showduplicates|sort -r
276   yum -y install docker-ce-24.0.2
