#!/bin/bash

# Got example from https://peromsik.com/codearea/automate-captive-portal-login-ubuntu-linux-17-04/

SSID="cooper"
USER="user"
PASS="pass"

[ -z "$IFACE" ] && { echo "This script should be placed under /etc/network/if-up.d/" && exit 0; }

[ "$IFACE" != "lo" ] || exit 0

ESSID=$(iwconfig $IFACE | grep ESSID | cut -d":" -f2 | sed 's/^[^"]*"\|"[^"]*$//g')
[ "$ESSID" = "$SSID" ] || { echo "Not running script. SSID: $ESSID Expected: $SSID" && exit 0; }

[ ! -z "$1" ] && command=$1
[ -z "$command" ] && command="login"

if [ "$command" = "login" ]; then
	redir=$(curl -s http://detectportal.firefox.com/success.txt)
	[[ $redir != "success" ]] || { echo "Not running script; already logged in to $SSID wifi." && exit 0; }
	echo "Running login script for $SSID wifi."
	result=$(curl -s "https://captiveportal-login.cooper.edu/cgi-bin/login?user=$USER&password=$PASS&cmd=authenticate")
elif [ "$command" = "logout" ]; then
	echo "Running logout script for $SSID wifi."
	result=$(curl -s "https://captiveportal-login.cooper.edu/cgi-bin/login?cmd=logout")
fi

if [[ $result == *"Login incorrect"* ]]; then
	echo "Login incorrect"
else
	msg=$(echo $result | grep -o '<b>.*</b>' | sed 's/\(<b>\|<\/b>\)//g')
	echo $msg
fi

#url=$(echo $redir | grep url | sed 's/^.*\(url=\)//' | sed "s/'>$//g" | sed "s/'.*//g")
#url=$(cat ../redirect | grep url | sed 's/^.*\(url=\)//' | sed "s/'>$//g")
#echo $url

#form=$(curl -skL $url)
#echo $form

#location=$(curl -sI $url | grep Location | cut -d ' ' -f 2)
#echo $location

# Parse returned data and submit form
#result=$(curl -s --data "user=$USER&password=$PASS&cmd=authenticate&Login=Log+In" https://captiveportal-login.cooper.edu/cgi-bin/login)
#echo $result
#result=$(cat output.log)
#echo $result

#curl -s "https://captiveportal-login.cooper.edu/cgi-bin/login?user=$USER&password=$PASS&cmd=authenticate"
