#!/bin/bash

# Got example from https://peromsik.com/codearea/automate-captive-portal-login-ubuntu-linux-17-04/

IF="wlp2s0"
SSID="cooper"
USER="user"
PASS="pass"

[ -z "$var" ] && { echo "This script should be placed under /etc/network/if-up.d/" && exit 0; }

[ "$IFACE" != "lo" ] || exit 0
#[ "$IFACE" = "$IF" ] || { echo "Not running script on interface $IFACE" && exit 0; }

ESSID=$(iwconfig $IFACE | grep ESSID | cut -d":" -f2 | sed 's/^[^"]*"\|"[^"]*$//g')
[ "$ESSID" = "$SSID" ] || { echo "Not running script. SSID: $ESSID Expected: $SSID" && exit 0; }

redir=$(curl -s http://detectportal.firefox.com/success.txt)

#[[ $redir != "success" ]] || { echo "Not running script; already logged in to $SSID wifi." && exit 0; }

echo "Running login script for $SSID wifi."

url=$(echo $redir | grep url | sed 's/^.*\(url=\)//' | sed "s/'>$//g")
#url=$(cat ../redirect | grep url | sed 's/^.*\(url=\)//' | sed "s/'>$//g")
#echo $url

form=$(curl -skL $url)
#echo $form

# Parse returned data and submit form
