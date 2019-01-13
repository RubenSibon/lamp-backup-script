##
# Functions
##

# Log to file and/or terminal.
# - First parameter is the message to log;
# - Second parameter is the message type and can be empty
#   or is one of "info", "success", "warn" or "error".
function log {
  local MSG=$1
  local TYPE=$2
  local TIMESTAMP=`date`;

  # If no log type is passed-in, assume it is "info".
  if [ ! $2 ]; then
    local TYPE=info;
  fi

  local LOG_TYPE=$TYPE;

  # Color for each log type.
  # @todo Convert into loop, switch or if else statement.
  if [ "$TYPE" = "info" ]; then
    local LOG_COLOR="${BLUE}";
  fi

  if [ "$TYPE" = "success" ]; then
    local LOG_COLOR="${GREEN}";
  fi
  
  if [ "$TYPE" = "warn" ]; then
    local LOG_COLOR="${ORANGE}";
  fi

  if [ "$TYPE" = "error" ]; then
    local LOG_COLOR="${RED}";
  fi

  local LOG_MSG="[${LOG_COLOR}$LOG_TYPE${NC}]  $MSG";

  # Make new backup directory if it does not exist.
  if [ $( pwd ) != "$BACKUP_PATH" ]; then
    cd $BASE_DIR

    if [ ! -d "$BACKUP_DIR" ]; then
      makeBackupDir $BACKUP_DIR;
    fi

    cd $BACKUP_PATH;
  fi

  # Make log file if it does not exist.
  if [ ! -f "$BACKUP_PATH/$LOG_BACKUP" ]; then
    makeFile $LOG_BACKUP;
  fi

  # Log to log file.
  printf "$TIMESTAMP  $LOG_MSG\n" >> $BACKUP_PATH/$LOG_BACKUP;

  # Log success, warnings and errors to terminal (only for debugging).
  if [ $LOG_TO_CONSOLE > 0 ]; then
    if [ "$TYPE" = "warn" ] || [ "$TYPE" = "error" ] || [ "$TYPE" = "success" ]; then
      printf "$LOG_MSG\n";
    fi
  fi
}

# Quit the program.
function quit {
  log "$1" "$2";
  exit;
}

# On fail log and print error message and call the quit function.
function fail {
  log $1 'error';
  quit;
}

# Make a directory.
function makeBackupDir {
  if [ ! -d "$1" ]; then
    cd $BASE_DIR;
    mkdir $1;
    cd $1;

    if [ $LOG_TO_CONSOLE > 0 ]; then
      printf "Directory \"$BASE_DIR$1\" not found.\n";
    fi

    log "Make \"$1/\" in \"$BASE_DIR\"." "info";
  fi
}

# Make a file.
function makeFile {
  if [ ! -f "$1" ]; then
    touch $1;

    if [ $LOG_TO_CONSOLE > 0 ]; then
      printf "File \"$1\" not found.\n";
    fi

    log "Make \"$1\" in \"$BACKUP_PATH\"." "info";
  fi
}

# Check what type of site we have. Can be one of:
#   1) "default" - Plain HTML site or unknown CMS;
#   2) "drupal" - A Drupal site with a local Drush;
#   3) "grav" - A Grav site with bin/gpm;
#   4) "wordpress" - A WordPress site with wp-cli.
# function checkSiteType {
#   # Check each vhost webroot and test in what category it should go.
#   # Add each webroot directory and sitename to a seperate array.
#   # Pass these lists to the appropriate backup scripts.
# }
