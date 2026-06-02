#!/bin/bash

# 获取用户输入，用于替换 docker-compose.yml 文件中的占位符
read -p "请输入 数据库ROOT密码：" dbrootpasswd
read -p "请输入 数据库用户名：" dbuse
read -p "请输入 数据库用户密码：" dbusepasswd


# 更新并安装必要的软件包
DEBIAN_FRONTEND=noninteractive apt update -y
DEBIAN_FRONTEND=noninteractive apt full-upgrade -y
apt install -y curl wget sudo socat unzip tar htop

# 安装 Docker
curl -fsSL https://get.docker.com | sh

# 安装 Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

# 创建必要的目录和文件
cd /home && mkdir -p web/html web/mysql web/certs web/conf.d web/redis && touch web/docker-compose.yml

# 创建 docker-compose.yml 文件并进行替换
cat > /home/web/docker-compose.yml << 'EOF'
version: '3.8'

services:
  nginx:
    image: nginx
    container_name: nginx
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./conf.d:/etc/nginx/conf.d
      - ./certs:/etc/nginx/certs
      - ./html:/var/www/html
      - ./log/nginx:/var/log/nginx

  php:
    image: php:fpm
    container_name: php
    restart: always
    volumes:
      - ./html:/var/www/html

  php74:
    image: php:7.4.33-fpm
    container_name: php74
    restart: always
    volumes:
      - ./html:/var/www/html

  mysql:
    image: mysql
    container_name: mysql
    restart: always
    volumes:
      - ./mysql:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: webroot
      MYSQL_USER: riwi001
      MYSQL_PASSWORD: riwi001YYDS

  redis:
    image: redis
    container_name: redis
    restart: always
    volumes:
      - ./redis:/data
EOF

# 在 docker-compose.yml 文件中进行替换
sed -i "s/webroot/$dbrootpasswd/g" /home/web/docker-compose.yml
sed -i "s/riwi001YYDS/$dbusepasswd/g" /home/web/docker-compose.yml
sed -i "s/riwi001/$dbuse/g" /home/web/docker-compose.yml

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F

cd /home/web && docker-compose up -d

docker exec php apt update &&
docker exec php apt install -y libmariadb-dev-compat libmariadb-dev libzip-dev libmagickwand-dev imagemagick &&
docker exec php docker-php-ext-install mysqli pdo_mysql zip exif gd intl bcmath opcache &&
docker exec php pecl install imagick &&
docker exec php sh -c 'echo "extension=imagick.so" > /usr/local/etc/php/conf.d/imagick.ini' &&
docker exec php pecl install redis &&
docker exec php sh -c 'echo "extension=redis.so" > /usr/local/etc/php/conf.d/docker-php-ext-redis.ini' &&
docker exec php sh -c 'echo "upload_max_filesize=50M \n post_max_size=50M" > /usr/local/etc/php/conf.d/uploads.ini' &&
docker exec php sh -c 'echo "memory_limit=256M" > /usr/local/etc/php/conf.d/memory.ini'


docker exec php74 apt update &&
docker exec php74 apt install -y libmariadb-dev-compat libmariadb-dev libzip-dev libmagickwand-dev imagemagick &&
docker exec php74 docker-php-ext-install mysqli pdo_mysql zip gd intl bcmath opcache &&
docker exec php74 pecl install imagick &&
docker exec php74 sh -c 'echo "extension=imagick.so" > /usr/local/etc/php/conf.d/imagick.ini' &&
docker exec php74 pecl install redis &&
docker exec php74 sh -c 'echo "extension=redis.so" > /usr/local/etc/php/conf.d/docker-php-ext-redis.ini' &&
docker exec php74 sh -c 'echo "upload_max_filesize=50M \n post_max_size=50M" > /usr/local/etc/php/conf.d/uploads.ini' &&
docker exec php74 sh -c 'echo "memory_limit=256M" > /usr/local/etc/php/conf.d/memory.ini'

