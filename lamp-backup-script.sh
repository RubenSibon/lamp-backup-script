#!/bin/sh

# BACKUP WEBSITES ON A LAMP
#
# LAMP = Linux, Apache, MySQL/MariaDB, PHP server
#
# This script backs up the unique file directories and databases for each site found in Apache's enabled virtual hosts.
# If one or more sites has the cli tool of Drupal (drush), Grav (gpm) or WordPress (wp-cli) it will use the backup function of that tool.
#
# Author: Ruben J. Sibon (Webricolage)
# Mail: mail@webricolage.nl
#
# License: MIT

##
# Setup
##

# Root permissions are required.
if [ "$(whoami)" != "root" ]; then
  echo "Root privileges are required to run this, try running with sudo...";
  exit 2;
fi

# Include partials.
source ./_config.sh;
source ./_functions.sh;

# Initial log to console.
log "START NEW BACKUPS" "info";
log "Backup location: $BASE_DIR$BACKUP_DIR" "info";

# Go to backup root directory.
cd $BASE_DIR;

# Make new backup directory if it does not exist.
if [ ! -d "$BACKUP_DIR" ]; then
  makeBackupDir $BACKUP_DIR;
fi

cd $BACKUP_PATH;

if [ $LOG_TO_CONSOLE > 0 ]; then
  printf "Moving to backup dir: $( pwd )\n";
fi

##
# Collect webroots from vhosts
##

# Remove any pre-existing vhosts log.
if [ -f "$BACKUP_PATH/$LOG_VHOSTS" ]; then
  rm $BACKUP_PATH/$LOG_VHOSTS;
  rm $BACKUP_PATH/$LOG_VHOSTS.tmp;
fi

# Create temporary vhosts and webroots log.
makeFile $LOG_VHOSTS.tmp;

# Go to vhosts directory.
cd $VHOSTS_PATH;
shopt -s nullglob;

# Get the site name and webroot for each site in vhosts.
for f in *; do
  SITE=$( cat $f | sed -e "/ServerName.*/!d" | sed "s/[[:blank:]]//g" | sed "s/ServerName//" | sed "/^#/ d" );

  if [ ! $SITE ]; then
    continue
  fi

  SITE="${SITE}RANDOM$( cat $f | sed -e "/DocumentRoot.*/!d" | sed "s/[[:blank:]]//g" | sed "s/DocumentRoot//" | sed "/^#/ d" )";
  # cat $f | \
  #   sed -e "/ServerName.*/!d" | sed "s/[[:blank:]]//g" | sed "s/ServerName//" | sed '/^#/ d' >> $BACKUP_PATH/$LOG_VHOSTS.tmp;
  # cat $f | \
  #   sed -e "/DocumentRoot.*/!d" | sed "s/[[:blank:]]//g" | sed "s/DocumentRoot//" | sed '/^#/ d' >> $BACKUP_PATH/$LOG_VHOSTS.tmp;

  echo "$SITE" >> $BACKUP_PATH/$LOG_VHOSTS.tmp;
done

# Sort and clean vhosts and webroots and log them.
sort -u $BACKUP_PATH/$LOG_VHOSTS.tmp > $BACKUP_PATH/$LOG_VHOSTS;

# Go back to backup path and remove temporary vhosts log file.
cd $BACKUP_PATH;
rm $LOG_VHOSTS.tmp;

log "All site webroots can be found in \"${LOG_WEBROOTS}\"." "info";
log "All site names can be found in \"${LOG_VHOSTS}\"." "info";
log "Virtual hosts to be backed up:";

if [ $LOG_TO_CONSOLE > 0 ]; then
  cat $LOG_VHOSTS;
  cat $LOG_VHOSTS >> $LOG_BACKUP;
fi

# Add webroots to array.
readarray vhostArray < $LOG_VHOSTS;

##
# Backing up
##

# Move to backup directory and create timestamped folder.
log "Move to \"$BACKUP_PATH\" ...";
cd $BACKUP_PATH;
TIMESTAMP=`$NOW`;
mkdir $TIMESTAMP;
cd $BACKUP_PATH/$TIMESTAMP;

for v in ${vhostArray[@]}; do
  WEBNAME="$( echo $v | sed -e "/RANDOM.*/!d" | sed "s/[[:blank:]]//g" | sed "s/RANDOM.*//" )";

  if [ ! $WEBNAME ]; then
    continue
  fi

  log "Backing up \"${WEBNAME}\"" "info";
  # echo "Webname: ${WEBNAME}";

  mkdir $BACKUP_PATH/$TIMESTAMP/$WEBNAME;
  cd $BACKUP_PATH/$TIMESTAMP/$WEBNAME;

  WEBROOT=$( echo $v | sed -e "/RANDOM.*/!d" | sed "s/[[:blank:]]//g" | sed "s/^.*RANDOM//" );

  # echo "Webroot: ${WEBROOT}";
  echo $WEBROOT >> $WEBNAME.txt;

  # rsync -avzP $WEBROOT $BACKUP_PATH/$TIMESTAMP/$WEBNAME/
  rsync -avzP $WEBROOT $BACKUP_PATH/$TIMESTAMP/$WEBNAME/
done

cd $BACKUP_PATH;

log "Backup successful! Backups are located in \"${BACKUP_PATH}\"." "success";

# Exit backup script.
quit "Exit backup script..." "info";
