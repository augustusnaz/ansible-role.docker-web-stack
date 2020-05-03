#!/bin/bash


## Template config
export MAIL_HOST=${MAIL_HOST:-"postal.example.com"}
export WEB_HOST=${WEB_HOST:-$MAIL_HOST}
export DB_HOST=${DB_HOST:-"127.0.0.1"}
export DB_USERNAME=${DB_USERNAME:-postal}
export DB_PASSWORD=${DB_PASSWORD:-p0stalpassw0rd}
export DB_DATABASE=${DB_DATABASE:-postal}
export DB_PREFIX=${DB_PREFIX:-postal}
export RABBITMQ_HOST=${RABBITMQ_HOST:-rabbitmq}
export RABBITMQ_USER=${RABBITMQ_USER:-postal}
export RABBITMQ_PASS=${RABBITMQ_PASS:-p0stalpassw0rd}
export RABBITMQ_VHOST=${RABBITMQ_VHOST:-postal}


postal_install(){
	echo "=> Downloading source"
	wget https://postal.atech.media/packages/stable/latest.tgz -O - | tar zxpv -C .  > /dev/null 2>&1
	chown -R postal:postal .
	ln -s /opt/postal/app/bin/postal /usr/bin/postal
	echo "=> Bundling app"
	postal bundle /opt/postal/vendor/bundle > /dev/null 2>&1
}

await_mysql () {
	echo "=> Waiting for MySQL connection"
	while ! mysqladmin ping -h $1 --silent; do
		sleep 0.5
	done
}

# postal_install


## MySQL
if [ "$DB_HOST" == "127.0.0.1" ]; then

	VOLUME_HOME="/var/lib/mysql"

	echo "=> Installing SQL Server ..."
	apt-get install -y mariadb-server > /dev/null 2>&1
	echo "=> Done!"

	service mysql start

	await_mysql $DB_HOST

	if [[ ! -d $VOLUME_HOME/$DB_DATABASE ]]; then
		echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
		mysql -uroot -e "CREATE USER '${DB_USERNAME}'@'%' IDENTIFIED BY '${DB_PASSWORD}'"
		mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '${DB_USERNAME}'@'%' WITH GRANT OPTION"
		mysql -uroot -e "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE}"
	else
		echo "=> Using an existing MySQL volume"
	fi

else
    echo "=> Using external MySQL driver"
    await_mysql $DB_HOST
fi

postal initialize-config
secret_key=$(grep -o 'secret_key:[^,]*' /opt/postal/config/postal.yml)
export SECRET_KEY=${secret_key#"secret_key:"}
envsubst < /postal.env.yml > /opt/postal/config/postal.yml
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
