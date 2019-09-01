# blog-webhook
> This is webhook of my blog for CI and CD

在Docker中部署Egg.js应用(blog-node-egg)
## 重点总结
- 使用Centos 7.4版本安装docker。
- --daemon要去掉，让eggjs应用直接前台运行。
- Dockerfile里先拷贝package.json，安装npm依赖后，再拷贝应用的代码。
- 使用境外服务器则不需要使用淘宝的npm镜像源。

## 问题：
访问提示网页可能暂时无法连接，或者它已永久性地移动到了新网址。ERR_UNSAFE_PORT:
这个是浏览器限制了6000端口，服务端没问题的。
如果您的这个端口只是nginx代理的请求地址，可以使用这个端口。
如果您的这个站点，需要通过浏览器访问，您可以将其修改为其他端口，避免被浏览器限制。