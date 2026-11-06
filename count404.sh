#!/bin/bash
for book in /var/log/nginx/access.log /var/log/nginx/access.log-20261105 /var/log/nginx/banana.log
do
    if [ -r "$book" ]; then 
        echo "$book"
        grep ' 404 ' "$book" | wc -l
    elif [ -f "$book" ]; then
        echo "$book exist but locked try sudo"
    else 
        echo "$book that file doesnt exist"
    fi
done
