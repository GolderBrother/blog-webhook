# 设置允许指定端口通过防火墙centos7
- 开启防火墙
```bash
systemctl start firewalld.service
```

- 停止防火墙
```bash
systemctl stop firewalld.service
```

- 重启防火墙
```bash
systemctl restart firewalld
```

- 指定端口范围为通过防火墙
```bash
firewall-cmd --permanent --zone=public --add-port=6000/tcp
# 指定端口范围为4400-4600通过防火墙
firewall-cmd --permanent --zone=public --add-port=4400-4600/tcp
```

- 说明3306端口通过成功
```bash
Warning: ALREADY_ENABLED: 3306:tcp
```

- 关闭指定端口
```bash
firewall-cmd --zone=public --remove-port=80/tcp --permanent
```

- 查看通过的端口
```bash
firewall-cmd --zone=public --list-ports
```

- 查看防火墙状态 
```bash
systemctl status firewalld
```