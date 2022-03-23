#!/usr/bin/env perl
use strict;
use warnings;

# Add lib
use FindBin;					# locate this script
use lib "$FindBin::Bin/lib";	# use the lib directory

use Mojolicious::Lite;
use Mojolicious::Plugin::Authentication;
use Mojolicious::Plugin::Config;
use Mojolicious::Sessions;
use Webrsnapshot::ConfigReader;
use Webrsnapshot::ConfigWriter;
use Webrsnapshot::CronHandler;
use Webrsnapshot::HostSummary;
use Webrsnapshot::LogReader;
use Webrsnapshot::SystemInfo;


my $config				= plugin 'Config';
my $rs_config			= $config->{rs_config}? $config->{rs_config}: '/etc/rsnapshot.conf';
my $default_template	= $config->{template}? $config->{template}:'default';

plugin 'authentication', {
	autoload_user => 0,
	load_user => sub {
		my ($app, $uid) = @_;
		return
		{
			'username' => $config->{rootuser},
			'password' => $config->{rootpass},
		} 
		if ($uid eq 'userid');
			return undef;
		},
	validate_user => sub {
		my $self	= shift;
		my $user	= shift || '';
		my $pass	= shift || '';

		return 'userid' if($user eq $config->{rootuser} && $pass eq $config->{rootpass});
		return undef;
	},
};

# Build the Main Menu
sub mainMenu
{
	my %menuHash = (
		home => (
			entry	=> "Home",
			link	=> "/"
		),
		hostsummary => (
			entry	=> "Host Summary",
			link	=> "/hostsummary"
		),
		config => (
			entry	=> "Rsnapshot Config",
			link	=> "/config"
		),
		log => (
			entry	=> "Rsnapshot Log",
			link	=> "/log"
		),
		cronjobs => (
			entry	=> "Cronjobs",
			link	=> "/cron"
		)
	);
	return %menuHash;
};

get '/' => sub {
	my $self = shift;

	my $username = $self->session( 'username' )?$self->session( 'username' ):"";
	my $password = $self->session( 'password' )?$self->session( 'password' ):"";
	if ( $self->authenticate( $username, $password ) )
	{
		eval
		{
			# User defined template
			$self->stash( default_template	=> $default_template );
			$self->stash( rs_configfile		=> $rs_config);
			my $parser = new ConfigReader($rs_config);
			$self->stash( rs_root_dir		=> $parser->getSnapshotRoot());
			# Get info about the file system
			my @partition = SystemInfo->getPartitionInfo( $rs_config );
			$self->stash( partitionInfoPart	=> $partition[0]);
			$self->stash( partitionInfoSize	=> $partition[1]);
			$self->stash( partitionInfoUsed	=> $partition[2]);
			$self->stash( partitionInfoFree	=> $partition[3]);
			$self->stash( partitionInfoPerc	=> $partition[4]);
			$self->stash( partitionInfoMP	=> $partition[5]);
			$self->render('index');
		};
		# Error handling
		if ( $@ ) {
			$self->stash(error_message=>"$@");
			$self->render('exception');
		}
	} else {
		$self->redirect_to('/login');
	}
};

get '/login' => sub {
	my $self = shift;

	my $username = $self->session('username')?$self->session('username'):"";
	my $password = $self->session('password')?$self->session('password'):"";
	if ( $self->authenticate( $username, $password ) ) {
		$self->redirect_to('/');
	} else {
		# User defined template
		$self->stash( default_template => $default_template);
		$self->render('login');
	}
};

post '/login' => sub {
	my $self = shift;

	# Filter Post data
	my $username = $self->req->param('username');
	my $password = $self->req->param('password');
	if ( $self->authenticate( $username, $password ) ) {
		# User defined template
		$self->stash( default_template => $default_template );
		# And save as session data
		$self->session(username => $username);
		$self->session(password => $password);
		$self->redirect_to('/');
	} else {
		$self->flash( login_failed => "Incorrect username or password.");
		$self->redirect_to('/login');
	}
};

