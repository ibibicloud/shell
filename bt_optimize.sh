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

# 解除强制账号绑定
if [ ! -f /www/server/panel/data/userInfo.json ]; then
	echo "{\"uid\":1000,\"username\":\"admin\",\"serverid\":1}" > /www/server/panel/data/userInfo.json
fi
echo -e "${BG_YELLOW}已解除宝塔面板强制账号绑定。${NC}"

# 去除各种计算题与延时等待
Layout_file="/www/server/panel/BTPanel/templates/default/layout.html";
JS_file="/www/server/panel/BTPanel/static/bt.js";
if [ `grep -c "<script src=\"/static/bt.js\"></script>" $Layout_file` -eq '0' ];then
	sed -i '/{% block scripts %} {% endblock %}/a <script src="/static/bt.js"></script>' $Layout_file;
fi
wget -q http://f.cccyun.cc/bt/bt.js -O $JS_file;
echo -e "${BG_YELLOW}已去除各种计算题与延时等待。${NC}"

# 去除创建网站自动创建的垃圾文件
sed -i "/htaccess = self.sitePath+'\/.htaccess'/, /public.ExecShell('chown -R www:www ' + htaccess)/d" /www/server/panel/class/panelSite.py
sed -i "/index = self.sitePath+'\/index.html'/, /public.ExecShell('chown -R www:www ' + index)/d" /www/server/panel/class/panelSite.py
sed -i "/doc404 = self.sitePath+'\/404.html'/, /public.ExecShell('chown -R www:www ' + doc404)/d" /www/server/panel/class/panelSite.py
echo -e "${BG_YELLOW}已去除创建网站自动创建的垃圾文件。${NC}"

# 关闭未绑定域名提示页面
sed -i "s/root \/www\/server\/nginx\/html/return 400/" /www/server/panel/class/panelSite.py
if [ -f /www/server/panel/vhost/nginx/0.default.conf ]; then
	sed -i "s/root \/www\/server\/nginx\/html/return 400/" /www/server/panel/vhost/nginx/0.default.conf
fi
echo -e "${BG_YELLOW}已关闭未绑定域名提示页面。${NC}"

# 关闭安全入口登录提示页面
sed -i "s/return render_template('autherr.html')/return abort(404)/" /www/server/panel/BTPanel/__init__.py
echo -e "${BG_YELLOW}已关闭安全入口登录提示页面。${NC}"

# 去除消息推送与文件校验
sed -i "/p = threading.Thread(target=check_files_panel)/, /p.start()/d" /www/server/panel/task.py
sed -i "/p = threading.Thread(target=check_panel_msg)/, /p.start()/d" /www/server/panel/task.py
echo -e "${BG_YELLOW}已去除消息推送与文件校验。${NC}"

# 去除面板日志与绑定域名上报
sed -i "/^logs_analysis()/d" /www/server/panel/script/site_task.py
sed -i "s/run_thread(cloud_check_domain,(domain,))/return/" /www/server/panel/class/public.py
echo -e "${BG_YELLOW}已去除面板日志与绑定域名上报。${NC}"

# 重启宝塔面板
/etc/init.d/bt restart

echo -e "${BG_YELLOW}宝塔面板优化脚本执行完毕。${NC}"
