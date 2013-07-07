package ConfigWriter;
use strict;
use warnings;

my $configfile        = "/etc/rsnapshot.conf";
## Root
my @config_parameters =
(
  # Extra Parameter for multiply Lines below
  "include_count",         # 0
  "exclude_count",         # 1
  "server_count",          # 2
  "scrips_count",          # 3
  # Tab 1: Root config
  "config_version\t",      # 4
  "snapshot_root\t",       # 5
  "no_create_root\t",      # 6
  # Tab 2: Optional programs and scripts used
  "cmd_cp\t\t\t",          # 7
  "cmd_rm\t\t\t",          # 8
  "cmd_rsync\t\t",         # 9
  "cmd_ssh\t\t\t",         # 10
  "cmd_logger\t\t",        # 11
  "cmd_du\t\t\t",          # 12
  "cmd_rsnapshot_diff",    # 13
  "cmd_preexec",           # 14
  "cmd_postexec",          # 15
  # Tab 4: Backup Intervals
  "retain\t\t\t\thourly",  # 16
  "retain\t\t\t\tdaily",   # 17
  "retain\t\t\t\tweekly",  # 18
  "retain\t\t\t\tmonthly", # 19
  # Tab 3: Global Options
  "verbose\t\t\t",         # 20
  "loglevel\t\t",          # 21
  "logfile\t\t\t",         # 22
  "lockfile\t\t",          # 23
  "rsync_short_args",      # 24
  "rsync_long_args\t",     # 25
  "ssh_args\t",            # 26
  "du_args\t\t",           # 27
  "one_fs\t\t",            # 28
  "link_dest\t\t",         # 29
  "sync_first",            # 30
  "use_lazy_deletes",      # 31
  "rsync_numtries\t",      # 32
  # Tab 5: Includes/Excludes
  "include_file\t",        # 33
  "exclude_file\t",        # 34
  "include\t\t\t",         # 35
  "exclude\t\t\t",         # 36
  # Tab 6: Servers
  "backup\t\t\t\t",        # 37
  # Tab 7: Scripts
  "backup_script\t",       # 38
);

# and save the config File
# Parameters is all post data from config
sub saveConfig
{
  my $counter = 0;
  my $include_start = 35;
  my @arguments = @_;

  my $include_count = $arguments[0];
  my $incl_counter  = 0;

  my $exclude_count = $arguments[1];
  my $excl_counter  = 0;

  my $servers_count   = $arguments[2];
  my $servers_counter = 0;

  my $scripts_count = $arguments[3];
  # printf ("[ConfigWriter] Scripts Count %s\n",$scripts_count);
  # Open the config file for writing
  open (CONFIG, ">$configfile") || die $!;
  foreach my $arg (@arguments)
  {
    if ( $counter > 3 )
    { 
      # If not defined, we brake off
      if (!defined $arg || $arg eq "" || $arg eq "off") {}

      # If argument is on, we used checkbox and have to be changed to 1
      elsif ( defined $arg && $arg eq "on")  { printf CONFIG ($config_parameters[$counter]."\t1\n"); }

      # Include Patterns
      elsif ($counter == $include_start)
      {
        if ( ($include_count != 0) && ($incl_counter++ < $include_count) )
        {
          printf CONFIG ($config_parameters[$counter]."\t".$arg."\n");
          # Don't switch back if we reached the last member
          $incl_counter == $include_count || $counter --;
        }
      }
      # Exclude Patterns
      elsif ($counter == ($include_start + 1))
      {
        if ($excl_counter++ < $exclude_count)
        {
          printf CONFIG ($config_parameters[$counter]."\t".$arg."\n");
          # Don't switch back if we reached the last member
          $excl_counter == $exclude_count || $counter --;
        }
      }
      # Servers
      elsif ($counter == ($include_start + 2))
      {

        if ($servers_counter++ < $servers_count)
        {
          printf CONFIG ($config_parameters[$counter]."".$arg."\n");
          # Don't switch back if we reached the last member
          $servers_counter == $servers_count || $counter --;
        }
      }
      # Scripts
      elsif ($counter == $include_start + $exclude_count + $servers_count + $scripts_count)
      {

      }
      # And everything else ... just write to the file
      else
      {
        printf CONFIG ($config_parameters[$counter]."\t".$arg."\n");
      }
    }
    $counter++;
  }
  # Close the config file
  close CONFIG;
  printf ("[%s] [ConfigWriter] Writing config file: $configfile finished.\n",scalar localtime);
}

1;