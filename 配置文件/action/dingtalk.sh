#!/bin/bash

# 获取触发Fail2Ban的IP地址参数
banned_ip="$1"

# 获取IP地址参数
local_ip=$(hostname -I | awk '{print $1}')



# DingTalk机器人的Webhook地址
dingtalk_webhook="https://oapi.dingtalk.com/robot/send?access_token=a5cd33fc0bad3e1f9bb292a43e70fbe6ed377fba45358c5a547570e0ac62adb4"

# 要发送的JSON数据
json_data='{
    "msgtype": "text",
    "text": {
              "content": "【报警】\n攻击IP：'"$attack_ip"'\n被攻击IP：'"$banned_ip"'\n攻击行为：在10分钟内登录失败十次\n处置结果：永久封禁"

    }
}'

# 使用curl发送请求
curl -s -X POST "$dingtalk_webhook" \
    -H 'Content-Type: application/json' \
    -d "$json_data"

# 检查curl是否成功
if [ $? -eq 0 ]; then
    echo "DingTalk消息发送成功! IP: $ip" >> "/etc/fail2ban/jail.d/log"
else
    echo "DingTalk消息发送失败. IP: $ip" >> "/etc/fail2ban/jail.d/log"
fi


