#!/bin/bash


###########################################################################
# Clean Up:
###########################################################################

rm -rf /opt/postal/tmp/pids/*
rm -rf /tmp/postal


###########################################################################
# Wait for MySQL and RabbitMQ to start up:
###########################################################################

echo "=> Waiting for MySQL and RabbitMQ to start up"
_db_host=${DB_HOST:-mysql}
_db_port=${DB_PORT:-3306}
_rabbitmq_host=${RABBITMQ_HOST:-rabbitmq}
_rabbitmq_port=${RABBITMQ_PORT:-5672}
dockerize -wait tcp://${_db_host}:${_db_port} -wait http://${_rabbitmq_host}:${_rabbitmq_port}/api/aliveness-test

###########################################################################
# Init:
###########################################################################

/opt/postal/bin/postal initialize-config
/opt/postal/bin/postal initialize


###########################################################################
# Create user:
###########################################################################

/opt/postal/bin/postal make-user <<-EOF
$POSTAL_EMAIL
$POSTAL_FNAME
$POSTAL_LNAME
$POSTAL_PASSWORD
EOF



# Start Postal
# /opt/postal/bin/postal "$@"
/opt/postal/bin/postal run