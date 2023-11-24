CREATE TABLE `job_cpu_minute` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `jid` varchar(100) NOT NULL,
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idle.avg` float DEFAULT NULL,
  `iowait.avg` float DEFAULT NULL,
  `sys.avg` float DEFAULT NULL,
  `user.avg` float DEFAULT NULL,
  `nice.avg` float DEFAULT NULL,
  `irq.avg` float DEFAULT NULL,
  `softirq.avg` float DEFAULT NULL,
) ENGINE=OLAP 
  PRIMARY KEY (`id`),
  KEY `idx_key_cd` (`jid`,`created_date`)
  COMMENT "OLAP"
  DISTRIBUTED BY HASH(`id`) BUCKETS 7 
  PROPERTIES (
  "replication_num" = "1",
  "in_memory" = "false",
  "storage_format" = "DEFAULT"
  );
  AUTO_INCREMENT=120663156 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;


CREATE TABLE `t_job` (
  `id` int(11) NOT NULL COMMENT "序号",
  `job_id` varchar(200) NULL COMMENT "作业ID",
  `job_name` varchar(200) NULL COMMENT "作业名",
  `cluster_id` varchar(200) NULL COMMENT "集群ID",
  `user_name` varchar(200) NULL COMMENT "账号名",
  `account_id` varchar(200) NULL COMMENT "账户ID",
  `account_name` varchar(200) NULL COMMENT "账户名称",
  `account_user` varchar(200) NULL COMMENT "账户管理员",
  `accounttype_id` varchar(200) NULL COMMENT "账户类型ID",
  `accounttype_name` varchar(200) NULL COMMENT "账户类型名称",
  `submit_time` datetime NULL COMMENT "提交时间",
  `start_time` datetime NULL COMMENT "作业开始时间",
  `end_time` datetime NULL COMMENT "作业结束时间",
  `queue` varchar(200) NULL COMMENT "队列名",
  `queue_type` varchar(6) NULL COMMENT "队列类型（0=计时，1=独占）",
  `queue_billing` varchar(200) NULL COMMENT "计费对象",
  `queue_state` varchar(100) NULL COMMENT "队列状态",
  `queue_nodes` int(11) NULL DEFAULT "0" COMMENT "节点数",
  `queue_price` decimal128(23, 3) NULL DEFAULT "0.000" COMMENT "队列CPU单价",
  `gpu_unit_price` decimal128(23, 3) NULL DEFAULT "0.000" COMMENT "队列GPU单价",
  `queue_price_discount` int(11) NULL DEFAULT "100" COMMENT "队列CPU折扣，100表示原价",
  `queue_gpu_price_discount` int(11) NULL DEFAULT "100" COMMENT "队列GPU折扣，100表示原价",
  `queue_node_price` decimal128(23, 3) NULL DEFAULT "0.000" COMMENT "队列节点价格",
  `alloc_cpus` int(11) NULL DEFAULT "0" COMMENT "使用CPU个数",
  `ncpus` int(11) NULL DEFAULT "0" COMMENT "cpu核数",
  `ngpus` int(11) NULL DEFAULT "0" COMMENT "gpu卡数",
  `cpu_time` decimal128(23, 3) NULL DEFAULT "0.000" COMMENT "CPU核时",
  `gpu_time` decimal128(23, 3) NULL DEFAULT "0.000" COMMENT "GPU卡时",
  `cpu_scope_expression` varchar(1000) NULL COMMENT "CPU规模计价规则",
  `cpu_scope_discount` int(11) NULL COMMENT "CPU规模计价折扣",
  `queue_time` bigint(20) NULL COMMENT "排队时间",
  `run_time` bigint(20) NULL COMMENT "运行时间",
  `cpu_machine_time` decimal128(23, 3) NULL DEFAULT "0.000" COMMENT "cpu费用",
  `gpu_machine_time` decimal128(23, 3) NULL DEFAULT "0.000" COMMENT "GPU费用",
  `machine_time` decimal128(23, 3) NULL DEFAULT "0.000" COMMENT "费用总计",
  `billing` varchar(6) NULL COMMENT "计费状态（0:未计费，1:独占，2：已计费）",
  `billing_introduction` varchar(500) NULL COMMENT "未计费原因",
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT "创建时间",
  `platform_user_name` varchar(150) NULL COMMENT "平台用户名",
  `platform_user_id` varchar(150) NULL COMMENT "平台用户ID",
  `updated_date` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT "",
  `queue_node_price_discount` int(11) NULL DEFAULT "100" COMMENT "节点时折扣，100表示原价"
) ENGINE=OLAP 
UNIQUE KEY(`id`)
COMMENT "OLAP"
DISTRIBUTED BY HASH(`id`) BUCKETS 7 
PROPERTIES (
"replication_num" = "1",
"in_memory" = "false",
"storage_format" = "DEFAULT"
);