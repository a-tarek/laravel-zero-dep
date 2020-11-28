FROM php:7.4-apache

RUN sed -i '10i\\n\tServerName www.hafiz.com' /etc/apache2/sites-available/000-default.conf
RUN sed -ie 's/html/html\/public/g' /etc/apache2/sites-available/000-default.conf
RUN sed -i '19i\\n\t<Directory> "/var/www/html/public">\n\
    \t\tAllowOverride All\n\
    \t\tAllow from ALl\n\
    \t\tRequire all granted\n\
    \t</Directory>' /etc/apache2/sites-available/000-default.conf

RUN a2enmod rewrite


# Install system dependencies
RUN apt-get update -y && apt-get install -y libmcrypt-dev openssl
RUN docker-php-ext-install pdo_mysql
RUN pecl install mcrypt-1.0.3
RUN docker-php-ext-enable mcrypt

RUN apt-get update && apt-get install -y \
    curl \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*


# Arguments defined in docker-compose.yml
ARG user
ARG uid

RUN echo $uid $user
# RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN adduser --disabled-password --gecos "" -u $uid $user
RUN usermod -aG www-data $user
RUN usermod -aG $user www-data
WORKDIR /var/www/html
