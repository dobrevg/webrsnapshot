package ConfigWriter;
use strict;
use warnings;

## Root
my @config_parameters =
(
  # Extra Parameter for multiply Lines below
  "include_count",         # 0
  "exclude_count",         # 1
  "server_count",          # 2
  "scrips_count",          # 3
  "rs_config_file",        # 4
  # Tab 1: Root config
  "config_version\t",      # 5
  "snapshot_root\t",       # 6
  "no_create_root\t",      # 7
  # Tab 2: Optional programs and scripts used
  "cmd_cp\t\t\t",          # 8
  "cmd_rm\t\t\t",          # 9
  "cmd_rsync\t\t",         # 10
  "cmd_ssh\t\t\t",         # 11
  "cmd_logger\t\t",        # 12
  "cmd_du\t\t\t",          # 13
  "cmd_rsnapshot_diff",    # 14
  "cmd_preexec",           # 15
  "cmd_postexec",          # 16
  # Tab 4: Backup Intervals
  "retain\t\t\t\thourly",  # 17
  "retain\t\t\t\tdaily",   # 18
  "retain\t\t\t\tweekly",  # 19
  "retain\t\t\t\tmonthly", # 20
  # Tab 3: Global Options
  "verbose\t\t\t",         # 21
  "loglevel\t\t",          # 22
  "logfile\t\t\t",         # 23
  "lockfile\t\t",          # 24
  "rsync_short_args",      # 25
  "rsync_long_args\t",     # 26
  "ssh_args\t",            # 27
  "du_args\t\t",           # 28
  "one_fs\t\t",            # 29
  "link_dest\t\t",         # 30
  "sync_first",            # 31
  "use_lazy_deletes",      # 32
  "rsync_numtries\t",      # 33
  # Tab 5: Includes/Excludes
  "include_file\t",        # 34
  "exclude_file\t",        # 35
  "include\t\t\t",         # 36
  "exclude\t\t\t",         # 37
  # Tab 6: Servers
  "backup\t\t\t\t",        # 38
  # Tab 7: Scripts
  "backup_script\t",       # 39
);

# and save the config File
# Parameters is all post data from config
sub saveConfig
{
  my $counter       = 0;
  my $include_start = 36;
  my @arguments     = @_;

  my $include_count   = $arguments[0];
  my $incl_counter    = 0;

  my $exclude_count   = $arguments[1];
  my $excl_counter    = 0;

  my $servers_count   = $arguments[2];
  my $servers_counter = 0;

  my $scripts_count   = $arguments[3];
  my $scripts_counter = 0;
  # Create random config file under /tmp for configtest later
  my $configfile      = $arguments[4];
  my $config_to_test  = "/tmp/rsnapshot_".(int(rand(8999))+1000);

  # Open the config file for writing
  open (CONFIG, ">$config_to_test") || die $!;
  foreach my $arg (@arguments)
  {
    if ( $counter > 4 )
    {
      # If not defined, we brake off
      if (!defined $arg || $arg eq "" || $arg eq "off") {}

      # If argument is on, we used checkbox and have to be changed to 1
      elsif ( defined $arg && $arg eq "on")  
      {
        printf CONFIG ($config_parameters[$counter]."\t1\n"); 
      }
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
      #elsif ($counter == $include_start + $exclude_count + $servers_count + $scripts_count)
      elsif ($counter == $include_start + 3)
      {
        if ($scripts_counter++ < $scripts_count)
        {
          printf CONFIG ($config_parameters[$counter]."\t".$arg."\n");
          # Don't switch back if we reached the last member
          $scripts_counter == $scripts_count || $counter --;
        }
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

  # Check here if the config is well formed and return any warnings and errors
  my @configtest = `rsnapshot -c $config_to_test configtest 2>&1`;
  # Set configtest array with following code in the last cell
  # $configtest[-1] = 0 - No Errors, File Saved
  # $configtest[-1] = 1 - Warnings, File Saved
  # $configtest[-1] = 2 - Errors, File NOT Saved

  # Check if Syntax ok
  foreach (@configtest) 
  { 
    if ("$_" =~ /^Syntax\sOK/)
    {
      $configtest[-1] = 0 if (scalar (@configtest) == 1);
      $configtest[-1] = 1 if (scalar (@configtest) > 1);
    }
  }
  push (@configtest, "2") if ( $configtest[-1] ne "1" && scalar (@configtest) > 1 );
  # Save the tested config file on the real place only if Syntax OK
  if ($configtest[-1] ne "2")
  {
    system ("cp", $config_to_test, $configfile) == 0 or $configtest[-1] = 3;
    if ($configtest[-1] == 3)
    {
      # Create an error message in case that the file can not be copied
      $configtest[0] = "Error: The file $config_to_test can not be copyied";
      $configtest[1] = "to $configfile";
      $configtest[2] = 3;
    }
  }
  system ("rm", "-f",$config_to_test);
  return @configtest;
}

1;