# Handle any logout request
any '/logout' => sub {
	my $self = shift;
	$self->session(username => "");
	$self->session(password => "");
	$self->redirect_to('/login');
};

# Show Hosts Summary
get '/hosts' => sub {
	my $self = shift;
	my $username = $self->session('username')?$self->session('username'):"";
	my $password = $self->session('password')?$self->session('password'):"";
	if ( $self->authenticate( $username, $password ) ) {
		eval {
			# User defined template
			$self->stash( default_template	=> $default_template );
			$self->stash( hosts				=> [ Webrsnapshot::getHostNames($rs_config) ]);
			$self->stash( last_bkp			=> [ HostSummary::getAllLastBackupTimes($rs_config) ]);

			$self->render('hostsummary');
		};
	} else {
		$self->redirect_to('/login');
	}
};

# Show Hosts Summary
get '/host' => sub {
	my $self = shift;
	my $host = $self->param('h');
	my $username = $self->session('username')?$self->session('username'):"";
	my $password = $self->session('password')?$self->session('password'):"";
	if ( $self->authenticate( $username, $password ) ) {
		eval {
			# URL Param
			$self->stash( host => $host );
			# User defined template
			$self->stash( default_template	=> $default_template );
			# Create object from the Config File
			my $parser = new ConfigReader($rs_config);
			# Get a server list from rsnapshot.conf
			$self->stash(rootdir			=> [ $parser->getSnapshotRoot() ]);
			$parser->DESTROY();
			# Host Summary
			$self->stash(retain_dirs		=> [ HostSummary::getBackupDirectories($rs_config, $host) ]);

			$self->render('host');
		};
	} else {
		$self->redirect_to('/login');
	}
};

# And write the log file here.
get '/log' => sub {
	my $self = shift;
	my $username = $self->session('username')?$self->session('username'):"";
	my $password = $self->session('password')?$self->session('password'):"";
	if ( $self->authenticate( $username, $password ) ) {
		eval {
			# User defined template
			$self->stash( default_template	=> $default_template );
			$self->stash( log_content		=> LogReader->getContent(
												$config->{loglines},
												$config->{rs_config}) );
			$self->render('log');
		};
	} else {
		$self->redirect_to('/login');
	}
};

# Get crontab content for rsnapshot
get '/cron' => sub {
	my $self = shift;
	my $username = $self->session('username')?$self->session('username'):"";
	my $password = $self->session('password')?$self->session('password'):"";
	if ( $self->authenticate( $username, $password ) ) {
		eval {
			# User defined template
			$self->stash( default_template	=> $default_template );
			$self->stash( retains			=> [ CronHandler::getCronContent($rs_config)  ]);
			$self->stash( retainnames		=> [ Webrsnapshot::getRetainings($rs_config) ]);
			$self->stash( rs_config			=> $rs_config );

			$self->render('cron');
		};
	} else {
		$self->redirect_to('/login');
	}
};

# Write Crontab file
post '/cron' => sub {
	my $self = shift;

	my $username = $self->session('username')?$self->session('username'):"";
	my $password = $self->session('password')?$self->session('password'):"";

	if ( $self->authenticate( $username, $password ) ) {
		my @cronjobs	= ();
		my $cron_count	= $self->param('newcron');
		my $cron_email	= $self->param('cron_email');
		my $email_dsbl	= $self->param('cron_disabled')?$self->param('cron_disabled'):"off";

		if ( $email_dsbl eq "on" ) { $cronjobs[0] = "#MAILTO=\"".$cron_email."\""; }
		else { $cronjobs[0] = "MAILTO=\"".$cron_email."\""; }

		for (my $k=1; $k<$cron_count; $k++) {
			$cronjobs[$k] = $self->param('cronjob_'.$k);
		}

		my $saveResult = "";

		# And send everything to the CronHandler to save
		$saveResult = CronHandler::writeCronContent(
			scalar @cronjobs,
			@cronjobs? @cronjobs : (""),
		);

		# 0 - Ok
		# -1 - Error
		# If returns diferent then 0, then we have a problem
		if ($saveResult != 0) {
			$self->flash(message_text=>"$!");
		} else {
			$self->flash(message_text=>"Cron sucessfully saved.");
		}
		$self->flash(saved=>$saveResult);

		$self->redirect_to('/cron');
	} else {
		$self->render('/login');
	}
};

