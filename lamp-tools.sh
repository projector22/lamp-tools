#!/bin/bash

##
# Tool to start, stop and restart the services pertaining to a web service,
# namely Apache2 & MySQL. It also contains tools for setting up various configurations
# of the LAMP stack.
#
# Arguments:
# - --help | -h 
# - --start
# - --stop
# - --restart
# - --status
# - --setup-dev-env
# - --setup-apache2
# - --setup-php
# - --setup-mysql
# 
# Author:
# Gareth Palmer [@projector22]
##


## Install some basic tools, mysql-server, git and openssh-server
install_mysql() {
    sudo apt update
    sudo apt install git openssh-server mysql-server apache2 -yy
    sudo service apache2 start
    sudo service mysql start
    printf "Complete\n\n"
}

## Create a user account for mysql
setup_mysql_user() {
    username=$1
    password=$2
    echo "Creating mysql user with the above credentials..."
    printf "Note: this is for a DEV environment and all privileges are being granted. This is not recomended in a PROD environment\n\n"
    echo "Creating user..."
    sudo mysql --execute="CREATE USER '$username'@'localhost' IDENTIFIED BY '$password';"
    echo "Assign privileges..."
    sudo mysql --execute="GRANT ALL PRIVILEGES ON *.* TO '$username'@'localhost';"
    sudo mysql --execute="FLUSH PRIVILEGES;"
    printf "Complete\n\n"
}

## Install php & phpmyadmin
install_php() {
    sudo apt install php php-ldap php-gmp composer -yy
    sudo apt install phpmyadmin -yy
    printf "Complete\n\n"
}

## Configure apache2.conf and enable .htaccess
configure_apache() {
    apache_conf="/etc/apache2/apache2.conf"
    echo "Backing up $apache_conf -> $apache_conf.bak"
    sudo cp $apache_conf $apache_conf.bak
    echo "Enabling .htaccess"
    sudo sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' $apache_conf
    sudo a2enmod rewrite
    sudo service apache2 restart
    printf "Complete\n\n"
}

## configure PHP to increase post and file size limits
configure_php() {
    ini_path="/etc/php/8.1/apache2/php.ini"
    size="200M"
    echo "Backing up $ini_path -> $ini_path.bak"
    sudo cp $ini_path $ini_path.bak
    printf "Complete\n\n"

    echo "Setting post_max_size & upload_max_filesize to $size"
    upload=$(grep -F "post_max_size" $ini_path)
    new_upload="post_max_size=$size"
    sudo sed -i "s/$upload/$new_upload/" $ini_path

    post=$(grep -F "upload_max_filesize" $ini_path)
    new_post="upload_max_filesize=$size"
    sudo sed -i "s/$post/$new_post/" $ini_path
    printf "Complete\n\n"
}


setup_dev_env() {
    printf "Step one - install mysql, git and ssh\n\n"
    install_mysql

    echo "Step 2. Set up a mysql user account"
    read -rp "Username: " mysql_username
    read -rp "Password: " mysql_password
    setup_mysql_user "$mysql_username" "$mysql_password"

    echo "Step 3. Installing phpmyadmin php8.1-ldap"
    install_php

    echo "Step 4. Configure Apache2 and PHP"
    configure_php
    configure_apache

    echo "Enter a Git global name"
    read -r name
    echo "Enter a Git global email account"
    read -r mail

    git config --global user.name "$name"
    git config --global user.mail "$mail"

    printf "\n\nComplete"
}

help_info() {
    echo "Usage: lamp [options]"
    echo "Options:"
    printf "  -h, --help\t   Show this help message\n"
    printf "  --start\t   Start the LAMP Server (apache2 & mysql)\n"
    printf "  --stop\t   Stop the LAMP Server (apache2 & mysql)\n"
    printf "  --restart\t   Restart the LAMP Server (apache2 & mysql)\n"
    printf "  --status\t   Show the status of the LAMP Server (apache2 & mysql)\n"
    printf "  --setup-dev-env  Install the full dev environment, including the setup of php, apache2 & mysql, as well as phpMyAdmin, Composer & openSSH-server and the basic configuration of git\n"
    printf "  --setup-apache2  Install and perform basic configuration of just Apache2\n"
    printf "  --setup-php\t   Install and perform basic configuration of just PHP\n"
    printf "  --setup-mysql\t   Install and perform basic configuration of just MySQL\n"
}


case $1 in
    -h | --help)
        echo "LAMP TOOLS HELP"
        help_info
    ;;

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

    --status)
        echo "Status of Apache2 & MySQL"
        sudo service apache2 status
        sudo service mysql status
    ;;

    --setup-dev-env)
        echo "This process will perform a number of tasks that will set up this server as a test environment."
        setup_dev_env
    ;;

    --setup-apache2)
        sudo apt update
        sudo apt install apache2 -yy
        sudo service apache2 start
        configure_apache
    ;;

    --setup-php)
        sudo apt update
        install_php
        configure_php
    ;;

    --setup-mysql)
        printf "Setting up MySQL\n"
        sudo apt update
        sudo apt install mysql-server -yy
        sudo service mysql start

        echo "Set up a mysql user account"
        read -rp "Username: " mysql_username
        read -rp "Password: " mysql_password
        setup_mysql_user "$mysql_username" "$mysql_password"
    ;;

    *)
        echo "Invalid flag parsed..."
        help_info
    ;;
esac
