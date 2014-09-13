FROM tutum/ubuntu:trusty
MAINTAINER Gabriel Melillo "gabriel@melillo.me"

ADD run-services.sh /usr/local/bin/

RUN apt-get update && apt-get -y upgrade
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

RUN echo "Europe/Berlin" > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

ADD owncloud.sql /usr/local/src/
RUN apt-get -y install nginx-full php5-fpm mysql-server php5-mysql php5-gd php5-curl php5-cli wget unzip

# Configuring database
RUN /usr/bin/mysqld_safe & \
    sleep 10s && \
    mysql < /usr/local/src/owncloud.sql

# Configuring nginx+php5-fpm
ADD www.conf /etc/php5/fpm/pool.d/
ADD default /etc/nginx/sites-available/

# Download latest OwnCloud
RUN wget https://download.owncloud.org/download/community/owncloud-latest.zip -O /usr/share/nginx/owncloud-latest.zip && \
    unzip /usr/share/nginx/owncloud-latest.zip -d /usr/share/nginx/
ADD autoconfig.php /usr/share/nginx/owncloud/config/
RUN chown www-data:www-data -R /usr/share/nginx/owncloud && \
    mkdir /oc_data && \
    chown www-data:www-data -R /oc_data

# Cleanup
RUN apt-get -y remove wget unzip && \
    apt-get autoremove -y && \
    rm -rf /usr/share/nginx/owncloud-latest.zip && \
    rm -rf /usr/local/src/owncloud.sql

VOLUME ['/oc_data', '/var/lib/mysql']

EXPOSE 80

CMD /usr/local/bin/run-services.sh

