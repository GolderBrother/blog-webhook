# Deploy eggjs app with Docker

内容包括：linux服务器安装Docker、使用Docker部署node.js应用、更新、Docker里连接主机的mysql数据库，以及可能用到的Docker命令。
网上也有不少类似的文章，但有的过于简单甚至有误，不太适合新手。通过参看多篇文章，并基于使用Docker部署egg.js应用的实践经验整理出了本文。
1：Docker的前端应用场景是什么？
每个node.js应用需要放在一个独立的环境Docker容器内运行，相互隔离，互不影响。
2：Docker部署node.js应用的优点是什么？
使用Docker容器部署node.js快速方便，特别是应用较多时部署迁移等使用Docker会更方便。
3：为什么要使用Docker部署eggjs应用？
在同一台服务器上不能同时运行多个eggjs应用，除非停止另外一个eggjs应用。
4：使用Docker部署node.js应用，大体的流程是什么样的？
-> 服务器安装好Docker 
-> 本地应用根目录编写好`Dockfile`文件 
-> 将整个应用一起上传到服务器目录下 
-> 使用终端连接服务器执行命令安装Docker 
-> 部署成功。具体的操作请看下文。


服务器安装Docker
如果要使用Docker，需使用Centos 7.x版本。Docker对内核要求比较高，要在Centos6.5及更高的版本的64位系统里安装，网上说6.x使用Docker会有不稳定情况。本文安装docker ce版本。
1. 安装一些系统依赖:
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

2. 添加软件源，这里使用阿里的源，更快更稳定:
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

3. 更新 yum 软件源缓存，并安装 docker-ce:
sudo yum makecache fast
sudo yum install docker-ce

4. 启动docker-ce:
sudo systemctl enable docker
sudo systemctl start docker

5. 查看Docker版本：
docker -v

本人在Centos 7.2上安装的Docker版本为18.05.0-ce。
关于docker的使用等可查看 非官方docker中文版文档。
部署node.js应用到服务器
1. egg.js应用需要修改根目录下的package.json（普通node.js应用可忽略这一步）：将start这行里命令里的--daemon去掉，即启动eggjs使用egg-scripts start就好了。在Docker里eggjs应用要在前台运行。
2. 在本地应用的根目录下(package.json所在目录)新建一个名为Dockerfile的文件（无后缀），将以下内容复制到文件里，并将/usr/src/node-app/koa-server全部替换为你想设置的路径（该路径为docker容器里的路径，可自行设置）：
# 设置基础镜像,如果本地没有该镜像，会从Docker.io服务器pull镜像
FROM node:8.6.0-alpine
# 设置时区
RUN apk --update add tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata

# 创建app目录
RUN mkdir -p /usr/src/node-app/koa-server

# 设置工作目录
WORKDIR /usr/src/node-app/koa-server

# 拷贝package.json文件到工作目录
# !!重要：package.json需要单独添加。
# Docker在构建镜像的时候，是一层一层构建的，仅当这一层有变化时，重新构建对应的层。
# 如果package.json和源代码一起添加到镜像，则每次修改源码都需要重新安装npm模块，这样木有必要。
# 所以，正确的顺序是: 添加package.json；安装npm模块；添加源代码。
COPY package.json /usr/src/node-app/koa-server/package.json

# 安装npm依赖(使用淘宝的镜像源)
# 如果使用的境外服务器，无需使用淘宝的镜像源，即改为`RUN npm i`。
RUN npm i --registry=https://registry.npm.taobao.org

# 拷贝所有源代码到工作目录
COPY . /usr/src/node-app/koa-server

# 暴露容器端口
EXPOSE 9002

# 启动node应用
CMD npm start

上面的注释一目了然。整个过程简单描述就是：1.拉取docker镜像（并设置时区等）；2.创建docker工作目录，并将package.json拷贝到docker里；3.安装npm依赖；4.将服务器上的应用拷贝到docker里；5.暴露docker容器的端口，然后启动node应用。
3. 使用ftp工具或git工具将整个应用上传到生产环境服务器，并使用终端连接到服务器，进入到服务器应用的目录下；（过程略）
4. 执行以下命令，安装docker镜像；
sudo docker build -t node/koa-server .

