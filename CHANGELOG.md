Version 0.9
-----------

* [feature]     - Let user define the date and time format in hosts pages
* [change]      - Convert the app from Mojo-Lite to Mojolicious


Version 0.8
-----------

* [feature]     - Add backup_exec support
* [feature]     - Add example systemd and sysV scripts
* [feature]     - Add rsnapshot cron file to the conf
* [feature]     - Add option to disable each/all crons individually
* [change]      - Replace jQuery with Bootstrap 5
* [change]      - Add external lib dependencies as submodules
* [improvement] - Better exit message handle on save
* [improvement] - Web UI is responsible 


Version 0.7
-----------

* [improvement] - Add simple Host Summary
* [improvement] - Update to jQuery 3.2.1
* [improvement] - Update to jQuery UI 1.12.1
* [improvement] - Convert code to "4 spaces" tabs for better readability
* [feature]     - Add user defined backup intervals
* [feature]     - Add LVM support
* [feature]     - Add include_conf support
* [feature]     - Add stop_on_stale_lockfile support
* [change]      - Move libs to libs/Webrsnapshot



Version 0.6
-----------

* [improvement] - Add new server switched to jQuery UI Dialog
* [change]      - Change the jQuery UI theme to "start"
* [change]      - Add SSL as optional Connection Protocol
* [fix]         - Main menu entries.
* [fix]         - Add new server
* [fix]         - Fix bug while removing directory
* [fix]         - Add notification if the file can not be copied after the configtest


Version 0.5
-----------

* [feature] - Implement backup_scripts
* [fix]     - webrsnapshot.sample.conf defaults values
* [new]     - Show some system information (openSUSE,Debian,Solaris,FreeBSD,Fedora)
* [fix]     - Fix the Cookie size while saving(Cookie is bigger than 4096 bytes.)


Version 0.4
-----------

* [improvement] - Improved template<=>layout system
* [improvement] - login form moved to the template
* [improvement] - Add rsnapshot conf file to webrsnapshot configuration
* [improvement] - Server error notification
* [feature]     - Add config check before save.
* [new]         - CHANGELOG file added.
* [new]         - INSTALL file added.


Version 0.3
-----------

* [fix]         - catch errors while saving the rsnapshot config file
* [improvement] - switched to jQuery v2.0.3
* [feature]     - log reader implemented


Version 0.2
-----------

* [feature] - dependencies are included to the lib directory
* [feature] - credential authentication added.
* [feature] - configuration file added
* [feature] - start and stop scripts added


Version 0.1
-----------

* Initial Release
* [feature] - implemented config_version
* [feature] - implemented snapshot_root
* [feature] - implemented no_create_root
* [feature] - implemented cmd_cp
* [feature] - implemented cmd_rm
* [feature] - implemented config_version
* [feature] - implemented cmd_rsync
* [feature] - implemented cmd_ssh
* [feature] - implemented cmd_logger
* [feature] - implemented cmd_du
* [feature] - implemented cmd_rsnapshot_diff
* [feature] - implemented cmd_preexec
* [feature] - implemented cmd_postexec
* [feature] - implemented retain/include (partially)
* [feature] - implemented verbose
* [feature] - implemented loglevel
* [feature] - implemented logfile
* [feature] - implemented lockfile
* [feature] - implemented rsync_short_args
* [feature] - implemented rsync_long_args
* [feature] - implemented ssh_args
* [feature] - implemented du_args
* [feature] - implemented one_fs
* [feature] - implemented link_dest
* [feature] - implemented sync_first
* [feature] - implemented use_lazy_deletes
* [feature] - implemented rsync_numtries
* [feature] - implemented include_file
* [feature] - implemented exclude_file
* [feature] - implemented include
* [feature] - implemented exclude
* [feature] - implemented backup (partially)
* [feature] - jQuery v2.0.2 added
* [feature] - jQuery-UI v1.10.3 added
