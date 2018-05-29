FROM php:5.6-fpm

ENV CLIENT_LOCALE "ru_ru.1251"
ENV DB_LOCALE "ru_ru.1251"

COPY informix /var/lib/IBM/informix
COPY PDO_INFORMIX-1.3.1 /opt/PDO_INFORMIX-1.3.1
COPY php.ini /usr/local/etc/php/

RUN apt-get update; \
apt-get install -y ssmtp; \
echo "mailhub=mail:25\nUseTLS=NO\nFromLineOverride=YES" > /etc/ssmtp/ssmtp.conf; \
apt-get install -y git

RUN cd /opt/PDO_INFORMIX-1.3.1; \
phpize; \
./configure --with-pdo-informix=/var/lib/IBM/informix; \
make; \
make install;

RUN pecl install xdebug-2.5.5
RUN docker-php-ext-install sockets

RUN apt-get update && apt-get install -y zlib1g-dev \
    && docker-php-ext-install zip

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
php composer-setup.php --install-dir=/usr/bin --filename=composer && \
php -r "unlink('composer-setup.php');" && \
composer global require "codeception/codeception:*"; \
ln -s /root/.composer/vendor/codeception/codeception/codecept /usr/bin/codecept

WORKDIR /var/www

CMD php-fpm -R

