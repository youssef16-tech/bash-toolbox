#!/bin/bash
if [ -r /var/log/nginx/access.log ]; then
	echo "I found it and its unlocked"
	grep ' 404 ' /var/log/nginx/access.log | wc -l
elif [ -f /var/log/nginx/access.log ] ; then
	echo "its there but locked, run the script with sudo"
else
	echo "no log found"
fi