# Write configuration file
post '/config' => sub {
	my $self = shift;
	my $username = $self->session('username')?$self->session('username'):"";
	my $password = $self->session('password')?$self->session('password'):"";

	if ( $self->authenticate( $username, $password ) ) {
		# Include loop to get all include patterns from the post data
		my @include = ();
		my $include_count = $self->param('include_count');
		for (my $c=0; $c<$include_count;$c++ ) {
			my $i=0;
			while ( $self->param('include_'.$c) ) {
				$include[$i++] = $self->param('include_'.$c++);
			}
		}

		# Exclude loop to get all exclude patterns from the post data
		my @exclude = ();
		my $exclude_count = $self->param('exclude_count');
		for (my $c=0; $c<$exclude_count;$c++ ) {
			my $i=0;
			while ( $self->param('exclude_'.$c) ) {
				$exclude[$i++] = $self->param('exclude_'.$c++);
			}
		}

		# Servers loop to get all configured server lines from the post data
		my @servers = ();
		my $servers_count = $self->param('servers_count');
		my $count = 0;
		my $servers_line_count = 0;
		for (my $c=0; $c<$servers_count;$c++) {
			my $server_label = $self->param('server_label_'.$c);
			# If server_label is defined, we have valid server
			if (defined $server_label) {
				my $server_dir_count = $self->param('server_'.$c.'_dircount');
				for (my $i=0; $i<$server_dir_count; $i++) {
					my $server_dir = $self->param('server_'.$c.'_dir_'.$i.'_dir');
					# If the directory String is empty, we don't have it anymore and
					# this line must not be recorded
					if (defined $server_dir ne "") {
						my $server_dir_args = $self->param('server_'.$c.'_dir_'.$i.'_args')?
							"\t\t".$self->param('server_'.$c.'_dir_'.$i.'_args') : "";
						$servers[$servers_line_count++] =
							$self->param('server_'.$c.'_dir_'.$i.'_dir')."\t\t".$server_label."/".$server_dir_args;
					}
				}
			}
		}

		# backup_script loop to get all configured scripts from the post data
		my @scripts = ();
		my $scripts_count_postdata = $self->param('bkp_script_count');
		my $scripts_count = 0;
		for (my $c=0; $c<$scripts_count_postdata; $c++) {
			my $scriptname = $self->param('bkp_script_'.$c.'_script');
 			if ($scriptname) {
				$scripts[$scripts_count++] = $scriptname."\t\t".$self->param('bkp_script_'.$c.'_target');
			}
		}

		# Retain loop to get all configured intervals from the post data
		my @retain = ();
		my $retain_count_postdata = $self->param('retain_count');
		printf ("[%s] Retain post count: $retain_count_postdata\n",scalar localtime);
		my $retain_count = 0;
		for (my $r=0; $r<$retain_count_postdata; $r++) {
			my $retain_name = $self->param('retain_'.$r.'_name');
			if ($retain_name) {
				$retain[$retain_count++] = $retain_name."\t\t".$self->param('retain_'.$r.'_count');
			}
		}

		my @saveResult = {};

		# And send everything to the ConfigWriter
		@saveResult = ConfigWriter::saveConfig(
			# Extra Parameter
			scalar @include,		# 00
			scalar @exclude,		# 01
			$servers_line_count,	# 02
			$scripts_count,			# 03
			$rs_config,				# 04
			scalar @retain,			# 05
			# Tab - Root
			$self->param('config_version'),
			$self->param('snapshot_root' ),
			$self->param('include_conf' ),
			$self->param('no_create_root')?			$self->param('no_create_root')			: "off",
			# Tab - Commands
			$self->param('cmd_cp')?					$self->param('cmd_cp')					: "",
			$self->param('cmd_rm')?					$self->param('cmd_rm')					: "",
			$self->param('cmd_rsync'),
			$self->param('cmd_ssh')?				$self->param('cmd_ssh')					: "",
			$self->param('cmd_logger')?				$self->param('cmd_logger')				: "",
			$self->param('cmd_du')?					$self->param('cmd_du')					: "",
			$self->param('cmd_rsnapshot_diff')?		$self->param('cmd_rsnapshot_diff')		: "",
			$self->param('cmd_preexec')?			$self->param('cmd_preexec')				: "",
			$self->param('cmd_postexec')?			$self->param('cmd_postexec')			: "",
			# Tab - LVM Config
			$self->param('linux_lvm_cmd_lvcreate')?	$self->param('linux_lvm_cmd_lvcreate')	: "",
			$self->param('linux_lvm_cmd_lvremove')?	$self->param('linux_lvm_cmd_lvremove')	: "",
			$self->param('linux_lvm_cmd_mount')?	$self->param('linux_lvm_cmd_mount')		: "",
			$self->param('linux_lvm_cmd_umount')?	$self->param('linux_lvm_cmd_umount')	: "",
			$self->param('linux_lvm_snapshotsize')?	$self->param('linux_lvm_snapshotsize')	: "",
			$self->param('linux_lvm_snapshotname')?	$self->param('linux_lvm_snapshotname')	: "",
			$self->param('linux_lvm_vgpath')?		$self->param('linux_lvm_vgpath')		: "",
			$self->param('linux_lvm_mountpath')?	$self->param('linux_lvm_mountpath')		: "",
			# Tab - Global Config
			$self->param('verbose')?				$self->param('verbose')					: "",
			$self->param('loglevel')?				$self->param('loglevel')				: "",
			$self->param('logfile')?				$self->param('logfile')					: "",
			$self->param('lockfile')?				$self->param('lockfile')				: "",
			$self->param('stop_on_stale_lockfile')?	$self->param('stop_on_stale_lockfile')	: "off",
			$self->param('rsync_short_args')?		$self->param('rsync_short_args')		: "",
			$self->param('rsync_long_args')?		$self->param('rsync_long_args')			: "",
			$self->param('ssh_args')?				$self->param('ssh_args')				: "",
			$self->param('du_args')?				$self->param('du_args')					: "",
			$self->param('one_fs')?					$self->param('one_fs')					: "off",
			$self->param('link_dest')?				$self->param('link_dest')				: "off",
			$self->param('sync_first')?				$self->param('sync_first')				: "off",
			$self->param('use_lazy_deletes')?		$self->param('use_lazy_deletes')		: "off",
			$self->param('rsync_numtries')?			$self->param('rsync_numtries')			: "",
			# Tab - Backup Intervals
			@retain? @retain : (""),
			# Tab - Include/Exclude
			$self->param('include_file')? $self->param('include_file') : "",
			$self->param('exclude_file')? $self->param('exclude_file') : "",
			@include? @include : (""),
			@exclude? @exclude : (""),
			# Tab - Servers
			@servers? @servers : (""),
			# Tab - Scripts
			@scripts? @scripts : (""),
		);

		# Shrink the message size to not get oversized Cookies
		# Cookie "mojolicious" is bigger than 4096 bytes.
		my $savelinescount = scalar @saveResult;
		while ($savelinescount > 29) {
			my $lastLine = pop(@saveResult);
			pop(@saveResult);
			push(@saveResult, $lastLine);
			$savelinescount = scalar @saveResult;
		}

		# 0 - Ok
		# 1 - warning but successfull save
		# 2 - error in the rsnapshot.conf file
		# 3 - error while copying the rsnapshot file
		# If returns 0, then we have successfull save
		$self->flash(saved=>$saveResult[-1]);
		if ($saveResult[-1] eq "0") {
			$self->flash(message_text=>"Config sucessfully saved.");
		} else {
			splice(@saveResult,-1,1);
			$self->flash(message_text=>"@saveResult");
		}

		$self->redirect_to('/config');
	} else {
		$self->render('login');
	}
};

