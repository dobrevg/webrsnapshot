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
use Webrsnapshot::ConfigHandler;
use Webrsnapshot::CronHandler;
use Webrsnapshot::HostSummary;
use Webrsnapshot::LogReader;
use Webrsnapshot::SystemInfo;

my $config				= plugin 'Config';
my $rs_config			= $config->{rs_config}? $config->{rs_config}: '/etc/rsnapshot.conf';
my $rs_cron				= $config->{rs_cron}? 	$config->{rs_cron}: '/etc/cron.d/rsnapshot';
my $default_template	= $config->{template}? 	$config->{template}:'default';

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
			$self->stash( retains			=> [ CronHandler::getCronContent($rs_config, $rs_cron) ]);
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
		my $email_dsbl	= $self->param('email_disabled')?$self->param('email_disabled'):"off";

		if ( $email_dsbl eq "on" ) { $cronjobs[0] = "#MAILTO=\"".$cron_email."\""; }
		else { $cronjobs[0] = "MAILTO=\"".$cron_email."\""; }

		for (my $k=1; $k<$cron_count; $k++){
			my $cron_dsbl = $self->param('cron_disabled_'.$k)?$self->param('cron_disabled_'.$k):"off";
			if ( $cron_dsbl eq "on" ) { $cronjobs[$k] = "#".$self->param('cronjob_'.$k); }
			else { $cronjobs[$k] = $self->param('cronjob_'.$k); }
		}

		my @saveResult = ();

		# And send everything to the CronHandler to save
		@saveResult = CronHandler::writeCronContent(
			$rs_cron,
			@cronjobs,
		);

		# 0 - Ok
		# 1 - error in the rsnapshot cron file
		# 3 - error while copying the rsnapshot file
		# If returns diferent then 0, then we have a problem
		$self->flash(saved=>$saveResult[-1]);
		if ($saveResult[-1] eq "0") {
			$self->flash(message_text=>"Cron sucessfully saved.");
		} else {
			splice(@saveResult,-1,1);
			$self->flash(message_text=>"@saveResult");
		}

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
		my @backup  = ();
		my @retain  = ();
		my @include = ();
		my @exclude = ();
		my @backup_exec   = ();
		my @backup_script = ();

		# Get all post variables
		my $configparams = $self->req->params->to_hash;
		#print join("\n",sort keys %$configparams),"\n";
		#print("configparams: ".$configparams->{'config_version'}."\n");

		# Iterate over all keys and extract the multiline entries
		foreach my $key (sort keys %$configparams) {
			# include
			if( rindex($key,'include-',0) == 0) {
				$include[substr($key, 8)+0] = $configparams->{$key};
			}

			# exclude
			if( rindex($key,'exclude-',0) == 0) {
				$exclude[substr($key, 8)+0] = $configparams->{$key};
			}

			# retain
			if( rindex($key,'retainname_',0) == 0) {
				my %retain_entry = ();
				$retain_entry{'name'}  = $configparams->{$key};
				$retain_entry{'count'} = $configparams->{'retaincount_'.(substr($key, 11)+0)};
				push( @retain, \%retain_entry );
			}

			# backup_script
			if( rindex($key,'backup_script_name_',0) == 0) {
				my %backup_script_entry = ();
				$backup_script_entry{'name'}   = $configparams->{$key};
				$backup_script_entry{'target'} = $configparams->{'backup_script_target_'.(substr($key, 19)+0)};
				push( @backup_script, \%backup_script_entry);
			}

			# backup_exec
			if( rindex($key,'backup_exec_command_',0) == 0) {
				my %backup_exec_entry = ();
				$backup_exec_entry{'command'}    = $configparams->{$key};
				$backup_exec_entry{'importance'} = $configparams->{'backup_exec_importance_'.(substr($key, 20)+0)};
				push( @backup_exec, \%backup_exec_entry);
			}

			# backup
			if( rindex($key,'hostname_',0) == 0) {
				my %backup_host = ();
				$backup_host{'hostname'} = substr($key, 9, index($key,"__")-9);
				# We continue analyse the param only if its a source
				my $sourcekey      = 'hostname_'.$backup_host{'hostname'}.'__source_';
				my $argumentskey   = 'hostname_'.$backup_host{'hostname'}.'__args_';
				my $hostnamelength = length($backup_host{'hostname'});
				if( rindex($key,$sourcekey,0) == 0 ) {
					$backup_host{'source'} = $configparams->{$sourcekey.(substr($key, 18 + $hostnamelength)+0)};
					$backup_host{'args'}   = $configparams->{$argumentskey.(substr($key, 18 + $hostnamelength)+0)};
					push( @backup, \%backup_host);
				}
			}
		}

		# Build config hash
		my %config = (
			# Root
			'config_version' => $self->param('config_version'),
			'snapshot_root'	 => $self->param('snapshot_root' ),
			'include_conf'	 => $self->param('include_conf' ),
			'no_create_root' => $self->param('no_create_root')?$self->param('no_create_root'):"off",
			'one_fs'		 => $self->param('one_fs')?$self->param('one_fs'):"off",
			# Commands
			'cmd_rsync' 		 => $self->param('cmd_rsync'),
			'cmd_cp'			 => $self->param('cmd_cp')?$self->param('cmd_cp'):"",
			'cmd_rm'			 => $self->param('cmd_rm')?$self->param('cmd_rm'):"",
			'cmd_ssh'			 => $self->param('cmd_ssh')?$self->param('cmd_ssh'):"",
			'cmd_logger'		 => $self->param('cmd_logger')?$self->param('cmd_logger'):"",
			'cmd_du'			 => $self->param('cmd_du')?$self->param('cmd_du'):"",
			'cmd_rsnapshot_diff' => $self->param('cmd_rsnapshot_diff')?$self->param('cmd_rsnapshot_diff'):"",
			'cmd_preexec'		 => $self->param('cmd_preexec')?$self->param('cmd_preexec'):"",
			'cmd_postexec'		 => $self->param('cmd_postexec')?$self->param('cmd_postexec'):"",
			# Tab - LVM Config
			'linux_lvm_cmd_lvcreate' => $self->param('linux_lvm_cmd_lvcreate')?$self->param('linux_lvm_cmd_lvcreate'):"",
			'linux_lvm_cmd_lvremove' => $self->param('linux_lvm_cmd_lvremove')?$self->param('linux_lvm_cmd_lvremove'):"",
			'linux_lvm_cmd_mount'	 => $self->param('linux_lvm_cmd_mount')?$self->param('linux_lvm_cmd_mount'):"",
			'linux_lvm_cmd_umount'	 => $self->param('linux_lvm_cmd_umount')?$self->param('linux_lvm_cmd_umount'):"",
			'linux_lvm_vgpath'		 => $self->param('linux_lvm_vgpath')?$self->param('linux_lvm_vgpath'):"",
			'linux_lvm_snapshotname' => $self->param('linux_lvm_snapshotname')?$self->param('linux_lvm_snapshotname'):"",
			'linux_lvm_snapshotsize' => $self->param('linux_lvm_snapshotsize')?$self->param('linux_lvm_snapshotsize'):"",
			'linux_lvm_mountpath'	 => $self->param('linux_lvm_mountpath')?$self->param('linux_lvm_mountpath'):"",
			# Global Config
			'rsync_numtries'		 => $self->param('rsync_numtries')?$self->param('rsync_numtries'):"",
			'verbose'				 => $self->param('verbose')?$self->param('verbose'):"",
			'loglevel'				 => $self->param('loglevel')?$self->param('loglevel'):"",
			'logfile'				 => $self->param('logfile')?$self->param('logfile'):"",
			'lockfile'				 => $self->param('lockfile')?$self->param('lockfile'):"",
			'rsync_short_args' 		 => $self->param('rsync_short_args')?$self->param('rsync_short_args'):"",
			'rsync_long_args'		 => $self->param('rsync_long_args')?$self->param('rsync_long_args'):"",
			'ssh_args'				 => $self->param('ssh_args')?$self->param('ssh_args'):"",
			'du_args'				 => $self->param('du_args')?$self->param('du_args'):"",
			'stop_on_stale_lockfile' => $self->param('stop_on_stale_lockfile')?$self->param('stop_on_stale_lockfile'):"off",
			'link_dest'				 => $self->param('link_dest')?$self->param('link_dest'):"off",
			'sync_first'			 => $self->param('sync_first')?$self->param('sync_first'):"off",
			'use_lazy_deletes'		 => $self->param('use_lazy_deletes')?$self->param('use_lazy_deletes'):"off",
			# Intervals
			'retain'		=> \@retain,
			# Include/Exclude
			'include_file' 	=> $self->param('include_file')?$self->param('include_file'):"",
			'exclude_file' 	=> $self->param('exclude_file')?$self->param('exclude_file'):"",
			'include'		=> \@include,
			'exclude'		=> \@exclude,
			# Backup / Hosts 
			'backup'		=> \@backup,
			# Scripts
			'backup_script'	=> \@backup_script,
			'backup_exec'	=> \@backup_exec,
		);

		# And send everything to the ConfigHandler::saveConfig
		my $saveResult = ConfigHandler::saveConfig(
			$rs_config,
			\%config,
		);

		$self->flash(saved=>$saveResult->{'exit_code'});
		$self->flash(message_text=>"$saveResult->{'message'}");

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

		# Get the current configuration from the config file
		my $config = ConfigHandler::readConfig($rs_config);

		# Root
		$self->stash(config_version	=> $config->{'config_version'});
		$self->stash(snapshot_root	=> $config->{'snapshot_root'});
		$self->stash(include_conf	=> $config->{'include_conf'});
		$self->stash(no_create_root	=> $config->{'no_create_root'});
		$self->stash(one_fs			=> $config->{'one_fs'});

		# Commands
		$self->stash(cmd_rsync			=> $config->{'cmd_rsync'});
		$self->stash(cmd_cp				=> $config->{'cmd_cp'});
		$self->stash(cmd_rm				=> $config->{'cmd_rm'});
		$self->stash(cmd_ssh			=> $config->{'cmd_ssh'});
		$self->stash(cmd_logger			=> $config->{'cmd_logger'});
		$self->stash(cmd_du				=> $config->{'cmd_du'});
		$self->stash(cmd_rsnapshot_diff	=> $config->{'cmd_rsnapshot_diff'});
		$self->stash(cmd_preexec		=> $config->{'cmd_preexec'});
		$self->stash(cmd_postexec		=> $config->{'cmd_postexec'});

		# LVM Config
		$self->stash(linux_lvm_cmd_lvcreate	=> $config->{'linux_lvm_cmd_lvcreate'});
		$self->stash(linux_lvm_cmd_lvremove	=> $config->{'linux_lvm_cmd_lvremove'});
		$self->stash(linux_lvm_cmd_mount	=> $config->{'linux_lvm_cmd_mount'});
		$self->stash(linux_lvm_cmd_umount	=> $config->{'linux_lvm_cmd_umount'});
		$self->stash(linux_lvm_vgpath		=> $config->{'linux_lvm_vgpath'});
		$self->stash(linux_lvm_snapshotname	=> $config->{'linux_lvm_snapshotname'});
		$self->stash(linux_lvm_snapshotsize	=> $config->{'linux_lvm_snapshotsize'});
		$self->stash(linux_lvm_mountpath	=> $config->{'linux_lvm_mountpath'});

		# Global Config
		$self->stash(rsync_numtries			=> $config->{'rsync_numtries'});
		$self->stash(verbose				=> $config->{'verbose'});
		$self->stash(loglevel				=> $config->{'loglevel'});
		$self->stash(logfile				=> $config->{'logfile'});
		$self->stash(lockfile				=> $config->{'lockfile'});
		$self->stash(rsync_short_args		=> $config->{'rsync_short_args'});
		$self->stash(rsync_long_args		=> $config->{'rsync_long_args'});
		$self->stash(ssh_args				=> $config->{'ssh_args'});
		$self->stash(du_args				=> $config->{'du_args'});
		$self->stash(stop_on_stale_lockfile	=> $config->{'stop_on_stale_lockfile'});
		$self->stash(link_dest				=> $config->{'link_dest'});
		$self->stash(sync_first				=> $config->{'sync_first'});
		$self->stash(use_lazy_deletes		=> $config->{'use_lazy_deletes'});
		
		# Intervals
		$self->stash(retains				=> $config->{'retain'});

		# Include/Exclude
		$self->stash(include_file	=> $config->{'include_file'});
		$self->stash(exclude_file	=> $config->{'exclude_file'});
		$self->stash(includes		=> $config->{'include'});
		$self->stash(excludes		=> $config->{'exclude'});

		# Hosts
		$self->stash(backups		=> $config->{'backup'});

		# Tab - Scripts
		$self->stash(backup_scripts	=> $config->{'backup_script'});
		$self->stash(backup_execs	=> $config->{'backup_exec'});

		# And render the web interface
		$self->render('config');
	} else {
		$self->render('login');
	}
};

app->secrets([$config->{appsecret}]);
app->start;
