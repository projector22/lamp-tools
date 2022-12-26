#!/bin/bash

##
# Tool to start, stop and restart the services pertaining to a web service,
# namely Apache2 & MySQL.
#
# Arguments:
# - --start
# - --stop
# - --restart
# 
# Author:
# Gareth Palmer [@projector22]
##

case $1 in
    --start)
    echo "Starting Apache2 & MySQL"
    sudo service apache2 start
    sudo service mysql start
    ;;

    --stop)
    echo "Stopping Apache2 & MySQL"
    sudo service apache2 stop
    sudo service mysql stop
    # sudo cron
    ;;

    --restart)
    echo "Restarting Apache2 & MySQL"
    sudo service apache2 restart
    sudo service mysql restart
    ;;

    *)
    echo "Invalid flag. Use either --start, --stop or --restart"
    ;;
esac