# Load Config
get '/config' => sub {
	my $self = shift;
	my $username = $self->session('username')?$self->session('username'):"";
	my $password = $self->session('password')?$self->session('password'):"";

	if ( $self->authenticate( $username, $password ) ) {
		# User defined template
		$self->stash( default_template	=> $default_template );
		# Create object from the Config File
		my $parser = new ConfigReader($rs_config);
		# Tab - Root
		$self->stash(config_version	=> $parser->getConfigVersion());
		$self->stash(snapshot_root	=> $parser->getSnapshotRoot());
		$self->stash(include_conf	=> $parser->getIncludeConf());
		$self->stash(no_create_root	=> $parser->getNoCreateRoot());
		# Tab - Commands
		$self->stash(cmd_cp				=> $parser->getCmCp());
		$self->stash(cmd_rm				=> $parser->getCmRm());
		$self->stash(cmd_rsync			=> $parser->getCmRsync());
		$self->stash(cmd_ssh			=> $parser->getCmSsh());
		$self->stash(cmd_logger			=> $parser->getCmLogger());
		$self->stash(cmd_du				=> $parser->getCmDu());
		$self->stash(cmd_rsnapshot_diff	=> $parser->getCmDiff());
		$self->stash(cmd_preexec		=> $parser->getPreExec());
		$self->stash(cmd_postexec		=> $parser->getPostExec());
		# Tab - LVM Config
		$self->stash(linux_lvm_cmd_lvcreate	=> $parser->getLinuxLvmCmdLvcreate());
		$self->stash(linux_lvm_cmd_lvremove	=> $parser->getLinuxLvmCmdLvremove());
		$self->stash(linux_lvm_cmd_mount	=> $parser->getLinuxLvmCmdMount());
		$self->stash(linux_lvm_cmd_umount	=> $parser->getLinuxLvmCmdUmount());
		$self->stash(linux_lvm_snapshotsize	=> $parser->getLinuxLvmSnapshotsize());
		$self->stash(linux_lvm_snapshotname	=> $parser->getLinuxLvmSnapshotname());
		$self->stash(linux_lvm_vgpath		=> $parser->getLinuxLvmVgpath());
		$self->stash(linux_lvm_mountpath	=> $parser->getLinuxLvmMountpath());
		# Tab - Global Config
		$self->stash(verbose				=> $parser->getVerbose());
		$self->stash(loglevel				=> $parser->getLogLevel());
		$self->stash(logfile				=> $parser->getLogFile());
		$self->stash(lockfile				=> $parser->getLockFile());
		$self->stash(stop_on_stale_lockfile	=> $parser->getStopOnStaleLockfile());
		$self->stash(rsync_short_args		=> $parser->getRsyncShortArgs());
		$self->stash(rsync_long_args		=> $parser->getRsyncLongArgs());
		$self->stash(ssh_args				=> $parser->getSshArgs());
		$self->stash(du_args				=> $parser->getDuArgs());
		$self->stash(one_fs					=> $parser->getOneFs());
		$self->stash(link_dest				=> $parser->getLinkDest());
		$self->stash(sync_first				=> $parser->getSyncFirst());
		$self->stash(use_lazy_deletes		=> $parser->getUseLazyDeletes());
		$self->stash(rsync_numtries			=> $parser->getRsyncNumtries());
		# Tab - Backup Intervals
		$self->stash(retain					=> [ $parser->getRetains()]);
		# Tab - Include/Exclude
		$self->stash(include_file	=> $parser->getIncludeFile());
		$self->stash(exclude_file	=> $parser->getExcludeFile());
		$self->stash(include		=> [ $parser->getInclude() ]);
		$self->stash(exclude		=> [ $parser->getExclude() ]);
		# Tab - Servers
		$self->stash(backup_servers	=> [ $parser->getServers() ]);
		# Tab - Scripts
		$self->stash(backup_scripts	=> [ $parser->getScripts() ]);

		# Object have to be destroyed, to not show the config from the first read
		$parser->DESTROY();

		# And render the web interface
		$self->render('config');
	} else {
		$self->render('login');
	}
};

app->secrets([$config->{appsecret}]);
app->start;