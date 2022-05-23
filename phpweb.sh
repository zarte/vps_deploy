#!/bin/bash
#修改源
nginxrepo="/etc/yum.repos.d/nginx.repo"
touch $nginxrepo
echo -e "[nginx] \nname=nginx repo \nbaseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/ \ngpgcheck=0 \nenabled=1 \n" >  $nginxrepo
#安装
yum -y install nginx
systemctl start nginx

#开放端口
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload

#php7.3
read -p "switch php version 7 or 8 (default 7): "  pversion
if [ "$pversion" == "8" ];then
    yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
    yum install -y php73-php-fpm php73-php-cli php73-php-bcmath php73-php-gd php73-php-json php73-php-mbstring php73-php-mcrypt php73-php-mysqlnd php73-php-opcache php73-php-pdo php73-php-pecl-crypto php73-php-pecl-mcrypt php73-php-pecl-geoip php73-php-recode php73-php-snmp php73-php-soap php73-php-xml
    systemctl enable php73-php-fpm
    systemctl start php73-php-fpm
    php -v
else
#elif
    #卸载yum remove -y php*
    yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm
    yum install yum-utils
    #单独启用php80的源
    yum-config-manager --disable 'remi-php*'
    yum-config-manager --enable remi-php80

    yum install -y php php-bcmath php-cli php-common php-devel php-fpm php-gd php-intl php-ldap php-mbstring php-mysqlnd php-odbc php-pdo php-pear php-pecl-xmlrpc php-pecl-zip php-process php-snmp php-soap php-sodium php-xml
    php -v
    systemctl enable php-fpm
    systemctl start php-fpm
fi


ngcofbak="/etc/nginx/conf.d/default.conf.bak"
ngcof="/etc/nginx/conf.d/default.conf"
if [-e "$ngcofbak"]; then
   cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
fi

##############
# nginx配置添加php
#
#location ~ \.php$ {
#        root           /usr/share/nginx/html;
#        fastcgi_pass   127.0.0.1:9000;
#       fastcgi_index  index.php;
#       fastcgi_param  SCRIPT_FILENAME  #$document_root$fastcgi_script_name;
#        include        fastcgi_params;
#   }
##########
echo -e "server {\n    listen       80;\n    server_name  localhost;\n    location / {\n        root   /usr/share/nginx/html;\n        index  index.html index.htm;\n    }\n    location = /50x.html {\n        root   /usr/share/nginx/html;\n    }\n\n\nlocation ~ \\.php\$ {\n    root    /usr/share/nginx/html;\n    fastcgi_pass    127.0.0.1:9000;\n    fastcgi_index    index.php;\n    fastcgi_param    SCRIPT_FILENAME \$document_root\$fastcgi_script_name;\n    include    fastcgi_params;\n    }\n}" >  $ngcof

echo -e "<?php\n    phpinfo(); " > /usr/share/nginx/html/test.php

#重启nginx
systemctl restart nginx
#访问http://ip/test.php

# 数据库
touch /etc/yum.repos.d/mariadb.repo

read -p "switch mariadb repo c or a (default abroad): "  pversion
if [ "$pversion" == "c" ];then

echo -e "[mariadb]\n\nname = MariaDB\n\nbaseurl =https://mirrors.ustc.edu.cn/mariadb/yum/10.2/centos7-amd64\n\ngpgkey=https://mirrors.ustc.edu.cn/mariadb/yum/RPM-GPG-KEY-MariaDB\n\ngpgcheck=1" > /etc/yum.repos.d/mariadb.repo

else

echo -e "[mariadb]\n\nname = MariaDB\n\nbaseurl =http://yum.mariadb.org/10.2/centos7-amd64\n\ngpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB\n\ngpgcheck=1" > /etc/yum.repos.d/mariadb.repo

fi

yum clean all
yum update
yum install MariaDB* -y

systemctl start mariadb.service
systemctl enable mariadb.service

mysql_secure_installation

#ssl
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --zone=public --permanent --add-service=ipsec
firewall-cmd --zone=public --permanent --add-masquerade
firewall-cmd --reload

#redis
yum install -y gcc
yum install -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

yum --enablerepo=remi install redis

systemctl start redis
systemctl enable redis.service
redis-cli --version

## 定期清除nginx日志
echo -e "find /var/log/nginx -mtime +30 -name \"access.log-*\" -exec rm -rf {} ; >> /var/log/nginx/delete.log \nfind /var/log/nginx -mtime +30 -name \"error.log-*\" -exec rm -rf {} ; >> /var/log/nginx/delete.log " > /var/log/nginx/del.sh

chmod 777 /var/log/nginx/del.sh

echo "0 0 1 * * root /var/log/nginx/del.sh" >> /etc/crontab
cat /etc/crontab