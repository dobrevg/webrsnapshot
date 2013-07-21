package ConfigReader;
use strict;
use warnings;

my $configfile         = "";
# Root
my $config_version     = "";
my $snapshot_root      = "";
my $no_create_root     = "";
# Optional programs and scripts used
my $cmd_cp             = "";
my $cmd_rm	           = "";
my $cmd_rsync          = "";
my $cmd_ssh            = "";
my $cmd_logger         = "";
my $cmd_du             = "";
my $cmd_rsnapshot_diff = "";
my $cmd_preexec        = "";
my $cmd_postexec       = "";
# Global Options
my $verbose            = "";    # 1 - 5, def = 2
my $loglevel           = "";    # 1 - 5, def = 3 
my $logfile            = "";
my $lockfile           = "";
my $rsync_short_args   = "";
my $rsync_long_args    = "";
my $ssh_args           = "";
my $du_args            = "";
my $one_fs             = "";
my $link_dest          = "";
my $sync_first         = "";
my $use_lazy_deletes   = "";
my $rsync_numtries     = "";
# Backup Intervals
my $interval_hourly    = "";
my $interval_daily     = "";
my $interval_weekly    = "";
my $interval_monthly   = "";
# Includes
my $include_file       = "";
my $exclude_file       = "";
my @include            = "";    # Array
my $include_ptr        = 0 ;
my @exclude            = "";    # Array
my $exclude_ptr        = 0 ;
# Backups
my @backup_servers	   = "";    # Array
my $backup_servers_ptr = 0 ;
my @backup_scripts     = "";    # Array
my $backup_scripts_ptr = 0 ;


sub new
{
  my $this = {};             # Create an anonymouns hash, and #self points to it
  bless   $this;             # Connect the hash to the package
  $configfile = $_[1];

  printf ("[%s] Start reading config file: $configfile\n",scalar localtime);
  open (CONFIG, $configfile) || die $!;
  while (<CONFIG>)
  {
    #print ("Readed Line: $_");
    my $temp = "";
    next if /^#/;                   # Ignore every comment 
    chop;                           # Remove the new line character
    # and start parsing the config file
    # Tab 1: Root config
    if    ("$_" =~ /^config_version\t+(.*)/)     { $config_version     = $1; }
    elsif ("$_" =~ /^snapshot_root\t+(.*)/ )     { $snapshot_root      = $1; }
    elsif ("$_" =~ /^no_create_root\t+(.*)/)     { $no_create_root     = $1; }
    # Tab 2: Optional programs and scripts used
    elsif ("$_" =~ /^cmd_cp\t+(.*)/)             { $cmd_cp             = $1; }
    elsif ("$_" =~ /^cmd_rm\t+(.*)/)             { $cmd_rm             = $1; }
    elsif ("$_" =~ /^cmd_rsync\t+(.*)/)          { $cmd_rsync          = $1; }
    elsif ("$_" =~ /^cmd_ssh\t+(.*)/)            { $cmd_ssh            = $1; }
    elsif ("$_" =~ /^cmd_logger\t+(.*)/)         { $cmd_logger         = $1; }
    elsif ("$_" =~ /^cmd_du\t+(.*)/)             { $cmd_du             = $1; }
    elsif ("$_" =~ /^cmd_rsnapshot_diff\t+(.*)/) { $cmd_rsnapshot_diff = $1; }
    elsif ("$_" =~ /^cmd_preexec\t+(.*)/)        { $cmd_preexec        = $1; }
    elsif ("$_" =~ /^cmd_postexec\t+(.*)/)       { $cmd_postexec       = $1; }
    # Tab 3: Global configuration
    elsif ("$_" =~ /^verbose\t+(.*)/)            { $verbose            = $1; }
    elsif ("$_" =~ /^loglevel\t+(.*)/)           { $loglevel           = $1; }
    elsif ("$_" =~ /^logfile\t+(.*)/)            { $logfile            = $1; }
    elsif ("$_" =~ /^lockfile\t+(.*)/)           { $lockfile           = $1; }
    elsif ("$_" =~ /^rsync_short_args\t+(.*)/)   { $rsync_short_args   = $1; }
    elsif ("$_" =~ /^rsync_long_args\t+(.*)/)    { $rsync_long_args    = $1; }
    elsif ("$_" =~ /^ssh_args\t+(.*)/)           { $ssh_args           = $1; }
    elsif ("$_" =~ /^du_args\t+(.*)/)            { $du_args            = $1; }
    elsif ("$_" =~ /^one_fs\t+(.*)/)             { $one_fs             = $1; }
    elsif ("$_" =~ /^link_dest\t+(.*)/)          { $link_dest          = $1; }
    elsif ("$_" =~ /^sync_first\t+(.*)/)         { $sync_first         = $1; }
    elsif ("$_" =~ /^use_lazy_deletes\t+(.*)/)   { $use_lazy_deletes   = $1; }
    elsif ("$_" =~ /^rsync_numtries\t+(.*)/)     { $rsync_numtries     = $1; }
    # Tab 4: Backup intervals, OpenSuSE still uses interval
    # Let us support the old "interval" and the new "retain"
    elsif ("$_" =~ /^interval\t+hourly\t+(.*)/ ||
        "$_" =~ /^retain\t+hourly\t+(.*)/)   { $interval_hourly    = $1; }
    elsif ("$_" =~ /^interval\t+daily\t+(.*)/  ||
        "$_" =~ /^retain\t+daily\t+(.*)/)    { $interval_daily     = $1; }
    elsif ("$_" =~ /^interval\t+weekly\t+(.*)/ ||
        "$_" =~ /^retain\t+weekly\t+(.*)/)   { $interval_weekly    = $1; }
    elsif ("$_" =~ /^interval\t+monthly\t+(.*)/||
        "$_" =~ /^retain\t+monthly\t+(.*)/)  { $interval_monthly   = $1; }
    # Tab 5: Include und Exclude
    elsif ("$_" =~ /^include\t+(.*)/)            { $include[$include_ptr++] = $1; }
    elsif ("$_" =~ /^exclude\t+(.*)/)            { $exclude[$exclude_ptr++] = $1; }
    elsif ("$_" =~ /^include_file\t+(.*)/)       { $include_file            = $1; }
    elsif ("$_" =~ /^exclude_file\t+(.*)/)       { $exclude_file            = $1; }
    # Tab 6: Server config is complicated
    # Filter servers with extra arguments
    elsif ("$_" =~ /^backup\t+(.*[^\t+])\t+(.*?[^\t+])\t+(.*)/) {
      my @servers = ($1, $2, $3);
      $backup_servers[$backup_servers_ptr++] = (\@servers);
    }
    # And then the rest without arguments
    elsif ("$_" =~ /^backup\t+(.*?[^\t+])\t+(.*)/) 
    {
      my @servers = ($1, $2, "");
      $backup_servers[$backup_servers_ptr++] = (\@servers);
    }
    # Tab 7: Scripts have to be configured
    elsif ("$_" =~ /^backup_script\t+(.*?[^\t+])\t+(.*)/) 
    { 
      my @scripts = ($1, $2);
      $backup_scripts[$backup_scripts_ptr++] = (\@scripts);
    }
    else  { }    # Unknown Line. Don't know what to do now?
  }

  # And close the file	
  close CONFIG;
  # Clear the Array pointers for the next run 
  $include_ptr        = 0;
  $exclude_ptr        = 0;
  $backup_servers_ptr = 0;
  $backup_scripts_ptr = 0;
  return  $this;             # Return the reference to the hash
}

