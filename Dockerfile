FROM ubuntu:14.04
MAINTAINER Santiago Ciciliani
LABEL version="1.0.0"


RUN apt-get -qq update
RUN apt-get -qq -y upgrade

RUN echo "mysql-server mysql-server/root_password password toor" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password toor" | debconf-set-selections

RUN DEBIAN_FRONTEND=noninteractive apt-get -qq -y install mysql-server mysql-client unzip wget supervisor

RUN wget --quiet -O - https://packages.icinga.org/icinga.key | apt-key add -

RUN echo "deb http://packages.icinga.org/ubuntu icinga-trusty main" >> /etc/apt/sources.list.d/icinga2.list

RUN apt-get -qq update

RUN DEBIAN_FRONTEND=noninteractive apt-get -qq -y install icinga2 icinga2-ido-mysql icinga-web nagios-plugins icingaweb2 icingacli php5-curl

RUN sed -i 's/;date.timezone =/date.timezone = UTC/g' /etc/php5/apache2/php.ini

RUN icingacli setup config directory --group www-data


RUN wget  --no-cookies "https://s3.amazonaws.com/icinga2-deploy/icinga2-config.tgz" -O /tmp/icinga2-config.tgz
RUN tar -xvzf /tmp/icinga2-config.tgz -C /
RUN chmod 755 /opt/init.sh

RUN icinga2 api setup

# set icinga2 NodeName and create proper certificates required for the API
RUN sed -i -e 's/^.* NodeName = .*/const NodeName = "docker-icinga2"/gi' /etc/icinga2/constants.conf; \
 icinga2 pki new-cert --cn docker-icinga2 --key /etc/icinga2/pki/docker-icinga2.key --csr /etc/icinga2/pki/docker-icinga2.csr; \
 icinga2 pki sign-csr --csr /etc/icinga2/pki/docker-icinga2.csr --cert /etc/icinga2/pki/docker-icinga2.crt;

RUN find /etc/icingaweb2 -type f -name "*.ini" -exec chmod 660 {} \;
RUN find /etc/icingaweb2 -type d -exec chmod 2770 {} \;

EXPOSE 22 80 443 5665 3306

CMD ["/opt/init.sh"]

