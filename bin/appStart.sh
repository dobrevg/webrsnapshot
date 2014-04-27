#!/bin/sh
#######################################################################
# This file is part of Webrsnapshot - The web interface for rsnapshot
# Copyright© (2013-2014) Georgi Dobrev (dobrev.g at gmail dot com)
#
# Webrsnapshot is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Webrsnapshot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################
SERVER_BIN="./hypnotoad"
APP_BIN="../webrsnapshot.pl"


# Get script directory and go there
DIR=$(cd $(dirname $0) && pwd)
cd $DIR

# Test if we can read and execute hypnotoad file
test -e ${SERVER_BIN} || { echo "${SERVER_BIN}: does not exists."; exit 10; }
test -f ${SERVER_BIN} || { echo "${SERVER_BIN}: not regular file."; exit 11; }
test -x ${SERVER_BIN} || { echo "${SERVER_BIN}: is not executable."; exit 12; }

# And test if application file exist and can be executed
test -e ${APP_BIN}   || { echo "${APP_BIN}: does not exists."; exit 10; }
test -f ${APP_BIN}   || { echo "${APP_BIN}: not regular file."; exit 11; }
test -x ${APP_BIN}   || { echo "${APP_BIN}: is not executable."; exit 12; }

${SERVER_BIN} ${APP_BIN}
exit 0
