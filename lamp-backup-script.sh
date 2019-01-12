#!/bin/bash

# BACKUP WEBSITES ON A LAMP (Linux Apache MySQL/MariaDB PHP) SERVER
#
# Author: Ruben J. Sibon
# Mail: mail@webricolage.nl

# Log to file and terminal.
# First parameter is message to log
# Second parameter should be type of message and one of "info" or "error"
function log {
  MSG=$1
  TYPE=$2
  TIMESTAMP=`date`;

  # Color for each log type
  LOG_TYPE=$TYPE;

  LOG_MSG="$LOG_TYPE $MSG"

  echo "$TIMESTAMP  $LOG_TYPE  $LOG_MSG\n" >> $BACKUP_PATH/log.log;
  echo $LOG_MSG
}

# Quit the program
function quit {
  echo $1;
  exit;
}

# On fail log and print error message and call the quit function
function fail {
  log $1 'error';
  quit;
}

# Check what type of site we have. Can be one of:
#   1) "default" - Plain HTML site or unknown CMS;
#   2) "drupal" - A Drupal site with a local Drush;
#   3) "grav" - A Grav site with bin/gpm;
#   4) "wordpress" - A WordPress site with wp-cli.
function checkSiteType {
  # Check each vhost webroot and test in what category it should go.
  # Add each webroot directory and sitename to a seperate array.
  # Pass these lists to the appropriate backup scripts.
}

# Root permissions are required
if [ "$(whoami)" != "root" ]; then
  echo "Root privileges are required to run this, try running with sudo...";
  exit 2;
fi

# Backup settings
## Basic
BASE_DIR="/opt/";
BACKUP_DIR="site-backups";
BACKUP_PATH="$BASE_DIR$BACKUP_DIR";
NOW="date +%Y%m%d%H%M%S";

## Webroots
WEBROOT="/var/www/sites/";

## Apache
HOSTS="/etc/hosts";
VHOSTS_PATH="/etc/apache2/sites-enabled/"
PATTERN="DocumentRoot"

# MySQL
DBUSER="root";
DBHOST="localhost";
DEFAULTCHARSET="utf8";

# Binaries
MYSQL=/usr/bin/mysql;
GREP=/bin/grep;
REMOVE=/bin/rm;
GZIP=/bin/gzip;
DATE=/bin/date;
MK=/bin/mkdir;
MYSQLDUMP=/usr/bin/mysqldump;

## [[ DEBUG ]] ##
echo "$BASE_DIR$BACKUP_DIR";
## [[ DEBUG ]] ##

# Make new backup directory if it does not exist.
if [ ! -d "$BACKUP_PATH" ]; then
  printf "Backup directory not found.\nMaking directory \"$BACKUP_DIR\" in \"$BASE_DIR\" ...\n";
  cd $BASE_DIR;
  mkdir $BACKUP_DIR;
fi

# Collect site webroots from vhosts and log them.
## Remove any pre-existing vhost logs.
if [ -f "$BACKUP_PATH/vhosts-all.log" ]; then
  rm $BACKUP_PATH/vhosts-all.log;
fi

## Go to vhosts directory.
cd $VHOSTS_PATH;
shopt -s nullglob;

## Get the webroot for each site in vhosts.
for f in *; do
   cat $f | \
     sed -e "/DocumentRoot.*/!d" | sed "s/[[:blank:]]//g" | sed "s/DocumentRoot//" >> $BACKUP_PATH/vhosts-all.log;
done

## Sort and clean vhosts and log them.
sort -u $BACKUP_PATH/vhosts-all.log > $BACKUP_PATH/vhosts-list.log;
rm $BACKUP_PATH/vhosts-all.log;
echo "All Apache Virtual Host webroots:";
cat $BACKUP_PATH/vhosts-list.log;

# Move to backup directory and create timestamped folder.
echo "Moving to \"$BACKUP_PATH\" ...";
cd $BACKUP_PATH;
TIMESTAMP=`$NOW`;
mkdir $TIMESTAMP;
cd $TIMESTAMP;

# Exit backup script.
quit "Success! Exiting backup...";
