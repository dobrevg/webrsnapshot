#!/usr/bin/env perl
use strict;
use warnings;

# Add lib
use FindBin;                     # locate this script
use lib "$FindBin::Bin/lib";     # use the lib directory

use ConfigReader;
use ConfigWriter;
use Mojolicious::Lite;
use Mojolicious::Plugin::Authentication;
use Mojolicious::Plugin::Config;
use Mojolicious::Sessions;

my $config = plugin 'Config';

plugin 'authentication', {
  autoload_user => 0,
  load_user => sub 
  {
    my ($app, $uid) = @_;
    return 
    {
      'username' => $config->{rootuser},
      'password' => $config->{rootpass},
      'name' => 'BackupAdministrator'
    } if ($uid eq 'userid');
    return undef;
  },
  validate_user => sub
  {
    my $self  = shift;
    my $user  = shift || '';
    my $pass  = shift || '';
#    my $extradata = shift || {};

    return 'userid' if($user eq $config->{rootuser} && $pass eq $config->{rootpass});
    return undef;
  },
};

get '/' => sub {
  my $self = shift;

  my $username = $self->session( 'username' )?$self->session( 'username' ):"";
  my $password = $self->session( 'password' )?$self->session( 'password' ):"";
  if ( $self->authenticate( $username, $password ) )
  {
    $self->render('index');
  }
  else
  {
    $self->redirect_to('/login');
  }
};

get '/login' => sub 
{
  my $self = shift;

  my $username = $self->session('username')?$self->session('username'):"";
  my $password = $self->session('password')?$self->session('password'):"";
  if ( $self->authenticate( $username, $password ) )
  {
     $self->redirect_to('/');
  }
  else
  {
    $self->render('login');
  }
};

