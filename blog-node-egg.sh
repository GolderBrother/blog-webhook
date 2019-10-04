#!/bin/bash
# 进入到服务端工作目录
WORK_PATH='/usr/projects/blog/blog-node-egg'
cd $WORK_PATH
echo '清除老代码'
# 回退版本，历史区回退到暂存区
git reset --hard origin/master
# 清除暂存区
git clean -f
echo '拉取最新代码'
git pull origin master
echo '开始进行构建'
# 创建新镜像, . 是当前目录下找Dockerfile文件进行构建
# 注意：这边要加个版本号，不然默认就是latest,会有问题,下面的也要同步加
docker build -t blog-node-egg:1.0 .
echo '停止旧容器并删除新容器'
docker stop blog-node-egg-container
docker rm blog-node-egg-container
echo '启动新容器'
# TODO：这边启动会出现6100端口被占用，导致容器启动失败，需要解决，因此先杀掉所有6100端口的进程
kill -9 $(lsof -i tcp:6100 -t)
# docker容器端口映射
# -p 6100:6100:宿主机的端口(:前面的)映射到docker容器的6000端口(:后面的)，前提是docker容器要暴露端口出来
# -d:后台运行，不堵塞当前命令行窗口
# blog-node-egg: 镜像名字（基于blog-node-egg镜像启动服务，后台运行）
# docker container run -p 6100:6100 -d --name blog-node-egg-container blog-node-egg:1.0
docker container run -d --net=host --name blog-node-egg-container blog-node-egg:1.0

