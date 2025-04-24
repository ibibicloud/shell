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

if [ ! -d /www/server/panel ] || [ ! -f /etc/init.d/bt ];then
    echo -e "${BG_YELLOW}服务器未安装宝塔面板。${NC}"
    exit 1
fi

echo -e "${BG_YELLOW}宝塔Linux面板优化脚本，适用版本：v7.7。${NC}"

# 修改强制登录
sed -i "s|if (bind_user == 'True') {|if (bind_user == 'REMOVED') {|g" /www/server/panel/BTPanel/static/js/index.js
rm -rf /www/server/panel/data/bind.pl
echo -e "${BG_YELLOW}修改强制登陆结束。${NC}"

# 锁死plugin.json
chattr +i /www/server/panel/data/plugin.json
echo -e "${BG_YELLOW}插件商城开心结束。${NC}"

# 锁死repair.json
chattr +i /www/server/panel/data/repair.json
echo -e "${BG_YELLOW}文件防修改结束。${NC}"

# 重启宝塔面板
/etc/init.d/bt restart 	

# 输出宝塔面板默认账号密码
bt default

echo -e "${BG_YELLOW}宝塔面板开心结束。${NC}"
