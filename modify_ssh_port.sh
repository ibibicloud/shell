#!/bin/bash

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    echo "请以 root 用户身份运行此脚本。"
    exit 1
fi

# 提示用户输入新的 SSH 端口，默认端口为 2233
read -p "请输入新的 SSH 端口（默认: 2233）: " new_port
new_port=${new_port:-2233}

# 检查输入的端口是否为有效的整数
if ! [[ "$new_port" =~ ^[0-9]+$ ]]; then
    echo "输入的端口不是有效的整数，请重新运行脚本并输入正确的端口。"
    exit 1
fi

# 获取当前时间
current_time=$(date +"%Y%m%d%H%M%S")

# 备份 SSH 配置文件，文件名加上时间戳
backup_file="/etc/ssh/sshd_config.bak.$current_time"
cp /etc/ssh/sshd_config "$backup_file"
echo "已备份 SSH 配置文件到 $backup_file"

# 修改 SSH 端口，使用更精确的正则匹配
sed -i "s/^#*Port [0-9]\+/Port $new_port/" /etc/ssh/sshd_config

# 重新加载 SSH 服务
systemctl reload sshd
echo "已重新加载 SSH 服务"

# 检查防火墙是否为 firewalld
if systemctl is-active --quiet firewalld; then
    # 开放新的 SSH 端口
    firewall-cmd --permanent --zone=public --add-port=$new_port/tcp
    firewall-cmd --reload
    echo "已开放新的 SSH 端口 $new_port 并重新加载防火墙规则"
else
    echo "Firewalld 未运行，若需要开放端口，请手动配置防火墙。"
fi

echo "SSH 端口已成功修改为 $new_port"    