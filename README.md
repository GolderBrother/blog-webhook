# blog-webhook
> This is webhook of my blog for CI and CD

在Docker中部署Egg.js应用(blog-node-egg)
## 重点总结
- 使用Centos 7.4版本安装docker。
- --daemon要去掉，让eggjs应用直接前台运行。
- Dockerfile里先拷贝package.json，安装npm依赖后，再拷贝应用的代码。
- 使用境外服务器则不需要使用淘宝的npm镜像源。
