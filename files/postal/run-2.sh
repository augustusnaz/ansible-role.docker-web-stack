#!/bin/bash



###########################################################################
# RabbitMQ:
###########################################################################

echo "=> Initalising RabbitMQ"
rabbitmqctl add_vhost /postal > /dev/null 2>&1
rabbitmqctl add_user postal p0stalpassw0rd > /dev/null 2>&1
rabbitmqctl set_permissions -p /postal postal ".*" ".*" ".*" > /dev/null 2>&1
echo "=> Done!"



###########################################################################
# Database:
###########################################################################

if [ "$DB_HOST" == "127.0.0.1" ]; then

	VOLUME_HOME="/var/lib/mysql"

	echo "=> Installing SQL Server ..."
	apt-get install -y mariadb-server > /dev/null 2>&1

	# Try the 'preferred' solution
	mysqld --initialize-insecure > /dev/null 2>&1

	# sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
	# sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/*server.cnf
	# sed -i "s/^user.*=.*/user = root/g" /etc/mysql/mariadb.conf.d/*server.cnf

	echo "=> Done!"

	if [[ ! -d $VOLUME_HOME/$DB_DATABASE ]]; then
		echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
		service mysql restart > /dev/null 2>&1
		mysql -uroot -e "CREATE USER '${DB_USERNAME}'@'%' IDENTIFIED BY '${DB_PASSWORD}'"
		mysql -uroot -e "GRANT USAGE ON *.* TO '${DB_USERNAME}'@'%' IDENTIFIED BY '${DB_PASSWORD}'"
		mysql -uroot -e "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE}"
		mysql -uroot -e "GRANT ALL PRIVILEGES ON ${DB_DATABASE}.* TO '${DB_USERNAME}'@'%'"
	else
		echo "=> Using an existing MySQL volume"
	fi

else
    echo "=> Using external MySQL driver"
fi



###########################################################################
# Postal init:
###########################################################################

postal initialize-config
postal initialize



service nginx restart

postal run