-t是对该镜像进行tag标识，标识的名字为node/koa-server，可以自定义这个名字。镜像的构建过程依赖于网速，整体还比较快。npm依赖可能会久一些，因为egg.js的依赖比较多。如果所有步骤执行完，会有success的提示，安装成功了。
5. 执行以下命令，使用刚创建好的镜像来启动一个容器；
普通node.js应用
sudo docker run -d --name koa-server -p 9002:9002 node/koa-server

-d为后台运行容器。如果普通node.js应用使用以上命令，容器使用9002端口，与Dockerfile里面的一致。
eggjs应用
sudo docker run -d --net=host --name koa-server node/koa-server

eggjs应用需要执行以上命令，即增加了--net=host，该参数表示使用host网络模式与主机共享网络来连接mysql数据库；(暂时使用这种模式成功了，后续研究其他更好方案)。
6. 执行以下命令查看容器是否启动成功；
docker ps

以上命令是查看运行中的容器。如果刚才启动成功，则会显示出来。
curl -i localhost:9002

也可以通过curl命令或者到浏览器里输入应用的访问地址，来查看能否访问应用，如果可以则安装成功。
docker logs containerId

如果刚才执行docker ps没有看到刚刚启动的容器，说明启动失败，使用该命令来查看启动的具体情况。
7. docker容器里eggjs连接mysql：
只需要根据情况修改数据库相关信息即可，在host网络模式下，容器里eggjs的mysql配置文件里的host仍可设置为localhost。
更新docker里的node.js应用：
1. 通过查看容器列表，找到需要停止的容器ID；
docker ps

2. 停止容器；
sudo docker stop containerId

3. 删除容器；
sudo docker rm containerId

4. 删除镜像；
# 正常情况可以删除
sudo docker rmi imageId
# 提示无法删除情况下，强制删除
sudo docker rmi -f imageId

5. 将本地应用代码更新到服务器目录下。
6. 按照上面的步骤重新构建镜像和启动容器。
重点总结

使用Centos 7.x版本安装docker。

--daemon要去掉，让eggjs应用直接前台运行。
Dockerfile里先拷贝package.json，安装npm依赖后，再拷贝应用的代码。
使用境外服务器则不需要使用淘宝的npm镜像源。

可能出现的问题

npm安装失败：可能是镜像源的问题，需要删除镜像重新构建镜像。
镜像无法删除：需要先停止和删除容器。

其他常用命令
镜像相关：
查看镜像构建工程
sudo docker history node/koa-server

比如上面我们构建node/koa-server这个镜像后，可以通过这个命令来查看该镜像的构建过程，来发现问题。
查看所有镜像列表
docker images

删除镜像
sudo docker rmi imageId

sudo docker rmi -f imageId


先查看镜像列表，找到要删除的镜像ID，然后使用该命令删除。-f为强制删除。
容器相关：
查看所有容器列表
docker ps

查看某个容器的信息
docker logs containerId

先查看容器列表，找到要查看容器的ID，然后使用该命令查看。
拷贝主机的文件到容器的目录下
docker cp src/. mycontainer:/target

src为要拷贝的目录名，mycontainer为容器的id，target为目标目录名。
进入某个容器的环境
sudo docker exec -it containerId /bin/bash
或
sudo docker exec -it containerId /bin/sh

先查看容器列表，找到要查看容器的ID，然后使用该命令查看。/bin/sh可在执行docker ps后看到。退出容器可以执行exit;。

## 目前问题
1 .sh文件不能自动执行(已解決)
2 提交代码不能触发webhook(已解決)
3 Dockerfile里面的脚本貌似不能自动执行(已解決)
4 blog-react-admin 打包不能访问
(Cannot read property 'authority' of undefined)