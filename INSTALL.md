# Install
================



## Quick install
----------------

* Clone Webrsnapshot git repo `git clone https://github.com/dobrevg/webrsnapshot.git`
* Copy the config file and configure it `cp config/webrsnapshot.example.yml config/webrsnapshot.yml`
* Install Mojolicious and the required modules. See the requirements below. 
* Edit and install the service: `cp contrib/webrsnapshot.service /etc/systemd/system/ && systemctl daemon-reload`
* Start the service: `service webrsnapshot start`
* Access the application via https://myServerIP:8080


## Quick update
----------------

* Just execute: `git pull` in the folder where webrsnapshot is installed
* Adjust config/webrsnapshot.yml for your needs (optional)
* Restart/Reload the application server


## Requirements
============ 

* rsnapshot.conf have to be readable and writable for the user running this web application
* rsnapshot log file have to be readable for the user running this web application
* cronjob file (f.e. /etc/cron.d/rsnapshot) file have to be readable and writable for the user running this web application
* Mojolicious Framework (required)
* Mojolicious::Plugin::Authentication (required)
* File::ReadBackwards (required)
* Crypt::PBKDF2 (required)
* perl-IO-Socket-SSL 1.75 or better (optional) if you plan to use HTTPS


## Create your own template
----------------

Webrsnapshot comes with default template developed by me and it is supposed to be functional(and not wow designed) at any committed revision. Feel free to create your own template. To create new template, just copy the existed default one and redesign it for your needs.

* copy the file `templates/layouts/default.html.ep` to `templates/layouts/My-New-Template-Name.html.ep`
* copy recursive the directory `public/default` to `public/My-New-Template-Name`
* change the template value in webrsnapshot.conf from default to `template  => 'My-New-Template-Name'`
* Edit everything in `templates/layouts/My-New-Template-Name.html.ep` and under `public/My-New-Template-Name`

I can not guarantee that custom templates will be compatible in a new versions of Webrsnapshot. So use it at your own risk.

## For developers and testers
----------------

If you want to start the application server as developer to get some output just run `morbo ./script/webrsnapshot`. Then you can access the server on port 3000 instead of 8080. The process doesn't goes in background and you can follow the output on the console. 
