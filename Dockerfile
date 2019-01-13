FROM debian:stretch
MAINTAINER Hamed Bahadorzadeh "h.bahadorzadeh@gmail.com"

RUN apt-get update && \
      apt-get install -y \
        curl \
        wget \
        gnupg


#PHP7.2
RUN wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
RUN echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list

RUN apt-get install -y ca-certificates apt-transport-https

RUN apt-get update && \
        apt-get install -y \
            php7.2 \
            php7.2-cli \
            php7.2-common \
            php7.2-opcache \
            php7.2-curl \
            php7.2-mbstring \
            php7.2-mysql \
            php7.2-zip \
            php7.2-xml\
            php7.2-json

#PHP ionCube loader
ADD https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz /tmp/
RUN tar xvzfC /tmp/ioncube_loaders_lin_x86-64.tar.gz /tmp/ \
    && rm /tmp/ioncube_loaders_lin_x86-64.tar.gz \
    && mkdir -p /usr/local/ioncube \
    && cp /tmp/ioncube/ioncube_loader_lin_7.2.so /usr/local/ioncube \
    && rm -rf /tmp/ioncube

RUN echo "zend_extension = /usr/local/ioncube/ioncube_loader_lin_7.2.so" >> /etc/php/7.2/apache2/conf.d/00-ioncube.ini
RUN echo "zend_extension = /usr/local/ioncube/ioncube_loader_lin_7.2.so" >> /etc/php/7.2/cli/conf.d/00-ioncube.ini

#PHP composer
RUN cd /tmp && \
    curl -sS https://getcomposer.org/installer | php && \
    mv /tmp/composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer && \
    composer self-update

#phpunit
RUN composer require --dev phpunit/phpunit ^7 && ./vendor/bin/phpunit --version


#BringUp the web
VOLUME ["/var/www/html"]

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]