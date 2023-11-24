# StarGo v2.3 说明文档

### 一、StarGo介绍

StarGo 是用于管理多个 StarRocks 集群的命令行工具，通过 StarGo 我们可以进行多集群的部署、查看、启停、调参、升级、降级及扩缩容等操作。



### 二、文件说明

当前版本的安装包名称为 stargo-v2.3.tar.gz，解压进入目录后将看到如下 6 个文件：

```shell
[root@starrocks stargo-v2.3]# ll -h
total 61M
-rw-r--r-- 1 root root 3.5K Oct  17 13:14 deploy-template.yaml
-rwxr-xr-x 1 root root  12K Oct  17 13:14 env_check.sh
-rw-r--r-- 1 root root  52M Oct  17 13:14 jdk8u362-b09.tar.gz
-rw-r--r-- 1 root root  88K Oct  17 13:14 README.md
-rw-r--r-- 1 root root  186 Oct  17 13:14 repo.yaml
-rwxr-xr-x 1 root root 8.8M Oct  17 13:14 stargo
```

#### 2.1 deploy-template.yaml

`deploy-template.yaml` 是集群配置信息的拓扑文件模板，我们可根据该模板来编辑目标集群的 yaml 配置文件，具体的参数说明见**[第四章](###四、YAML文件说明)**。

#### 2.2 env_check.sh

`env_check.sh` 是配合 StarGo 进行部署前环境检查的 shell 脚本，用来检查当前服务器的 CPU、系统内核、端口占用、重要系统参数等是否符合 StarRocks 的部署要求，对检查通过的项打印绿色的 success，未通过的项会以红色字体给出提示及调参说明。具体的检测项说明见**[附录](###附录：环境检测脚本说明)**。

该脚本需要手动的在集群中的每台服务器中执行。stargo 主程序在运行时也会对集群所有的节点进行数项关键参数的校验，但在部署前仍然建议手动运行检测脚本，并根据提示对集群进行完整的调参。

注意：检测脚本对检测异常项给出的调参语句大多为临时调整命令（即执行后立刻生效，重启服务器后会失效），永久修改的方法可参考**[官方文档](https://docs.mirrorship.cn/zh-cn/latest/deployment/environment_configurations)**。

#### 2.3 jdk8u362-b09.tar.gz

`jdk8u362-b09.tar.gz` 是 StarGo 内置的 [Eclipse Temurin OpenJDK](https://github.com/adoptium/temurin8-binaries/releases)（精简了官方版本的源码包和说明文档），该 JDK 已经过社区多轮的兼容性测试验证，可以稳定使用。StarGo 会为部署的每个实例分发一份 JDK 并在其启动脚本中添加程序级的环境变量。

若希望集群使用 Oracle JDK，可在部署集群前将 Oracle 官方 [jdk-8u201-linux-x64.tar.gz](https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html) 或 [jdk-11.0.2_linux-x64_bin.tar.gz](https://www.oracle.com/java/technologies/javase/jdk11-archive-downloads.html) 放入 StarGo 目录（仅额外支持了这两个在 Oracle 变更 OTN 许可协议前的可商用版本，StarGo 是以 JDK 包名和解压后的文件夹名称来识别的），当目录内同时存在上述的多个 JDK 时，优先级为 **jdk-11.0.2_linux-x64_bin.tar.gz > jdk-8u201-linux-x64.tar.gz > jdk8u362-b09.tar.gz**。在每次进行集群升降级或扩容操作时，StarGo 都会使用该 JDK 包为 StarRocks 程序重新分发一次 JDK。

说明：自 StarRocks-2.5.10 版本开始，StarRocks 适配了 JDK 11，来使用 G1 GC 获得更好的 GC 性能。暂不推荐使用 JDK 17，社区现阶段测试的还不够充分。新版本的 StarRocks 也支持继续使用 JDK 8，当前只是在程序启动时会有提示，并未强制要求：

`Tips: current JDK version is 8,  JDK 11 or 17 is highly recommended for better GC performance(lower version JDK may not be supported in the future).`

#### 2.4 README.md

`README.md` 是随包附赠的使用说明文档，也即本文档。该文档会随 StarGo 的迭代来补充或删改内容，使用某个版本时以内置的说明文档为准。

#### 2.5 repo.yaml

`repo.yaml` 是 StarGo 获取本地部署包的配置文件。在我们进行部署、升级、降级或扩容操作时我们需要在其中配置目标版本的部署包路径及包名，示例如下：

```yaml
#该配置文件配置部署、升级/降级或扩容时需用的StarRocks二进制包路径及包名：
sr_path: /opt/software/           ## 部署包所在文件夹路径，路径末尾的"/"加或者不加逻辑上都不影响
sr_name: StarRocks-3.1.2.tar.gz   ## 安装包包名。除官网发布的Release安装包外，stargo新版本也支持了自定义安装包，但需保证手动创建压缩包时使用tar -czvf命令（即需要使用gzip压缩），同时安装包文件名与解压后的文件夹名称也要相同，且解压后的文件夹下层需为fe、be、apache_hdfs_broker这三个程序目录（换言之就是需要和官网发布的安装包目录层次相同）。
```
/root/stargo-v2.3/
StarRocks-3.0.7.tar.gz



StarRocks x86 架构下的部署包可从"镜舟科技官网"或"StarRocks 社区官网"获取（ARM 架构下的安装包官网没有提供）：

https://www.mirrorship.cn/zh-CN/download/community（推荐）

https://www.starrocks.io/download/community

在官网下载页中展示有安装包对应的 MD5 信息，推荐在下载完成后核对安装包的 MD5 信息以确认下载的安装包未出现文件损坏：

```shell
[root@starrocks software]# md5sum StarRocks-3.1.2.tar.gz 
8f138e85c24b503cc9e944d4046cf08a  StarRocks-3.1.2.tar.gz
```

#### 2.6 stargo

`stargo` 文件是 StarGo 的核心二进制文件，无需安装，没有特殊依赖，开箱即用，使用前确认文件拥有可执行权限即可。

stargo 程序只需在集群内或者集群外的任意一个节点上放置，若后续需要对 stargo 升级，可直接替换该文件为新版本文件（如果发现内置的 jdk 版本不一致，也需要将 jdk 替换为新版的）。

通过 `./stargo version` 命令可以查看 stargo 的版本信息，执行 `./stargo help` 命令可查看 stargo 支持的所有命令及说明：

```shell
[root@starrocks stargo-v2.3]# ./stargo version
Stargo version： v2.3
Build time： 2023-10-17
```



### 三、快速开始

为方便理解 StarGo 的使用方法，我们以使用 Linux 的 root 用户进行单机部署为例，来做完整的操作演示。

##### 第一步：文件准备

将 StarGo 和 StarRocks 安装包上传到服务器，例如 /root 目录。上传完成后解压 stargo，进入解压后的目录：

```shell
[root@starrocks ~]# ll -h
-rw-r--r-- 1 root root  57M Jun  1 20:59 stargo-v2.3.tar.gz
-rw-r--r-- 1 root root 2.2G Jun  1 20:41 StarRocks-2.5.6.tar.gz
[root@starrocks ~]# tar xvf stargo-v2.3.tar.gz
[root@starrocks ~]# cd stargo-v2.3
```

##### 第二步：环境检测与调优

执行环境检测脚本，并对检测异常项按照脚本给出的提示进行调整，保证脚本中除"内存"项外的其他检查项均提示 success：

```shell
[root@starrocks stargo-v2.3]# ./env_check.sh
```

##### 第三步：SSH免密

StarGo 是通过 SSH 的方式进行文件分发和命令执行的，因此即便单机下是"本机到本机"，仍然需要进行免密的配置（同理，若是部署多台服务器的集群，我们也需要打通 stargo 所在节点到"所有需要分发文件的节点"的 SSH 免密），例如：

```shell
[root@starrocks stargo-v2.3]# ssh-keygen -t rsa
[root@starrocks stargo-v2.3]# ssh-copy-id root@192.168.125.23
```

##### 第四步：目录创建

在部署前我们需要进行简单的目录规划，StarGo 需要我们手动创建好"外层"的文件夹，并保证文件夹为空（主要是要求其中不能有与即将部署的服务名相同的目录，以避免误覆盖写掉之前的集群）。例如，我们将程序部署在 /opt/starrocks 目录下，将数据保存在 /data/starrocks 目录中，那么我们就需要手动创建这两个目录：

```shell
[root@starrocks stargo-v2.3]# mkdir /opt/starrocks
[root@starrocks stargo-v2.3]# mkdir -p /data/starrocks
```

注意：若使用的为非 root 用户，在创建文件夹后，还应注意进行目录的授权。

##### 第五步：编写YAML文件

部署程序会需要我们配置程序的部署目录、数据目录、IP、端口、参数等等，stargo 通过解析我们编写的 YAML 文件来获取这些信息。关于 YAML 中完整的参数介绍我们可以参考**[第四章](###四、YAML文件说明)**，这里我们只需依据模板文件 deploy-template.yaml 简单改写出我们的单节点配置文件，例如：

```yaml
global:
    user: root
    ssh_port: 22

fe_servers:
  - host: 192.168.125.23
    ssh_port: 22
    http_port: 8030
    rpc_port: 9020
    query_port: 9030
    edit_log_port: 9010
    java_heap_mem: 10240
    deploy_dir: /opt/starrocks/fe
    meta_dir: /data/starrocks/fe/meta
    log_dir: /data/starrocks/fe/log
    priority_networks: 192.168.125.23
    role: FOLLOWER
    config:
      run_mode: shared_nothing

be_servers:
  - host: 192.168.125.23
    ssh_port: 22
    be_port: 9060
    webserver_port: 8040
    heartbeat_service_port: 9050
    brpc_port: 8060
    deploy_dir : /opt/starrocks/be
    storage_dir: /data/starrocks/be/storage
    log_dir: /data/starrocks/be/log
    priority_networks: 192.168.125.23
    config:
      mem_limit: 80%

broker_servers:
  - host: 192.168.125.23
    ssh_port: 22
    broker_port: 8000
    deploy_dir : /opt/starrocks/apache_hdfs_broker
    log_dir: /data/starrocks/apache_hdfs_broker/log
    config:
      sys_log_level: INFO
```

##### 第六步：指定安装包路径

StarGo 当前需要使用本地的 StarRocks 安装包（即 StarRocks 安装包需要放在 StarGo 程序所在的服务器上），我们通过 repo.yaml 文件来配置对应的路径与包名，例如本次我们使用 StarRocks-2.5.13 版本，安装包路径在 /root 下：

```shell
[root@starrocks stargo-v2.3]# vim repo.yaml
```

```yaml
#该配置文件配置部署、升级/降级或扩容时需用的StarRocks二进制包路径及包名：
sr_path: /root/
sr_name: StarRocks-2.5.13.tar.gz
```

##### 第七步：执行部署命令

StarGo 部署的过程中不会访问外网，只会使用我们配置的安装包离线部署，我们指定集群名称为 `sr-c1`，版本为我们指定的`2.5.13`，配置文件为上文的`deploy-demo.yaml`:

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster deploy sr-c1 v3.1.4 deploy-template.yaml
```

执行 deploy 命令后，StarGo 会先进行目录、端口、系统参数等的检查，若服务器配置较差，这一步耗时会略长（在stargo 2.3版本，这里添加了一个跳过检查的选项，若确认服务器配置已满足要求，当测试环境检测特别慢时可以按照提示跳过环境检查）。StarGo 会将所有操作的日志打印在控制台上，部署过程中不需要我们进行手动操作，等待部署完成后检查服务，确认 FE、BE、Broker 的进程均存在即可：

```shell
[root@starrocks stargo-v2.3]# ps -ef | egrep 'StarRocksFE|starrocks_be|BrokerBootstrap'
root      16434      1  4 22:06 ?        00:00:13 /opt/starrocks/fe/jdk/bin/java -Dlog4j2.formatMsgNoLookups=true -Xmx10240m -XX:+UseMembar -XX:SurvivorRatio=8 -XX:MaxTenuringThreshold=7 -XX:+PrintGCDateStamps -XX:+PrintGCDetails -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSClassUnloadingEnabled -XX:-CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=80 -XX:SoftRefLRUPolicyMSPerMB=0 -Xloggc:/opt/starrocks/fe/log/fe.gc.log.20230606-220639 com.starrocks.StarRocksFE
root      17615      1  1 22:07 ?        00:00:02 /opt/starrocks/be/lib/starrocks_be
root      18307      1  0 22:07 ?        00:00:00 /opt/starrocks/apache_hdfs_broker/jdk/bin/java -Dlog4j2.formatMsgNoLookups=true -Xmx1024m -Dfile.encoding=UTF-8 com.starrocks.broker.hdfs.BrokerBootstrap
root      18568  13157  0 22:11 pts/1    00:00:00 grep -E --color=auto StarRocksFE|starrocks_be|BrokerBootstrap
```

##### 第八步：访问集群

StarRocks 部署完成后，默认启用 root 用户，密码为空，使用 mysql-client 访问 FE 的 IP 及其 9030 查询端口，即可连接到 StarRocks 进行愉快的后续操作：

```shell
[root@starrocks ~]# mysql -h192.168.125.23 -P9030 -uroot
```

StarRocks 兼容 MySQL 语法，我们也可以使用 DBeaver、SQLYog、DataGrip、Navicat 等可视化工具，将 StarRocks 当作 MySQL（端口使用 9030）来进行连接和查询。

**注意：**

1）单机部署时集群中只有一个 BE，所以在建表时需注意在表属性中设置为单副本（"replication_num" = "1"），具体参考**[官方文档](https://docs.mirrorship.cn/zh-cn/latest/introduction/StarRocks_intro)**，这里不再详述。

2）当修改了 StarRocks 集群的 root 密码，我们也需要修改 StarGo 的元文件，具体介绍及操作见**[第七章](###七、配置集群密码)**。

##### 第九步：一些啰嗦

对 StarGo 有了初步了解后，我们就可以继续向下阅读该文档，体会使用 stargo 管理集群的便捷，例如：

停止集群服务：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster stop sr-c1
```

再次启动集群服务：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster start sr-c1
```

查看集群状态：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster status sr-c1
```



### 四、YAML文件说明

在部署集群前，我们可参考 `deploy-template.yaml` 模板文件，按照规范的 YAML 语法来编辑目标集群的拓扑文件，StarGo 会解析该文件获取 StarRocks 集群部署时需要的 IP、端口、文件路径以及参数配置，各项参数的说明如下：

```yaml
global:
    user: "root"  ## SSH使用的用户，需调整为当前Linux用户
    ssh_port: 22  ## SSH端口，通常无需调整，默认为22端口

##前置说明：该yaml中涉及的所有目录配置，其末尾带不带"/"都可以。
fe_servers:
  - host: 192.168.110.101  ## FE节点的IP，需调整为当前服务器需用的内网IP
    ssh_port: 22           ## SSH端口，通常默认即可
    java_heap_mem: 8192    ## 该项为可选配置，支持配置FE节点JVM的Xmx堆内存，默认为8192，单位为M，不支持手动配置单位。因过小的JVM容易引起稳定性问题，故当前设计为该值需配置为大于默认的8192才会生效。
    http_port: 8030        ## FE http_port，默认为8030端口，若不与其他服务冲突则无需调整。注意：集群中所有FE的http端口需要一致
    rpc_port: 9020         ## FE rpc_port，默认为9020，若不与其他服务冲突则无需调整
    query_port: 9030       ## FE query_port，默认为9030，若不与其他服务冲突则无需调整
    edit_log_port: 9010    ## FE edit_log_port，默认为9010，若不与其他服务冲突则无需调整
    deploy_dir: /opt/starrocks/fe        ## FE部署目录
    meta_dir: /data/starrocks/fe/meta    ## FE元数据目录
    log_dir: /data/starrocks/fe/log      ## FE主要日志目录（fe.log及fe.warn.log）
    priority_networks: 192.168.110.0/24  ## FE IP绑定，需使用CIDR写法来调整为当前服务器IP，例如192.168.110.0/24即表示192.168.110.1~192.168.110.254的IP区间。在服务器存在多网卡或虚拟网卡时，StarRocks需要通过该参数让FE识别到正确网段的IP。若不清楚CIDR的写法，也可直接在这里配置具体的IP，例如：192.168.110.101。无论这里使用哪种写法，StarRocks都不支持在部署完成后变更IP。
    role: FOLLOWER         ## 配置FE的角色，可选择配置FOLLOWER或OBSERVER，不配置该项时默认为FOLLOWER。StarRocks FE要求FOLLOWER角色的节点存活半数以上才能够选主，所以建议集群中FOLLOWER配置为奇数个。OBSERVER节点不会参与选主，其作用仅为拓展FE读的能力，所以对个数无要求，可以为0个或者任意个。
    config:                ## StarGo支持在部署时解析yaml中的参数直接写入StarRocks的配置文件
      sys_log_level: INFO
  - host: 192.168.110.102  ## 同上
    ssh_port: 22
    java_heap_mem: 8192
    http_port: 8030
    rpc_port: 9020
    query_port: 9030
    edit_log_port: 9010
    deploy_dir: /opt/starrocks/fe
    meta_dir: /data/starrocks/fe/meta
    log_dir: /data/starrocks/fe/log
    priority_networks: 192.168.110.0/24
    role: FOLLOWER
    config:
      sys_log_level: INFO
  - host: 192.168.110.103  ## 同上
    ssh_port: 22
    java_heap_mem: 8192
    http_port: 8030
    rpc_port: 9020
    query_port: 9030
    edit_log_port: 9010
    deploy_dir: /opt/starrocks/fe
    meta_dir: /data/starrocks/fe/meta
    log_dir: /data/starrocks/fe/log
    priority_networks: 192.168.110.0/24
    role: FOLLOWER
    config:
      sys_log_level: INFO

be_servers:
  - host: 192.168.110.101  ## BE节点的IP，需调整为当前服务器需用的内网IP
    ssh_port: 22           ## SSH端口，通常默认即可
    be_port: 9060                  ## BE be_port，默认为9060端口，若不与其他服务冲突则无需调整
    webserver_port: 8040           ## BE webserver_port，默认为8040端口，若不与其他服务冲突则无需调整。从StarRocks 3.0版本开始，该参数在be.conf中被修改为了be_http_port并在BE代码中做了兼容适配，我们使用be_http_port或继续使用webserver_port都可以正常识别，但若两个参数同时存在，会以be_http_port参数为准。stargo在2.2-patch1中对该变更进行了适配，不论在yaml中该处使用webserver_port还是be_http_port，最终在集群be.conf中都只保留使用webserver_port来保证兼容。
    heartbeat_service_port: 9050   ## BE heartbeat_service_port，默认为9050端口，若不与其他服务冲突则无需调整
    brpc_port: 8060                ## BE brpc_port，默认为8060端口，若不与其他服务冲突则无需调整
    deploy_dir : /opt/starrocks/be    ## BE程序的分发部署目录
    storage_dir: /data1/starrocks/be/storage,medium:SSD;/data2/starrocks/be/storage   ## BE数据存储目录。StarRocks无法自动识别存储介质类型，默认会将所有磁盘识别为HDD，若我们服务器中同时使用了HDD和SSD两种磁盘，就需要在该处按照规范的格式显式的对SSD盘进行配置。若服务器中只有HDD或只有SSD，我们则无需额外配置介质，直接配置路径即可。在我们使用全SSD时，虽然StarRocks默认显示的存储类型仍是HDD，但由于固态硬盘带来的性能提升是物理层面的，并不会影响使用，所以我们同样可以直接指定路径
    log_dir: /data/starrocks/be/log      ## BE日志目录（be.INFO与be.WARNING）
    priority_networks: 192.168.110.0/24  ## BE IP绑定，需使用CIDR写法来调整为当前服务器IP，参数说明参考上文FE部分
    config:                              ## StarGo支持在部署时解析yaml中的参数直接写入StarRocks的配置文件
      mem_limit: 80%  
  - host: 192.168.110.102  ## 同上
    ssh_port: 22
    be_port: 9060
    webserver_port: 8040
    heartbeat_service_port: 9050
    brpc_port: 8060
    deploy_dir : /opt/starrocks/be
    storage_dir: /data/starrocks/be/storage  ## 注意参考上文描述的格式要求填写
    log_dir: /data/starrocks/be/log
    priority_networks: 192.168.110.0/24
    config:
      mem_limit: 80%
  - host: 192.168.110.103  ## 同上
    ssh_port: 22
    be_port: 9060
    webserver_port: 8040
    heartbeat_service_port: 9050
    brpc_port: 8060
    deploy_dir : /opt/starrocks/be
    storage_dir: /data/starrocks/be/storage,medium:HDD  ## 注意参考上文描述的格式要求填写
    log_dir: /data/starrocks/be/log
    priority_networks: 192.168.110.0/24
    config:
      mem_limit: 80%

##[可选]若不需要部署CN，可删除下方内容。CN节点（Compute Node）是从BE中剥离出的无状态计算节点，本身不存储数据，可以为集群提供额外的计算资源。CN可认为是不存储数据的BE，除不需要配置数据存储目录，其他配置整体与BE相同。CN不能与BE混布，主要用于K8s环境，通常不需要在物理环境中部署CN。
cn_servers:
  - host: 192.168.110.104
    ssh_port: 22
    thrift_port: 9060
    webserver_port: 8040
    heartbeat_service_port: 9050
    brpc_port: 8060
    deploy_dir : /opt/starrocks/cn
    log_dir: /data/starrocks/cn/log
    priority_networks: 192.168.110.104
    config:
      sys_log_level: INFO

##[可选]若不需要部署Broker，可删除下方内容。Broker封装了文件接口，主要用于和Hadoop及对象存储等的通信，默认的Broker名称均为：hdfs_broker。
##StarRocks 2.5+版本中，BE已经集成了文件接口，通常情况下不再需要部署Broker。
broker_servers:
  - host: 192.168.110.101  ## Broker节点的IP，需调整为当前服务器实际的内网IP
    ssh_port: 22           ## SSH端口，通常默认即可
    broker_port: 8000      ## broker_port，默认为8000端口，若不与其他服务冲突则无需调整
    deploy_dir : /opt/starrocks/apache_hdfs_broker    ## Broker程序的分发部署目录
    log_dir: /data/starrocks/apache_hdfs_broker/log   ## Broker日志目录
    config:                ## StarGo支持在部署时解析yaml中的参数直接写入StarRocks的配置文件
      sys_log_level: INFO
  - host: 192.168.110.102  ## 同上。补充说明：Broker节点通常与BE节点混布，不需要绑定IP，故没有也不需要配置priority_networks参数
    ssh_port: 22
    broker_port: 8000
    deploy_dir: /opt/starrocks/apache_hdfs_broker
    log_dir: /data/starrocks/apache_hdfs_broker/log
  - host: 192.168.110.103  ## 同上
    ssh_port: 22
    broker_port: 8000
    deploy_dir : /opt/starrocks/apache_hdfs_broker
    log_dir: /data/starrocks/apache_hdfs_broker/log
```



### 五、集群管理

#### 5.1 集群部署语法

StarGo 集群部署命令的语法为：

```shell
./stargo cluster deploy <cluster_name> <version> <topology_file>
## cluster_name：自定义的集群名称，例如这里我们写为'sr-c1'
## version：部署的StarRocks版本号，规范写法为'v+版本号'，例如'v3.0.1'，其他格式将会报错
## topology_file：目标集群需使用的yaml文件名称，例如本次我们使用的'sr-c1.yaml'
```

命令示例：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster deploy sr-c1 v3.0.1 sr-c1.yaml
```


#### 5.2 集群列表查看

可查看当前 StarGo 管理的所有 StarRocks 集群的信息列表，语法为：

```shell
./stargo cluster list
```

例如：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster list
[20230604-205519  OUTPUT] List all clusters
ClusterName      Version     User        CreateDate                 MetaPath                       PrivateKey        
-------------    --------    --------    -------------------        ----------------------------   ------------------
sr-c1            v3.0.1      root        2023-06-04 12:30:48        /root/.stargo/cluster/sr-c1    /root/.ssh/id_rsa
```

#### 5.3 查看集群信息

上面 list 命令查出的 ClusterName 即为我们执行部署命令时指定的名称，根据集群名称我们可以查看对应集群的详细信息，其语法为：

```shell
./stargo cluster display <cluster_name>
```

例如，查看 sr-c1 集群的状态，其命令为：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster display sr-c1
```

说：查询结果的中，STAT 列中的 UP 表示当前节点状态正常，UP/ L 表示当前节点为 FE Leader节点。

出于使用习惯，当前还设计了一种简略信息的状态查看方式，语法为：

```shell
./stargo cluster status <cluster_name>
```

例如查看集群 sr-c1 状态，其执行语句如下：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster status sr-c1
```

#### 5.4 停止指定集群

停止指定集群的语法为：

```shell
./stargo cluster stop <cluster_name>
```

执行该命令将停止指定集群中所有的服务，例如停止 sr-c1 集群：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster stop sr-c1
```

#### 5.5 启动指定集群

启动指定集群的语法为：

```shell
./stargo cluster start <cluster_name>
```

例如再次启动停止状态的 sr-c1 集群：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster start sr-c1
```

#### 5.6 启停集群某类服务

StarRocks 中的服务类型目前可以分为 FE、BE、CN 和 Broker，StarGo 可根据进程类型批量的启停一类进程，语法为：

```shell
./stargo cluster start|stop <cluster_name> --role FE|BE|CN|Broker
## 说明：每条命令中，--role后只能指定FE、BE、CN或Broker四类进程中的一个，不支持同时指定。
```

例如，我们停止 sr-c1 集群中的 Broker 进程后再启动：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster stop sr-c1 --role Broker

[root@starrocks stargo-v2.3]# ./stargo cluster start sr-c1 --role Broker
```

备注：执行停止命令时，日志打印的 ERROR 信息是由于服务停止后检测不到通信引起的，不影响命令执行效果，当前版本可先忽略，后续版本将优化该问题。

#### 5.7 启停指定实例服务

StarGo 也支持启停指定实例（这里的实例指具体的某个 FE、BE、CN 或 Broker），其语法为：

```shell
./stargo cluster start|stop <cluster_name> --node <node_id>
## node_id：即上文通过display命令查到的ID列
```

以启停 ID 为 192.168.110.103:9060 的 BE 实例为例：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster stop sr-c1 --node 192.168.110.103:9060

[root@starrocks stargo-v2.3]# ./stargo cluster start sr-c1 --node 192.168.110.103:9060
```

#### 5.8 重启指定集群

重启指定集群的语法为：

```shell
./stargo cluster restart <cluster_name>
```

例如重启 sr-c1 集群：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster restart sr-c1
```

#### 5.9 重启集群某类服务

StarGo 可根据进程类型批量的重启一类进程，语法为：

```shell
./stargo cluster restart <cluster_name> --role FE|BE|CN|Broker
## 说明：每条命令中，--role后只能指定FE、BE、CN或Broker四类进程中的一个，不支持同时指定。
```

例如，我们重启 sr-c1 集群中的 BE 进程：

```shell
[root@starrocks stargo-v2.3# ./stargo cluster restart sr-c1 --role BE
```

#### 5.10 重启指定实例服务

StarGo 也支持重启指定实例（这里的实例指具体的某个 FE、BE、CN 或 Broker），其语法为：

```shell
./stargo cluster restart <cluster_name> --node <node_id>
## node_id：即上文通过display命令查到的ID列
```

以重启 ID 为 192.168.110.103:9010 的 FE 实例为例：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster restart sr-c1 --node 192.168.110.103:9010
```



### 六、集群运维

#### 6.1 集群升级与降级

集群升降级操作的语法为：

```shell
./stargo cluster upgrade|downgrade <cluster_name> <target_version>
## cluster_name：需要升降级的集群名，例如上文使用的'sr-c1'
## target_version：升降级的目标版本，规范写法同样为"v+版本号"，例如使用的'v3.0.1'
```

也可以指定集群的某个实例，进行升降级，其语法为：

```shell
./stargo cluster upgrade|downgrade <cluster_name> <target_version> --node <node_id>
## node_id：即上文通过display命令查到的ID列
```

**备注：**

1）StarRocks 非常不推荐进行跨大版本的升降级（例如 2.1-2.5或 2.4-3.0，亦或者反向）。

2）目前在进行升级或降级操作时，没有自动进行集群副本状态的校验。当集群建表都为默认的三副本时，我们只需要在升降级前执行 `show proc '/statistic';` 命令，确认 `UnhealthyTabletNum` 为 0 后，即可进行升降级操作。

3）若之前指定了某个实例进行了升级，在后续进行完整的集群升级时，该实例仍会被视为普通节点再按照升级流程进行一次。

##### 6.1.1 集群升级

当需要对集群进行升级操作时，我们需要配置 repo.yaml，例如当前我们将 StarRocks 从 2.5.6 升级至 3.0.1，修改 repo.yaml：

```yaml
#该配置文件配置部署或升级/降级需用的StarRocks二进制包路径及包名：
sr_path: /opt/software/
#sr_name: StarRocks-2.5.6.tar.gz
sr_name: StarRocks-3.0.1.tar.gz
```

备注：

1）在升级前我们仍需要先下载 StarRocks 对应版本的二进制包，例如当前 3.0.1 版本的部署包已下载存放至 /opt/software 目录中。

2）升级或降级操作不会依赖部署时配置的 sr-c1.yaml 文件，我们仅需要配置 repo.yaml 以获取目标版本的安装包。

执行升级命令：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster upgrade sr-c1 v3.0.1
```

执行升级命令后，StarGo 会拉取 repo.yaml 中配置的本地安装包到工作目录解压，然后逐个将原版本程序的 bin 和 lib 目录添加时间戳重命名，例如：bin.bak-20230614125225，再将新版本程序的 bin 文件夹和 lib 文件夹分发到目标目录，最后将进程切换到新版本程序。升级操作的整体顺序为 BE-->FE-->Broker，在控制台打印的日志中我们可以看到程序执行的详细步骤。

注意：每次升级后，原程序的 bin 目录和 lib 目录都会在程序部署目录中备份，出于安全角度设计，StarGo 不会删除这些文件。在确认不需要后，我们可以手动进行清理，避免不必要的磁盘空间占用。

##### 6.1.2 升级指定实例

StarGo 支持升级指定实例（这里的实例指具体的**某个** FE、BE、CN 或 Broker），按照上文，升级前也需要下载对应版本的 StarRocks 二进制包，并修改 repo.yaml。

升级集群 sr-c1 的 FE 某节点实例，其命令为：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster upgrade sr-c1 v3.0.1 --node 192.168.110.102:9010
```

##### 6.1.3 集群降级

对集群进行降级操作时，按照前文，也需要下载对应版本的 StarRocks 二进制包，并修改 repo.yaml：

这里我们执行降级命令：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster downgrade sr-c1 v2.5.6
```

**说明：**频繁的升降级将会在部署目录产生较多的程序备份，也会在 .stargo/download 目录产生多个版本的安装包及解压文件，当前的逻辑下，我们只能手动清理，后续版本考虑优化。

##### 6.1.4 降级指定实例

StarGo 支持降级指定实例（这里的实例指具体的某个 FE、BE、CN 或 Broker），降级前还是需要下载对应版本的 StarRocks 二进制包，并修改 repo.yaml。

例如降级集群 sr-c1 的 BE 某节点实例，其命令为：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster downgrade sr-c1 v2.5.6 --node 192.168.110.102:9060
```


#### 6.2 集群扩容与缩容

##### 6.2.1 集群扩容

stargo 中的"集群扩容"是指集群的"横向扩容"，即为原有的集群增加 FE、BE 或 Broker 节点。

集群扩容的语法为：

```shell
./stargo cluster scale-out <cluster_name> <topology_file>
## cluster_name：需扩容集群的集群名，例如这里的'sr-c1'
## topology_file：包含扩容节点对应信息的yaml拓扑文件，文件名称随意，stargo通过该文件获取扩容节点的ip、端口及目录信息
```

**说明**：扩容的 yaml 文件中只需要配置需扩容节点相关的信息，不需要也不能填写已有集群的信息。扩容的 yaml 不需要编写 global 中的信息，这部分会直接沿用原集群的信息。其他信息参考部署时的模板文件填入即可，例如 sr-out.yaml：

```yaml
be_servers:
  - host: 192.168.125.24
    ssh_port: 22
    be_port: 9060
    webserver_port: 8040
    heartbeat_service_port: 9050
    brpc_port: 8060
    deploy_dir : /opt/starrocks/be
    storage_dir: /data/starrocks/be/storage
    log_dir: /data/starrocks/be/log
    priority_networks: 192.168.125.24
    config:
      mem_limit: 80%
```

在执行扩容命令前，我们仍需在目标服务器上手动创建对应的目录，并配置 stargo 所在节点对目标节点的免密。


根据我们配置的拓扑文件，执行扩容命令：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster scale-out sr-c1 sr-out.yaml
```

##### 6.2.2 集群缩容

stargo 中的集群缩容仍是指横向缩容，即将集群中的某个节点在集群中删除。对于 FE、CN 和 Broker 实例，stargo 会直接执行 Drop 命令，该命令为同步操作，执行后对应节点即完成缩容。而对于 BE 实例，基于数据安全考虑，stargo 会执行 DECOMMISSION 命令，该命令为异步操作，需等待目标 BE 将自己的数据迁移至集群其他节点后才会脱离集群完成缩容，所以实际的缩容时间会随该节点数据量的增大而增加。

**说明：**

1）FE Leader节点不允许缩容，可以先停止其服务待集群重新选主后再执行缩容。

2）BE 是否被执行缩容可通过 `show backends;` 命令返回值中的 `SystemDecommissioned` 是否为 `true` 来判断。在 BE 开始缩容后，其上的 tablet 会自动迁移至集群其他节点，故 BE 的缩容进度可通过返回值中的 `TabletNum` 剩余数来粗估。

3）因 DECOMMISSION 为异步操作，stargo 仅会在执行缩容命令后给出提示，并不会一直等待缩容完成。若发现集群缩容一直未完成，在确认集群中表都为三副本且集群中没有不健康副本后，可在 StarRocks 中对该 BE 再次执行 drop 命令。

集群缩容的语法为：

```shell
./stargo cluster scale-in <cluster_name> --node <nodeId>
## cluster_name：需缩容的集群名称
## nodeId：缩容节点的节点ID，即为通过display命令查到的ID字段值
```

例如我们先查看集群的节点 ID：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster display sr-c1
……
ID                     ROLE    HOST               PORT         STAT    DEPLOYDIR            DATADIR                          
--------------------   ------  ---------------    ---------    -----   ------------------   ---------------------------------
192.168.110.101:9010   FE      192.168.110.101    9010/9030    UP      /opt/starrocks/fe    /data1/starrocks/fe/meta             
192.168.110.101:9060   BE      192.168.110.101    9060/9050    UP      /opt/starrocks/be    /data2/starrocks/be/storage
192.168.110.102:9060   CN      192.168.110.102    9060/9050    UP      /opt/starrocks/cn    /data2/starrocks/cn/storage
192.168.110.101:8000   Broker  192.168.110.101    8000         UP                           /opt/starrocks/apache_hdfs_broker
```

根据节点 ID，例如我们进行 101 FE 的缩容，命令如下：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster scale-in sr-c1 --node 192.168.110.101:9010
```

再演示对 101 节点的 BE 进行缩容操作，命令如下：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster scale-in sr-c1 --node 192.168.110.101:9060
```

其他实例的缩容可参考上文，此处不再演示。

##### 6.2.3 取消缩容

集群取消缩容的语法为：

```shell
./stargo cluster cancel-scale-in sr-c1 --node <nodeId>
## cluster_name：要取消缩容的集群名称
## nodeId：要取消缩容的节点ID
```

例如**[上文](#####6.2.2 集群缩容)** BE 的缩容操作，若我们在执行缩容操作后，在缩容未完成前想取消缩容，即可执行如下命令：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster cancel-scale-in sr-c1 --node 192.168.110.101:9060
```

注意：取消缩容的操作只针对 BE 服务。

#### 6.3 移出集群

stargo 支持将当前管理的集群"移出"，该移出操作仅表示目标集群后续不再由 stargo 管理，并不会对目标集群有其他任何影响。

移出集群操作本质上是删除该集群在 stargo 工作目录中的 meta 文件，其语法如下：

```shell
./stargo cluster remove <cluster_name>
## cluster_name：需移出管理的集群名
```

例如我们移出对 sr-c1 集群的管理，命令如下：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster remove sr-c1
```

#### 6.4 迁入集群

迁入集群的逻辑和移出相反，是将服务器中一套已经手动部署完成的集群迁入到 stargo 的管理中，从逻辑上仍是根据我们编写的 yaml 拓扑文件信息在 stargo 工作目录中生成集群的 meta 文件。迁入集群时所用的 yaml 与部署集群时的语法及结构一致。

迁入集群的语法为：

```shell
./stargo cluster import <cluster_name> <version> <topology_file> [--JAVA_HOME 'java_path']
## cluster_name：为迁入管理的集群名命名，例如'sr-new'
## version：迁入集群的版本号，格式要求为'v+版本号'，例如'v2.5.6'
## topology_file：包含需迁入集群信息的yaml拓扑文件，例如'supervise-in.yaml'
## --JAVA_HOME：可选参数，指定迁入stargo管理后给FE、BE等服务使用的初始JAVA环境，java_path需要是一个绝对路径，例如：--JAVA_HOME '/usr/java/jdk1.8.0_201-amd64'，路径外层的引号可写为英文的单引号、双引号或者不写引号都可以。
##补充说明：stargo是通过ssh远程执行命令的方式来启停StarRocks服务的，这种方式会导致集群迁入stargo管理后，FE、BE等服务可能无法获取到系统中原有自定义的环境变量，进而出现类似报错："ERROR 1064 (HY000): env 'JAVA_HOME' is not set"。基于这类情况，stargo首先会在启动服务前预先执行一次"source /etc/profile"，但考虑到环境变量还可能配置在profile.d或者其他路径，stargo又设计了--JAVA_HOME这个可选参数，来让程序手动的获取我们系统的环境变量，并将其写入到start_fe.sh、start_be.sh等启动脚本中。这个参数只在迁入时需要考虑配置，后续若使用stargo对集群进行升级，stargo会自动为启动脚本配置内置的jdk路径，不再依赖系统的环境，就不需要再考虑系统环境变量的问题了。
```

目前 stargo 已支持在迁入的 yaml 中直接配置集群的用户名和密码，在 yaml 中的配置示例如下：

```yaml
clusterinfo:
    sr_user: "root"
    sr_password: "passwd"
global:
    user: root
    ssh_port: 22

fe_servers:
  - host: 192.168.125.23
    ssh_port: 22
……………………
```

迁入操作仅会进行少量的信息校验（当前为 SSH 通信及句柄数），不会对 yaml 中的目录、端口等进行校验，也不会对识别其中的自定义配置参数。迁入操作不会影响集群，我们可以对正在运行的集群执行迁入操作，唯一需要留意的就是将前面的拓扑文件配置正确，避免迁入后无法管理。
执行迁入命令, 如下示例：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster import sr-new v2.5.6 supervise-in.yaml --JAVA_HOME '/usr/java/jdk1.8.0_201-amd64'
```

迁入完成后，可通过 stargo 查看 sr-new 集群的状态信息，能正常查看即表示迁入成功, 查询命令如下：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster display sr-new
```

#### 6.5 清理集群

若使用 stargo 部署过程中因为某些问题导致部署操作中断，之前版本我们需要手动清理残留文件夹后才能再次尝试部署，较为麻烦。新版本增加了清理集群的功能，该操作的语法为：

```shell
./stargo cluster clean <topology_file>
## topology_file：需执行清理的集群对应的yaml拓扑文件，例如下面示例中的'sr-c1.yaml'
## 因清理操作涉及数据数据目录的删除，存在误删风险，因此命令执行后会提示并要求我们输入y或者n来二次确认！
```

**说明：**

1）clean 命令中不依赖集群名称，这是因为我们并不确定部署操作是在哪一步中断，此时有可能并未执行到在 stargo 工作目录中生成 meta 文件的那一步，也即该集群在 stargo 中可能并不存在自己的集群名。因此，clean 命令设计为从部署时使用的 yaml 文件中获取目录信息并执行清理。

2）clean 操作不会清理 stargo 工作目录中集群的元数据目录（因为可能就没有），适用于集群 meta 文件未创建的情况。在部署中断后，我们可以用 list 命令查看 stargo 已管理集群列表，观察列表中是否已经可查到中断部署的集群名称，若可查到即表示已生成了meta文件，就适合使用**[下文](####6.6 销毁集群)**的 destroy 销毁命令，连同 meta 一并清理。

命令示例清理：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster clean sr-c1.yaml
```

为规避风险，执行清理时会进行校验，若清理对象的端口存在监听，清理进程会报错并退出。所以若前面部署过程中进程已启动，我们仍需要手动 kill 进程。


#### 6.6 销毁集群

销毁集群是风险最高的一个操作，会将目标集群的"部署目录"和"数据目录"以及"stargo 中的 meta 元数据"一并清空，即恢复到部署前的初始状态。

销毁操作被设计用在以下两种情况：

1）用于对"部署过程中出现异常中断，但已在 stargo 中生成 meta 文件的集群"的残余文件清理，是 [6.5](####6.5 清理集群) 章节 clean 命令的场景补充。

2）用于对确认废弃的集群进行卸载清理。

销毁集群的语法为：

```shell
./stargo cluster destroy <cluster_name>
## cluster_name：执行销毁的目标集群名称，例如下方示例中的'sr-new'
## 销毁操作涉及数据文件的删除，风险很大，因此命令执行后会提示并要求我们输入y或者n来二次确认！
```

**说明：**为规避风险，执行卸载命令的集群，其进程需全部停止且不能存在连接（stargo 通过 netstat -an 命令执行检测，使用 mysql-client 等工具连接或存在 close_wait 的进程都视为存在连接）。因此我们需要先 stop 目标集群，并结束所有连接，然后再执行卸载。

销毁命令示例：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster destroy sr-new
```

#### 6.7 修改集群配置

##### 6.7.1 修改集群某类服务配置

StarGo 可根据进程类型批量的修改一类进程的 conf 配置文件，语法为：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster modify-conf <cluster_name> --key {key} --value {value} --role FE|BE|CN|Broker
## {key}、{value} 表示要修改的配置参数名称与值。
## --role后只能指定FE、BE、CN或Broker四类进程中的一个，不支持同时指定。
```

例如，要修改集群 sr-new 所有 FE 实例的 fe.conf 中的 sys_log_level 的值为 INFO ，其命令为：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster modify-conf sr-new --key sys_log_level --value INFO --role FE
```

注意：

1）修改过程中，会注释掉之前的旧配置，并标记是此命令所注释，然后添加新的配置项。若配置文件中没有旧配置，则会直接添加。

2）StarRocks 中的参数分为"静态参数"和"动态参数"，动态参数支持在集群运行时修改但重启集群后将失效，静态参数则只允许修改配置文件并重启服务，关于集群具体的参数说明与修改方式可参考官方文档**[配置参数章节](https://docs.mirrorship.cn/zh-cn/latest/administration/Configuration)**。

##### 6.7.2 修改指定实例的配置

StarGo 也支持修改指定实例的配置（这里的实例指具体的某个 FE、BE、CN 或 Broker），其语法为：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster modify-conf <cluster_name> --key {key} --value {value} --node <node_id>
## {key}、{value} 表示要修改的配置参数名称与值。
## node_id：即前文通过display命令查到的ID列
```

以 ID 为 192.168.110.103:9060 的 BE 实例为例，修改其 priority_networks 的值为 '192.168.0.0/16' ，其命令为：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster modify-conf sr-new --key priority_networks --value '192.168.0.0/16' --node 192.168.110.103:9060
```



### 七、配置集群密码

StarRocks在部署完成后，默认用户为 root，密码为空（**这里的 root 是指 "StarRocks 数据库"的用户，而不是 Linux 系统的用户**）。StarGo 通过类似 Java JDBC 的方式与集群通信，默认也是使用 StarRocks 的用户 root 和"空密码"来访问集群。在我们修改 StarRocks 集群的密码后我们也需要将修改后的密码手动配置在 StarGo 工作目录中集群对应的 yaml 拓扑文件中，否则 StarGo 将无法进行集群的管理。

例如我们修改 StarRocks 集群 root 用户的密码为 root，我们用 mysql-client 或可视化工具将 StarRocks 视为 MySQL 访问，IP 使用任意 FE 的 IP，端口为 9030，访问集群：

```shell
[root@starrocks ~]# mysql -h172.31.254.91 -P9030 -uroot
```

修改密码后退出：

```sql
mysql> set password = password('sdc@BJTU1011');
mysql> exit
```

**在部署时我们使用的 sr-c1.yaml 拓扑文件仅用于集群部署，在部署完成后该文件可删除，StarGo 会在"工作目录"为每个集群生成对应的拓扑文件 meta.yaml 用于集群管理，集群密码信息就是需要到该文件中配置**。我们切换目录到当前 Linux 用户的家目录，以当前的 root 用户为例：

```shell
[root@starrocks stargo-v2.3]# cd    ##该命令表示切换到家目录，root用户家目录为'/root'，其他用户为'/home/用户名'
[root@starrocks ~]# ll -a           ##展示当前目录文件列表，并显示隐藏文件
total 1650892
dr-xr-x---.  8 root root     4096 Jan 14 20:10 .
dr-xr-xr-x. 19 root root      250 Jan 14 14:03 ..
drwxr-xr-x.  2 root root        6 Nov 20  2021 .m2
drwx------   2 root root       80 Jan 14 14:08 .ssh
drwxr-xr-x   5 root root       48 Jan 14 15:01 .stargo
…………………………………………
```

可以看到有一个 .stargo 目录，该目录就是 StarGo 的**"本地工作目录"**，进入目录并查看：

```shell
[root@starrocks ~]# cd .stargo/
[root@starrocks .stargo]# ll
total 4
drwxr-xr-x 3 root root   19 Jan 14 19:31 cluster  ##该目录保存stargo管理的所有集群的yaml拓扑文件。其下层文件夹的名称即为各个集群的集群名称，其中保存集群对应的yaml文件。不可手动清理！！！
drwxr-xr-x 4 root root  106 Jan 14 15:02 download ##该目录保存从配置目录中获取的StarRocks安装包、JDK包及二者解压后的文件，需手动清理。当前这里实现不够友好，后续版本考虑优化。
drwxr-xr-x 2 root root 4096 Jan 14 15:08 tmp      ##该目录保存临时的配置文件，可手动清理。
```

切换至目标目录，为 meta.yaml 配置用户名和密码信息：

```shell
[root@starrocks .stargo]# cd cluster/sr-c1/
[root@starrocks sr-c1]# vim meta.yaml

clusterinfo:
  user: root
  version: v2.5.6
  create_date: "2023-06-01 12:30:48"
  meta_path: /root/.stargo/cluster/sr-c1
  private_key: /root/.ssh/id_rsa
  sr_user: "root"       ##添加用户名root，该项只能配置为root，其他用户权限不足
  sr_password: "root"   ##添加密码，例如上文修改为的root
global:
  user: root
  ssh_port: 22
server_configs:
…………
```

保存退出后，就可继续使用 StarGo 进行集群的管理。



### 八、Help命令介绍

stargo 支持通过help命令查看其支持的所有命令及简要说明：

```shell
[root@starrocks stargo-v2.3]# ./stargo help
```

若想了解每个命令的具体用法，可用下面命令：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster --help
```

之后输入需要查询的命令，就可以看到完整用法说明，例如查看 restart 用法：

```shell
[root@starrocks stargo-v2.3]# ./stargo cluster --help
 Use stargo cluster <Commands>. Cluster operation through stargo. please input deploy|start|stop|restart|display|status|list|remove|import|dstroy|clean|upgrade|downgrade|scale-in|scale-out|cancel-scale-in for detail.
restart
  stargo cluster restart <cluster_name>
  stargo cluster restart <cluster_name> --role FE|BE|Broker
  stargo cluster restart <cluster_name> --node <node_id>
  ## cluster_name ：The cluster name
```



### 九、异常排查

新版本的 stargo 默认开启了 dubug 日志，若在使用过程中出现异常，可根据 stargo 目录下的 stargo_debug.log 日志进行异常排查。

StarGo 仅是方便我们进行集群管理的工具，它只会机械的按照程序设定的逻辑向集群分发命令。除了根据控制台打印的信息和 debug 日志排查，部分情况下，我们仍需要在 StarRocks 集群中根据日志进行问题定位。

欢迎您为 StarGo 提出宝贵的改进建议，我们将一同为社区打造一款优秀的集群管理工具！



### 附录：环境检测脚本说明

执行环境检测脚本后，会对不符合要求的项给出异常提示，完成的提示及说明如下：

```shell
[root@starrocks stargo-v2.3]# ./env_check.sh 

############################ CPU检查 #############################
StarRocks BE需要CPU支持AVX2指令集才可启动，请更换至符合要求的x86架构服务器
#说明：该项为硬件检测，提示异常时，x86架构下需要更换服务器，ARM架构下需使用为ARM架构单独编译的StarRocks部署包。

########################## Linux版本检查 ##########################
若无特殊原因，建议您更换使用CentOS7部署StarRocks，该系统当前测试最为充分
#说明：从稳定性角度考虑，建议生产环境直接使用CentOS 7.9。

########################## Glibc版本检查 ##########################
StarRocks BE要求glibc版本最低为2.17才可启动，请升级glibc或使用更高内核版本的系统
或：检测到较高的glibc版本，StarRocks BE或将无法启动，请更换或降级系统为CentOS7
#说明：官网提供的安装包在Linux系统glibc版本小于2.17或大于2.37，BE启动都会有问题，所以再次建议使用CentOS 7进行部署。

############################ Swap检查 ############################
检查项1：使用swap分区可能影响查询性能，建议配置为不优先使用，临时配置命令：echo 0 | sudo tee /proc/sys/vm/swappiness
检查项2：检查到swap分区未禁用，推荐禁用，临时禁用命令：swapoff -a
#说明：重要参数，关闭后可有效避免查询抖动问题。

########################### 内核参数检查 ##########################
检查项1：推荐调整overcommit_memory=1，以允许内核分配所有的物理内存来保障程序稳定性，临时调整命令：echo 1 | sudo tee /proc/sys/vm/overcommit_memory
检查项2：推荐调整max_map_count=262144，来调大进程可拥有的内存映射区域的最大数量以保障程序稳定性，临时调整命令：echo 262144 | sudo tee /proc/sys/vm/max_map_count
#说明：重要参数，可有效避免环境原因引起的BE异常退出。

######################## 最大打开文件数检查 ########################
句柄数限制过小可能导致服务异常退出，完整调整命令：ulimit -n 655350 && echo -e '* soft nofile 655350\n* hard nofile 655350' >> /etc/security/limits.conf
#说明：重要参数，过小BE可能会无法正常运行。若之前未手动修改过配置文件，可直接执行提示中的完整调整命令。

######################## 最大打开进程数检查 ########################
进程数限制过小可能导致服务异常退出，完整调整命令：ulimit -u 655350 && echo -e '* soft nproc 655350\n* hard nproc 655350' >> /etc/security/limits.conf && sed -i 's/4096/655350/' /etc/security/limits.d/20-nproc.conf
#说明：重要参数，过小BE可能会无法正常运行。若之前未手动修改过配置文件，可直接执行提示中的完整调整命令。

########################### FE端口检查 ###########################
FE需用的默认端口被占用，请检查或在部署时调整端口，检查命令：ss -antpl | grep -E '8030|9010|9020|9030'
#说明：FE需用的端口有四个，若当前服务器混布了其他服务（例如yarn.resourcemanager），就可能会冲突，此时就需要调整yaml配置中的端口。

########################### BE端口检查 ###########################
BE需用的默认端口被占用，请检查或在部署时调整端口，检查命令：ss -antpl | grep -E '9060|9050|8040|8060|9070'
#说明：BE需用的端口有四个，若当前服务器混布了其他服务（例如yarn.nodemanager），就可能会冲突，此时就需要调整yaml配置中的端口。

######################### Broker端口检查 #########################
Broker需用的默认端口被占用，请检查或在部署时调整端口，检查命令：ss -antpl | grep '8000'
#说明：Broker需用的仅为8000端口，若和服务器中已有服务冲突，就需要调整yaml配置中的端口。

########################### 防火墙检查 ###########################
系统防火墙为启用状态，为保证集群内部通信，建议关闭防火墙或开放端口，完整关闭命令：systemctl stop firewalld && systemctl disable firewalld
#说明：多台服务器之间相互通信需要开发上述端口，生产环境通常有其他防护措施，建议直接关闭系统防火墙并禁用开机自启。

########################## TCP参数检查 ###########################
推荐调整tcp_abort_on_overflow参数值为1，临时调整命令：echo 1 | sudo tee /proc/sys/net/ipv4/tcp_abort_on_overflow
#说明：重要参数，可避免tcp引起的查询或写入报错。

######################### Somaxconn检查 #########################
推荐调整somaxconn参数值为1024，临时调整命令：echo 1024 | sudo tee /proc/sys/net/core/somaxconn
#说明：重要参数，可避免队列过小引起的查询或写入报错。

########################## SELinux检查 ###########################
建议关闭SELinux，临时关闭命令：setenforce 0
#说明：重要参数，SELinux安全机制较复杂，无特殊需求都建议关闭。

########################## Hugepage检查 ##########################
检查项1：推荐禁用透明大页，临时禁用命令：echo never > /sys/kernel/mm/transparent_hugepage/enabled
检查项2：推荐禁用碎片整理，临时禁用命令：echo never > /sys/kernel/mm/transparent_hugepage/defrag
#说明：重要参数，透明大页参数或对集群性能产生较大影响。

########################## 时钟同步检查 ##########################
未检测到ntp命令，StarRocks各FE节点间的时钟差大于5秒将无法启动，建议在部署前使用ntp对各节点进行时钟同步
#说明：ntpd服务存在仅是集群时钟同步的"必要条件"，这里的判断结果可能并不准确。建议在部署前对服务器进行规范的校时或同步操作。

############################ 时区检查 ############################
检测到操作系统未使用Asia/Shanghai时区，不恰当的时区设置可能影响集群数据导入导出，调整命令：timedatectl set-timezone Asia/Shanghai && clock -w
#说明：操作系统的时区设置可能会影响StarRocks导入后DATE类型数据值，建议提前调整规避。

########################## 磁盘容量检查 ##########################
检测到存在磁盘剩余容量不足20%的情况，请确认磁盘空间充足后再进行集群部署，检查命令：df -h
#说明：部署、升级、降级操作均需要消耗磁盘空间，此外StarRocks默认的磁盘高水位为85%，风险水位为95%，触发阈值后会禁用部分功能，因此若磁盘剩余空间不足需及时更换或扩容磁盘。

########################## 内存大小检查 ##########################
服务器内存较小，为保证集群性能和稳定性，生产环境的建议内存为32G+
#说明：StarRocks计算过程为全内存模式，不支持落盘，内存过小时无法良好体验其极速性能。

######################### Netstat命令检查 ########################
未找到netstat命令，StarGo当前需依赖netstat检测通信，否则无法正常使用。安装命令：yum -y install net-tools
#说明：netstat命令是StarGo工具所在节点需要用到的，并不是StarRocks依赖的命令。考虑运维时也会频繁用到，建议每台服务器都进行安装。
```

**特别说明：**脚本中给出的提示大都为“临时修改”的方法，即修改后立刻生效，但重启后会失效，完整调优操作系统参数的方式可参考**[官网文档](https://docs.mirrorship.cn/zh-cn/latest/deployment/environment_configurations)**。
