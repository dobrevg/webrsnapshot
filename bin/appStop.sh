#!/bin/sh

SERVER_BIN="hypnotoad"
APP_BIN="../webrsnapshot.pl"


# Get script directory and go there
DIR="$(cd $(dirname $0) && pwd)
cd $DIR

# Test if we can read and execute hypnotoad file
test -e ${SERVER_BIN} || { echo "${SERVER_BIN}: does not exists."; exit 10; }
test -f ${SERVER_BIN} || { echo "${SERVER_BIN}: not regular file."; exit 11; }
test -x ${SERVER_BIN} || { echo "${SERVER_BIN}: is not executable."; exit 12; }

# And test if application file exist and can be executed
test -e ${APP_BIN}   || { echo "${APP_BIN}: does not exists."; exit 10; }
test -f ${APP_BIN}   || { echo "${APP_BIN}: not regular file."; exit 11; }
test -x ${APP_BIN}   || { echo "${APP_BIN}: is not executable."; exit 12; }

$SERVER_BIN -s $APP_BIN) 2&> /dev/null
