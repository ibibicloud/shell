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
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
echo "yum 源已成功替换为阿里云源。"

# 安装 epel-release
yum install -y epel-release

# 处理 epel.repo 文件
if [ -f "/etc/yum.repos.d/epel.repo" ]; then
    # 备份原有的 epel.repo 文件到备份目录
    cp /etc/yum.repos.d/epel.repo "$backup_dir"
    # 替换 epel.repo 文件中的镜像源为阿里云镜像源
    sed -i 's|^baseurl=.*|baseurl=https://mirrors.aliyun.com/epel/$releasever/$basearch/|' /etc/yum.repos.d/epel.repo
    sed -i 's|^metalink=.*|#metalink|' /etc/yum.repos.d/epel.repo
fi

# 处理 epel-testing.repo 文件
if [ -f "/etc/yum.repos.d/epel-testing.repo" ]; then
    # 备份原有的 epel-testing.repo 文件到备份目录
    cp /etc/yum.repos.d/epel-testing.repo "$backup_dir"
    # 替换 epel-testing.repo 文件中的镜像源为阿里云镜像源
    sed -i 's|^baseurl=.*|baseurl=https://mirrors.aliyun.com/epel/testing/$releasever/$basearch/|' /etc/yum.repos.d/epel-testing.repo
    sed -i 's|^metalink=.*|#metalink|' /etc/yum.repos.d/epel-testing.repo
fi

# 清理并生成缓存
yum clean all
yum makecache
echo "清理并更新了 yum 缓存。"
    