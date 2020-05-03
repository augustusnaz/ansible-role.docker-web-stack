#!/bin/bash


## Template config
export DOMAIN=${DOMAIN:-"postal.example.com"}
export WEB_DOMAIN=${WEB_DOMAIN:-$DOMAIN}
export DB_HOST=${DB_HOST:-mysql}
export DB_USERNAME=${DB_USERNAME:-postal}
export DB_PASSWORD=${DB_PASSWORD:-p0stalpassw0rd}
export DB_DATABASE=${DB_DATABASE:-postal}
export DB_PREFIX=${DB_PREFIX:-postal}
export RABBITMQ_HOST=${RABBITMQ_HOST:-rabbitmq}
export RABBITMQ_USER=${RABBITMQ_USER:-postal}
export RABBITMQ_PASS=${RABBITMQ_PASS:-p0stalpassw0rd}
export RABBITMQ_VHOST=${RABBITMQ_VHOST:-"/postal"}
export RAILS_SECRET_KEY=$(openssl rand -base64 32)


## MySQL
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
	echo "=> Waiting for MySQL connection"
	while ! mysqladmin ping -h $DB_HOST --silent; do
		sleep 0.5
	done
fi


postal initialize-config
envsubst < /postal.env.yml > /opt/postal/config/postal.yml
chown postal:postal /opt/postal/config/postal.yml
postal initialize

## Create user
postal make-user <<-EOF
$POSTAL_EMAIL
$POSTAL_FNAME
$POSTAL_LNAME
$POSTAL_PASSWORD
EOF

## Start Postal
postal "$@"
