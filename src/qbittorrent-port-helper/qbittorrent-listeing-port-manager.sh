#!/bin/bash

OLD_PORT_NUMBER=0
PORT_NUMBER=0

# Read an env file to set the options for qbittorrent
set -a
source <(cat /scripts/qbittorrent-listeing-port-manager.env | sed -e '/^#/d;/^\s*$/d' -e "s/'/'\\\''/g" -e "s/=\(.*\)/='\1'/g")
set +a

# On terminiation, exit with code 0
trap 'exit 0' SIGTERM

# Give the VPN and qBittorrent a few seconds to get started
echo "Waiting 10 seconds for the VPN and qBittorrent to be available."
echo "***************************************************************"
echo "If this is the first time qBittorrent is being used, check the "
echo "output of the qBittorrent service container for the assigned   "
echo "temporary login credentials."
echo "***************************************************************"
sleep 10 & 
wait $!
 
COOKIE=$(curl -i --silent http://localhost:8080/api/v2/auth/login -H "application/x-www-form-urlencoded" -d "username=admin&password=abcd1234" | grep set-cookie | awk '{print $2}')
# echo "qbittorrent cookie value: ($COOKIE)";

if $BYPASS_AUTH_SUBNET_WHITELIST_ENABLED
then
  echo "Turning off qBittorrent auth for subnet $BYPASS_AUTH_SUBNET_WHITELIST"
  curl --silent -X POST http://localhost:8080/api/v2/app/setPreferences --cookie "$COOKIE" -H "application/x-www-form-urlencoded" -d "json={\"bypass_auth_subnet_whitelist\":\"$BYPASS_AUTH_SUBNET_WHITELIST\"}"
  curl --silent -X POST http://localhost:8080/api/v2/app/setPreferences --cookie "$COOKIE" -H "application/x-www-form-urlencoded" -d "json={\"bypass_auth_subnet_whitelist_enabled\":\"true\"}"
fi

while true
do
  [ -r "/pia-shared/port.dat" ] && PORT_NUMBER=$(cat /pia-shared/port.dat)

  NOW=$(date)
  echo "$NOW :: I am watching the file /pia-shared/port.dat for PIA forwarding port number changes."
  if [ $OLD_PORT_NUMBER -ne $PORT_NUMBER ]; then
 
    echo "$NOW :: The port number has changed!! --- setting qbittorrent port to: ($PORT_NUMBER)"
    curl --silent -X POST http://localhost:8080/api/v2/app/setPreferences --cookie "$COOKIE" -H "application/x-www-form-urlencoded" -d "json={\"listen_port\":\"$PORT_NUMBER\"}"
  
    OLD_PORT_NUMBER=$PORT_NUMBER
  fi

  sleep 30 & 
  wait $!
done