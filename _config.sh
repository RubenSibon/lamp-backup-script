##
# Global config
##

# Basic
BASE_DIR="/opt/";
BACKUP_DIR="site-backups";
BACKUP_PATH="$BASE_DIR$BACKUP_DIR";
NOW="date +%Y%m%d%H%M%S";
LOG_BACKUP="backup.log";
LOG_VHOSTS="vhosts.log";

# Webroots
WEBROOT="/var/www/sites/";

# Apache
HOSTS="/etc/hosts";
VHOSTS_PATH="/etc/apache2/sites-enabled/";
PATTERN="DocumentRoot";

# MySQL
DBUSER="root";
DBHOST="localhost";
DEFAULTCHARSET="utf8";

# Binaries
DATE=/bin/date;
GREP=/bin/grep;
GZIP=/bin/gzip;
MK=/bin/mkdir;
MYSQL=/usr/bin/mysql;
MYSQLDUMP=/usr/bin/mysqldump;
REMOVE=/bin/rm;

# Text colours
RED='\033[0;31m';
ORANGE='\033[0;33m';
BLUE='\033[0;34m';
GREEN='\033[0;32m';
NC='\033[0m';

# Options
# 0 = off
# 1 = on
LOG_TO_CONSOLE=0