# Tab1
sub getConfigVersion  { return $config_version; }
sub getSnapshotRoot   { return $snapshot_root;  }
sub getNoCreateRoot   { return ($no_create_root ne 1) ? " ":"checked"; }
# Tab2
sub getCmCp           { return $cmd_cp;     }
sub getCmRm           { return $cmd_rm;     }
sub getCmRsync        { return $cmd_rsync;  }
sub getCmSsh          { return $cmd_ssh;    }
sub getCmLogger       { return $cmd_logger; }
sub getCmDu           { return $cmd_du;     }
sub getCmDiff         { return $cmd_rsnapshot_diff; }
sub getPreExec        { return $cmd_preexec;        }
sub getPostExec       { return $cmd_postexec;       }
#Tab 3
sub getVerbose        { return $verbose;  }
sub getLogLevel       { return $loglevel; }
sub getLogFile        { return $logfile;  }
sub getLockFile       { return $lockfile; }
sub getRsyncShortArgs { return $rsync_short_args; }
sub getRsyncLongArgs  { return $rsync_long_args;  }
sub getSshArgs        { return $ssh_args;         }
sub getDuArgs         { return $du_args;          }
sub getOneFs          { return ($one_fs ne 1)           ? " ":"checked"; }
sub getLinkDest       { return ($link_dest ne 1)        ? " ":"checked"; }
sub getSyncFirst      { return ($sync_first ne 1)       ? " ":"checked"; }
sub getUseLazyDeletes { return ($use_lazy_deletes ne 1) ? " ":"checked"; }
sub getRsyncNumtries  { return $rsync_numtries;    }
# Tab 4
sub getIntervalHourly  { return $interval_hourly;  }
sub getIntervalDaily   { return $interval_daily;   }
sub getIntervalWeekly  { return $interval_weekly;  }
sub getIntervalMonthly { return $interval_monthly; }
# Tab 5
sub getIncludeFile    { return $include_file; }
sub getExcludeFile    { return $exclude_file; }
sub getInclude        { return @include;      }
sub getExclude        { return @exclude;      }
# Tab 6
sub getServers        { return @backup_servers; }
# Tab 7 
sub getScripts        { return @backup_scripts; }

# And the Destructor
sub DESTROY {
  my $self = shift;

  # Reset all values   
  # Root
  $config_version     = "";
  $snapshot_root      = "";
  $no_create_root     = "";
  # Optional programs and scripts used
  $cmd_cp             = "";
  $cmd_rm	            = "";
  $cmd_rsync          = "";
  $cmd_ssh            = "";
  $cmd_logger         = "";
  $cmd_du             = "";
  $cmd_rsnapshot_diff = "";
  $cmd_preexec        = "";
  $cmd_postexec       = "";
  # Global Options
  $verbose            = "";    # 1 - 5, def = 2
  $loglevel           = "";    # 1 - 5, def = 3
  $logfile            = "";
  $lockfile           = "";
  $rsync_short_args   = "";
  $rsync_long_args    = "";
  $ssh_args           = "";
  $du_args            = "";
  $one_fs             = "";
  $link_dest          = "";
  $sync_first         = "";
  $use_lazy_deletes   = "";
  $rsync_numtries     = "";
  # Backup Intervals
  $interval_hourly    = "";
  $interval_daily     = "";
  $interval_weekly    = "";
  $interval_monthly   = "";
  # Includes
  $include_file       = "";
  $exclude_file       = "";
  @include            = "";    # Array
  $include_ptr        = 0 ;
  @exclude            = "";    # Array
  $exclude_ptr        = 0 ;
  # Backups
  @backup_servers     = "";    # Array
  $backup_servers_ptr = 0 ;
  @backup_scripts     = "";    # Array
  $backup_scripts_ptr = 0 ;

  # check for an overridden destructor...
  $self->SUPER::DESTROY if $self->can("SUPER::DESTROY");
  # now do your own thing before or after
}

1;