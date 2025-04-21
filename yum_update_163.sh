#!/bin/bash

# 定义备份目录
backup_dir="/etc/yum.repos.d/backup_$(date +%Y%m%d%H%M%S)"

# 创建备份目录
mkdir -p "$backup_dir"

# 备份 yum 源文件
cp /etc/yum.repos.d/*.repo "$backup_dir"

# 检查备份是否成功
if [ $? -eq 0 ]; then
    echo "Yum 源备份成功，备份目录为: $backup_dir"
else
    echo "Yum 源备份失败"
    exit 1
fi

# 检查 curl 是否安装
if ! command -v curl &> /dev/null; then
    echo "系统未安装 curl，无法继续操作，请手动安装 curl 后再运行此脚本。"
    exit 1
fi

# 确定 CentOS 版本
centos_version=$(rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release))

# 根据不同版本替换 yum 源
case $centos_version in
    6)
        curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS6-Base-163.repo
        ;;
    7)
        curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
        ;;
    8)
        echo "网易暂未提供 CentOS 8 官方镜像源配置文件，可使用其他镜像源。"
        exit 1
        ;;
    *)
        echo "不支持的 CentOS 版本: $centos_version"
        exit 1
        ;;
esac

# 检查 curl 命令是否执行成功
if [ $? -ne 0 ]; then
    echo "下载网易 Yum 源配置文件失败，请检查网络连接。"
    exit 1
fi

# 清理并生成缓存
yum clean all
yum makecache

echo "Yum 源已成功替换为网易源，并更新了缓存。"