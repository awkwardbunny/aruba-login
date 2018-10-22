#!/bin/bash

# Got example from https://peromsik.com/codearea/automate-captive-portal-login-ubuntu-linux-17-04/

SSID="cooper"
USER="user"
PASS="pass"

# Make it run auto
[ -z "$IFACE" ] && { echo "This script should be placed under /etc/network/if-up.d/ (for linux)" && echo "or run it manually with the IFACE variable set to your wifi interface" && exit 0; }

# Don't run on lo
[ "$IFACE" != "lo" ] || exit 0

# Check if right network
ESSID=$(iwconfig $IFACE | grep ESSID | cut -d":" -f2 | sed 's/^[^"]*"\|"[^"]*$//g')
[ "$ESSID" = "$SSID" ] || { echo "Not running script. SSID: $ESSID Expected: $SSID" && exit 0; }

# Parse command (login or logout)
[ ! -z "$1" ] && command=$1
[ -z "$command" ] && command="login"

# If login
if [ "$command" = "login" ]; then

	# Check if logged in already
	redir=$(curl -s http://detectportal.firefox.com/success.txt)
	[[ $redir != "success" ]] || { echo "Not running script; already logged in" && exit 0; }

	# If not, log in!
	echo "Running login script for $SSID wifi."
	result=$(curl -s "https://captiveportal-login.cooper.edu/cgi-bin/login?user=$USER&password=$PASS&cmd=authenticate")

elif [ "$command" = "logout" ]; then

	# Log out!
	echo "Running logout script for $SSID wifi."
	result=$(curl -s "https://captiveportal-login.cooper.edu/cgi-bin/login?cmd=logout")

fi

if [[ $result == *"Login incorrect"* ]]; then
	echo "Login incorrect"
else
	msg=$(echo $result | grep -o '<b>.*</b>' | sed 's/\(<b>\|<\/b>\)//g')
	echo $msg
fi
