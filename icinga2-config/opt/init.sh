#!/bin/bash

FLAGFILE=/etc/icinga2/init.flag


if [ ! -f "$FLAGFILE" ]; then

	echo "INITIALIZING DATABASE"

	service mysql start
	service apache2 start

	echo "Waiting for db to start..."

	echo "CREATE DATABASE icingaweb2;"  | mysql -ptoor
	echo "GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE VIEW, INDEX, EXECUTE ON icingaweb2.* TO 'icingaweb2'@'localhost' IDENTIFIED BY 'icingaweb-pwd';" | mysql -ptoor
	mysql -ptoor icingaweb2 < /usr/share/icingaweb2/etc/schema/mysql.schema.sql

	echo "REPLACE INTO icingaweb_user (name, active, password_hash) VALUES ('icingaadmin', 1, '$1$tgJMNOIj$SSFGGOGuwpScrC5jIj9wq.');" | mysql -ptoor icingaweb2

	echo "CREATE DATABASE director CHARACTER SET 'utf8';"|  mysql -ptoor
	echo "GRANT ALL ON director.* TO director@localhost IDENTIFIED BY 'director-pwd';" | mysql -ptoor

	service mysql stop
	service apache2 stop
	
	touch $FLAGFILE
fi

/usr/bin/supervisord -n -c /etc/supervisor/icinga2.conf

