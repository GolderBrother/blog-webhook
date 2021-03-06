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
# 这边需要手动打包后提交,因为要处理一些打包后的静态资源引用路径问题
# npm run build
echo '开始进行构建'
# 创建镜像8000
docker build -t blog-react-admin:1.0 .
echo '停止旧容器并删除旧容器'
docker stop blog-react-admin-container
docker rm blog-react-admin-container
echo '启动新容器'
# docker容器端口映射
# 宿主机的端口映射到docker容器的8000端口，前提是docker容器要暴露端口出来
# -d:后台运行，不堵塞当前命令行窗口
# blog-react-admin: 镜像名字（基于blog-react-admin镜像启动服务，后台运行）
# TODO：这边启动会出现8000端口被占用，导致容器启动失败，需要解决，因此先杀掉所有8000端口的进程
kill -9 $(lsof -i tcp:8000 -t)
docker container run -p 8000:8000 -d --name blog-react-admin-container blog-react-admin:1.0
# 启动完容器后，释放8000端口，解决简历页面(http://116.62.6.228:8001/)启动，nginx报错8000端口占用问题
kill -9 $(lsof -i tcp:8000 -t)
# 重启nginx(使得简历(resume)页面能够正常访问)
systemctl restart nginx