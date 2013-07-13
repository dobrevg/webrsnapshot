# Install
================



## Quick install
----------------

* Download [Webrsnapshot](https://github.com/dobrevg/webrsnapshot) whenever you want
* Copy the config file and configure it `cp webrsnapshot.sample.conf webrsnapshot.conf`
* Run `./bin/appStart.sh` to start the server (see the requirements below)
* Run `./bin/appStop.sh` to stop the server
* Access the application via http://mySecretIP:8080
* For development run `./bin/development.pl`


## Create your own template
---------------- 

Webrsnapshot comes with default template developed by me and it is supposed to be functional(and not wow designed) at any committed revision. Feel free to create your own template. To create new template, just copy the existed default one and redesign it for your needs.

* copy the file `templates/layouts/default.html.ep` to `templates/layouts/My-New-Template-Name.html.ep`
* copy recursive the directory `public/default` to `public/My-New-Template-Name`
* change the template value in webrsnapshot.conf from default to `template  => 'My-New-Template-Name'`
* Edit everything in `templates/layouts/My-New-Template-Name.html.ep` and under `public/My-New-Template-Name`

I can not guarantee that custom templates will be compatible in a new versions of Webrsnapshot. So use it at your own risk.