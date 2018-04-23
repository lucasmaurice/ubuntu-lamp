# Use an official ubuntu runtime as a parent image
FROM ubuntu:16.04
LABEL MAINTAINER="Lucas Maurice <lucas.maurice@outlook.com>"

ENV DEBIAN_FRONTEND=noninteractive
ENV MYSQL_PASS=wArAyUaE7HI5FklXoGoQ

# Upgrade system and tools
RUN apt-get update && \
    apt-get install -y -q curl wget dialog apt-utils && \
    apt-get upgrade -y -q

# Prepare for php 7.2
RUN apt-get install -y -q software-properties-common python-software-properties && \
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php && \
    apt-get update

# Install server
RUN apt-get install -y -q apache2 php7.2 mysql-server php7.2-mysql php7.2-mbstring php7.2-gettext

# Config apache server
ADD ./config/* /etc/apache2/sites-available/
RUN mkdir /logs && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    echo "<ifModule mod_rewrite.c>" >> /etc/apache2/apache2.conf && \
    echo "    RewriteEngine On" >> /etc/apache2/apache2.conf && \
    echo "</ifModule>" >> /etc/apache2/apache2.conf && \
    a2enmod rewrite headers

# Prepare server
RUN usermod -d /var/lib/mysql/ mysql

# Install phpmyadmin
RUN service mysql start && \
    wget https://files.phpmyadmin.net/phpMyAdmin/4.8.0.1/phpMyAdmin-4.8.0.1-all-languages.tar.xz && \
    mkdir /usr/share/phpmyadmin && \
    tar xpvf phpMyAdmin-4.8.0.1-all-languages.tar.xz -C /usr/share/ && \
    mv /usr/share/phpMyAdmin-4.8.0.1-all-languages/* /usr/share/phpmyadmin && \
    rm phpMyAdmin-4.8.0.1-all-languages.tar.xz && \
    chown -R www-data:www-data /usr/share/phpmyadmin && chmod -R 755 /usr/share/phpmyadmin --recursive && \
    ln -s /usr/share/phpmyadmin /var/www/html
RUN ls /usr/share/phpmyadmin
RUN service mysql start && \
mysqladmin -u root password "${MYSQL_PASS}"

RUN echo "\033[1;32m>>>>>>>>>>\033[0m $MYSQL_PASS \033[1;32m<<<<<<<<<<\033[0m"

# Define environment variable
WORKDIR /var/www/html

# Make port 80 available to the world outside this container
EXPOSE 80

# Run app.py when the container launches
CMD service apache2 start; service mysql start; bash
