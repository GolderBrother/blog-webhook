#!/bin/bash
# 进入到服务端工作目录
WORK_PATH='/usr/projects/blog/blog-react-admin'
cd $WORK_PATH
echo '清除老代码'
# 回退版本，历史区回退到暂存区
git reset --hard origin/master
# 清除暂存区
git clean -f
echo '拉取最新代码'
git pull origin master
echo '编译打包'
npm run build
echo '开始进行构建'
# 创建镜像8000
docker build -t blog-react-admin:1.0
echo '停止旧容器并删除旧容器'
docker stop blog-react-admin-container
docker rm blog-react-admin-container
echo '启动新容器'
# docker容器端口映射
# 宿主机的端口映射到docker容器的8000端口，前提是docker容器要暴露端口出来
# -d:后台运行，不堵塞当前命令行窗口
# blog-react-admin: 镜像名字（基于blog-react-admin镜像启动服务，后台运行）
docker container run -p 8000:8000 -d --name blog-react-admin-container blog-react-admin:1.0

