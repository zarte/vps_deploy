#!/bin/bash
#更新内核
yum -y update
if [ $? -ne 0 ]; then
    echo "update fail"
    exit 1
fi
#时区设置
read -p "input now datetime: " nowtime
if [ "$nowtime" != "" ];then
  timedatectl set-timezone Asia/Shanghai
  date -s "$nowtime"
fi
#新增登录用账号
read -p "input new user: " newuser
if [ "$newuser" != "" ];then
  adduser "$newuser"
  passwd "$newuser"
fi

#ssh登录配置
read -p "don't allow root ssh:(y) " tflag
if [ "$tflag" = "y" ] || [ "$tflag" = "Y" ];then
  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
  sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
  sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
fi

sed -i 's/#Port 22/Port 36263/g' /etc/ssh/sshd_config
sed -i 's/Port 22/Port 36263/g' /etc/ssh/sshd_config
yum -y install policycoreutils-python
semanage port -a -t ssh_port_t -p tcp 36263
semanage port -l | grep ssh
firewall-cmd --permanent --add-port=36263/tcp
firewall-cmd --reload
#查看是否开启36263
echo "check ssh port"
firewall-cmd --permanent --query-port=36263/tcp
systemctl restart sshd.service
#安装基础工具
yum install net-tool wget lsof
echo "init complete!!!"