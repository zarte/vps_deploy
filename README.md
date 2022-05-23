# vps_deploy
vps部署脚本仓库

## 脚本列表
* vpsinit.sh
* web.sh

## 使用方法

``` 
yum install wget -y
自行修改脚本名
wget https://raw.githubusercontent.com/zarte/vps_deploy/main/
chmod 777 ./vpsinit.sh
./vpsinit.sh
```

## 脚本详细说明
### vpsinit.sh
vps初始化脚本  

* 时间设置，时区默认上海
* ssh修改，禁用root登录，新增账号，修改端口为36263，
* 安装基础工具net-tool wget lsof



### phpweb.sh
php站点环境部署

* nginx安装
* php安装，支持7或8
* mariadb 10.2安装
* redis 安装
* 定期清除nginx日志

## 开源协议说明
![](./1.gif)
