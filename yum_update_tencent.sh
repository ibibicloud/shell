#!/bin/bash

# 检查是否为 root 用户
if [ "$(id -u)" -ne 0 ]; then
    echo "请以 root 用户身份运行此脚本。"
    exit 1
fi

# 定义备份目录
backup_dir="/etc/yum.repos.d/backup_$(date +%Y-%m-%d_%H:%M:%S)"

# 创建备份目录
mkdir -p "$backup_dir"

# 备份 yum 源文件
cp /etc/yum.repos.d/*.repo "$backup_dir"

# 检查备份是否成功
if [ $? -eq 0 ]; then
    echo "原 yum 源配置备份成功，备份目录为: $backup_dir。"
else
    echo "原 yum 源配置备份失败。"
    exit 1
fi

# 检查 curl 是否安装
if ! command -v curl &> /dev/null; then
    echo "系统未安装 curl，无法继续操作，请手动安装 curl 后再运行此脚本。"
    exit 1
fi

# 确定 CentOS 版本
centos_version=$(rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release))

# 替换 yum 源
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.cloud.tencent.com/repo/centos7_base.repo
echo "CentOS 7.* yum 源已成功替换为腾讯云源。"

# 处理 epel.repo 文件
curl -o /etc/yum.repos.d/epel.repo https://mirrors.cloud.tencent.com/repo/epel-7.repo
echo "CentOS 7.* epel 源已成功替换为腾讯云源。"

# 清理并生成缓存
yum clean all
yum makecache
echo "清理并更新了 yum 缓存。"
    