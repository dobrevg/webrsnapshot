# [Webrsnapshot v0.6](https://github.com/dobrevg/webrsnapshot)
============

Webrsnapshot is web based graphical interface for editing the configuration file of rsnapshot via browser. This software is still in development. Please make a backup of your rnsapshot configuration file `/etc/rsnapshot.conf` before using Webrsnapshot. At this point not all features are implemented and only essential options are enabled. You can find a list with the missing options in the TODO file provided with this installation.

## Warning
============

Backuping servers supports at this time only root@my-target-server.com option. If you are using something like rsync://my-target-server.org or my-user@my-target-server.com you have to edit the server settings after adding a new server.


## Quick start
============ 

* Download [Webrsnapshot](https://github.com/dobrevg/webrsnapshot) whenever you want `git clone https://github.com/dobrevg/webrsnapshot.git`
* Copy the config file and configure it `cp webrsnapshot.sample.conf webrsnapshot.conf`
* Run `./bin/appStart.sh` to start the server (see the requirements below)
* Run `./bin/appStop.sh` to stop the server
* Access the application via http(s)://mySecretIP:8080
* For development run `./bin/development.pl`


## Requirements
============ 

* /etc/rsnapshot.conf have to be readable and writable for the user running this web application
* rsnapshot log file have to be readabe for for the user running this web application
* perl-IO-Socket-SSL 1.75 or better (optional) if you plan to use HTTPS


## Bug tracker
============

Have a bug or a feature request? Please read first the [Issue Guidelines](https://github.com/necolas/issue-guidelines), written by [Nicolas Gallagher](https://github.com/necolas/). Before opening any issue, please search for existing issues. Open a new issue [here](https://github.com/dobrevg/webrsnapshot/issues).


## Copyright and license
============

Webrsnapshot - Web interface for the backup tool rsnapshot.
Copyright (C) 2013  Georgi Dobrev

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License 
along with this program.  If not, see <http://www.gnu.org/licenses/>.

