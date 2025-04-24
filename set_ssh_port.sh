#!/bin/bash

# 定义文本背景颜色变量
BG_YELLOW='\e[43m'

# 恢复默认格式
NC='\e[0m'

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${BG_YELLOW}请以 root 用户身份运行此脚本。${NC}"
    exit 1
fi

# 提示用户输入新的 SSH 端口，默认端口为 2233
read -p "${BG_YELLOW}请输入新的 SSH 端口（默认: 2233）: ${NC}" new_port
new_port=${new_port:-2233}

# 检查输入的端口是否为有效的整数
if ! [[ "$new_port" =~ ^[0-9]+$ ]]; then
    echo -e "${BG_YELLOW}输入的端口不是有效的整数，请重新运行脚本并输入正确的端口。${NC}"
    exit 1
fi

# 获取当前时间
current_time=$(date +%Y-%m-%d_%H:%M:%S)

# 备份 SSH 配置文件，文件名加上时间戳
backup_file="/etc/ssh/sshd_config.bak.$current_time"
cp /etc/ssh/sshd_config "$backup_file"
echo -e "${BG_YELLOW}已备份 SSH 配置文件到 $backup_file$。{NC}"

# 修改 SSH 端口，使用更精确的正则匹配
sed -i "s/^#*Port [0-9]\+/Port $new_port/" /etc/ssh/sshd_config

# 重新加载 SSH 服务
systemctl reload sshd
echo -e "${BG_YELLOW}已重新加载 SSH 服务。${NC}"

# 检查防火墙是否为 firewalld
if systemctl is-active --quiet firewalld; then
    # 开放新的 SSH 端口
    firewall-cmd --permanent --zone=public --add-port=$new_port/tcp
    firewall-cmd --reload
    echo -e "${BG_YELLOW}已开放新的 SSH 端口 $new_port 并重新加载防火墙规则。${NC}"
else
    echo -e "${BG_YELLOW}Firewalld 未运行，若需要开放端口，请手动配置防火墙。${NC}"
fi

echo -e "${BG_YELLOW}SSH 端口已成功修改为 $new_port。${NC}"    