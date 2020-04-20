#!/bin/sh
echo "Waiting for $HEALTH_CHECK_URL to be online"

# Wait until the server at the provided $HEALTH_CHECK_URL is up before actually running certbot
until [ $(curl -s -L --head --fail -o /dev/null -w '%{http_code}\n' --connect-timeout 3 --max-time 5 $HEALTH_CHECK_URL) -eq 200 ]; do
  printf '.'
  sleep 5
  # -s = Silent cURL's output
  # -L = Follow redirects
  # -w = Custom output format
  # -o = Redirects the HTML output to /dev/null
done

echo ""
echo "$HEALTH_CHECK_URL is online, running certbot"

# one-time execution at container start once host's health check is ok
/scripts/run_certbot.sh

# scheduling periodic executions
exec crond -f