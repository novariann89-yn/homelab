#!/bin/bash
echo "Server online since: $(uptime -p)" > /var/www/html/uptime.txt
echo "Average load: $(cat /proc/loadavg | awk '{print $1,$2,$3}')" >> /var/www/html/uptime.txt