post '/login' => sub { 
  my $self = shift;

  # Filter Post data
  my $username = $self->req->param('u');
  my $password = $self->req->param('p');
  if ( $self->authenticate( $username, $password ) )
  {
    # And save as session data
    $self->session(username => $username);
    $self->session(password => $password);
    $self->redirect_to('/');
  }
  else
  { # TODO: Show message for wrong pass
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

# Write confguration file
post '/config' => sub {
  my $self = shift;

  my $username = $self->session('username')?$self->session('username'):"";
  my $password = $self->session('password')?$self->session('password'):"";
  if ( $self->authenticate( $username, $password ) )
  {
    # Include loop to get all include patterns from the post data
    my @include = ();
    my $include_count = $self->param('include_count');
    for (my $c=0; $c<$include_count;$c++ )
    {
      my $i=0;
      while ( $self->param('include_'.$c) )
      {	
        $include[$i++] = $self->param('include_'.$c++);
      }
    }

    # Exclude loop to get all exclude patterns from the post data
    my @exclude = ();
    my $exclude_count = $self->param('exclude_count');
    for (my $c=0; $c<$exclude_count;$c++ )
    {
      my $i=0;
      while ( $self->param('exclude_'.$c) )
      {	
        $exclude[$i++] = $self->param('exclude_'.$c++);
      }
    }
  
    # Servers loop do get all configured server lines from the post data
    my @servers = ();
    my $servers_count = $self->param('servers_count');
    my $count = 0;
    my $servers_line_count = 0;
    for (my $c=0; $c<$servers_count;$c++)
    {
      my $server_label = $self->param('server_label_'.$c);
      # If server_label is defined, we have valid server
      if (defined $server_label)
      {
        my $server_dir_count = $self->param('server_'.$c.'_dircount');
        for (my $i=0; $i<$server_dir_count; $i++)
        {
          my $server_dir_args = $self->param('server_'.$c.'_dir_'.$i.'_args')?
            "\t\t".$self->param('server_'.$c.'_dir_'.$i.'_args') : ""; 
          $servers[$servers_line_count++] = 
          $self->param('server_'.$c.'_dir_'.$i.'_dir')."\t\t".$server_label."/".$server_dir_args;
        }
      }
    }
  
    # TODO
    # Scripts loop
    my @scripts = ();
    my $scripts_count = 0;
  
    # And send everything to the ConfigWriter
    eval {
      ConfigWriter::saveConfig(
        # Extra Parameter
        scalar @include,
        scalar @exclude,
        $servers_line_count,
        $scripts_count,
        # Tab 1 - Root	
        $self->param('config_version'),
        $self->param('snapshot_root' ),
        $self->param('no_create_root')?     $self->param('no_create_root') : "off",
        # Tab 2 - Commands
        $self->param('cmd_cp')?             $self->param('cmd_cp') : "",
        $self->param('cmd_rm')?             $self->param('cmd_rm') : "",
        $self->param('cmd_rsync'),
        $self->param('cmd_ssh')?            $self->param('cmd_ssh')            : "",
        $self->param('cmd_logger')?         $self->param('cmd_logger')         : "",
        $self->param('cmd_du')?             $self->param('cmd_du')             : "",
        $self->param('cmd_rsnapshot_diff')? $self->param('cmd_rsnapshot_diff') : "",
        $self->param('cmd_preexec')?        $self->param('cmd_preexec')        : "",
        $self->param('cmd_postexec')?       $self->param('cmd_postexec')       : "",
        # Tab 4 - Backup Intervals
        $self->param('retain_hourly')?      $self->param('retain_hourly')  : "",
        $self->param('retain_daily')?       $self->param('retain_daily')   : "",
        $self->param('retain_weekly')?      $self->param('retain_weekly')  : "",
        $self->param('retain_monthly')?     $self->param('retain_monthly') : "",
        # Tab 3 - Global Config
        $self->param('verbose')?          $self->param('verbose')          : "",
        $self->param('loglevel')?         $self->param('loglevel')         : "",
        $self->param('logfile')?          $self->param('logfile')          : "",
        $self->param('lockfile')?         $self->param('lockfile')         : "",
        $self->param('rsync_short_args')? $self->param('rsync_short_args') : "",
        $self->param('rsync_long_args')?  $self->param('rsync_long_args')  : "",
        $self->param('ssh_args')?         $self->param('ssh_args')         : "",
        $self->param('du_args')?          $self->param('du_args')          : "",
        $self->param('one_fs')?           $self->param('one_fs')           : "off",
        $self->param('link_dest')?        $self->param('link_dest')        : "off",
        $self->param('sync_first')?       $self->param('sync_first')       : "off",
        $self->param('use_lazy_deletes')? $self->param('use_lazy_deletes') : "off",
        $self->param('rsync_numtries')?   $self->param('rsync_numtries')   : "",
        # Tab 5 - Include/Exclude
        $self->param('include_file')? $self->param('include_file') : "",
        $self->param('exclude_file')? $self->param('exclude_file') : "",
        @include? @include : (""),
        @exclude? @exclude : (""),
        # Tab 6 - Servers
        @servers? @servers : (""),
        # Tab 7 - Scripts
        @scripts? @scripts : (""),
      );
    };

    $self->flash(saved=>'yes') if (!$@);
    if ($@)
    {
      $self->flash(saved=>'no');
      $self->flash(error_message=>$@)
    }
    $self->redirect_to('/config');
  }
  else
  {
    $self->render('login');
  }
};

# Load Config
get '/config' => sub {
  my $self = shift;

  my $username = $self->session('username')?$self->session('username'):"";
  my $password = $self->session('password')?$self->session('password'):"";
  if ( $self->authenticate( $username, $password ) )
  {
    # Create object from the Config File
    my $parser = new ConfigReader;
    # Tab 1 - Root
    $self->stash(config_version => $parser->getConfigVersion() );
    $self->stash(snapshot_root  => $parser->getSnapshotRoot()  );
    $self->stash(no_create_root => $parser->getNoCreateRoot()  );
    # Tab 2 - Commands
    $self->stash(cmd_cp             => $parser->getCmCp()     );
    $self->stash(cmd_rm             => $parser->getCmRm()     );
    $self->stash(cmd_rsync          => $parser->getCmRsync()  );
    $self->stash(cmd_ssh            => $parser->getCmSsh()    );
    $self->stash(cmd_logger         => $parser->getCmLogger() );
    $self->stash(cmd_du             => $parser->getCmDu()     );
    $self->stash(cmd_rsnapshot_diff => $parser->getCmDiff()   );
    $self->stash(cmd_preexec        => $parser->getPreExec()  );
    $self->stash(cmd_postexec       => $parser->getPostExec() );
    # Tab 3 - Global Config
    $self->stash(verbose          => $parser->getVerbose()        );
    $self->stash(loglevel         => $parser->getLogLevel()       );
    $self->stash(logfile          => $parser->getLogFile()        );
    $self->stash(lockfile         => $parser->getLockFile()       );
    $self->stash(rsync_short_args => $parser->getRsyncShortArgs() );
    $self->stash(rsync_long_args  => $parser->getRsyncLongArgs()  );
    $self->stash(ssh_args         => $parser->getSshArgs()        );
    $self->stash(du_args          => $parser->getDuArgs()         );
    $self->stash(one_fs           => $parser->getOneFs()          );
    $self->stash(link_dest        => $parser->getLinkDest()       );
    $self->stash(sync_first       => $parser->getSyncFirst()      );
    $self->stash(use_lazy_deletes => $parser->getUseLazyDeletes() );
    $self->stash(rsync_numtries   => $parser->getRsyncNumtries()  );
    # Tab 4 - Backup Intervals
    $self->stash(interval_hourly  => $parser->getIntervalHourly()  );
    $self->stash(interval_daily   => $parser->getIntervalDaily()   );
    $self->stash(interval_weekly  => $parser->getIntervalWeekly()  );
    $self->stash(interval_monthly => $parser->getIntervalMonthly() );
    # Tab 5 - Include/Exclude
    $self->stash(include_file => $parser->getIncludeFile() );
    $self->stash(exclude_file => $parser->getExcludeFile() );
    $self->stash(include      => [ $parser->getInclude()  ]);
    $self->stash(exclude      => [ $parser->getExclude()  ]);
    # Tab 6 - Servers
    $self->stash(backup_servers => [ $parser->getServers() ]);
    # Tab 7 - Scripts
    $self->stash(backup_scripts => [ $parser->getScripts() ]);
    # And render the web interface
    $self->render('config');
  
    # Object have to be destroyed, to not show the config from the first read
    $parser->DESTROY();
  }
  else
  {
    $self->render('login');
  }
};

app->secret($config->{appsecret});
app->start;