#!/bin/bash
# 进入到服务端工作目录
WORK_PATH='/usr/share/nginx/html/resume'
cd $WORK_PATH
echo '清除老代码'
# 回退版本，历史区回退到暂存区
git reset --hard origin/master
# 清除暂存区
git clean -f
echo '拉取最新代码'
git pull origin master
echo '开始构建'
# TODO：这边启动会出现80端口被占用，导致容器启动失败，需要解决，因此先杀掉所有80端口的进程
kill -9 $(lsof -i tcp:80 -t)
# 重新启动nginx
systemctl restart nginx
