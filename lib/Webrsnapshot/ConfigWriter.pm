package ConfigWriter;
use strict;
use warnings;

## Root
my @config_parameters =
(
  # Extra Parameter for multiply Lines below
  "include_count",         # 00
  "exclude_count",         # 01
  "server_count",          # 02
  "scrips_count",          # 03
  "rs_config_file",        # 04
  "retain_count",          # 05
  # Tab 1: Root config
  "config_version\t",      # 06    5
  "snapshot_root\t",       # 07    6
  "no_create_root\t",      # 08    7
  # Tab 2: Optional programs and scripts used
  "cmd_cp\t\t\t",          # 09    8
  "cmd_rm\t\t\t",          # 10   9
  "cmd_rsync\t\t",         # 11  10
  "cmd_ssh\t\t\t",         # 12  11
  "cmd_logger\t\t",        # 13  12
  "cmd_du\t\t\t",          # 14  13
  "cmd_rsnapshot_diff",    # 15  14
  "cmd_preexec",           # 16  15
  "cmd_postexec",          # 17  16
  # Tab 3: Global Options
  "verbose\t\t\t",         # 18  21
  "loglevel\t\t",          # 19  22
  "logfile\t\t\t",         # 20  23
  "lockfile\t\t",          # 21  24
  "rsync_short_args",      # 22  25
  "rsync_long_args\t",     # 23  26
  "ssh_args\t",            # 24  27
  "du_args\t\t",           # 25  28
  "one_fs\t\t",            # 26  29
  "link_dest\t\t",         # 27  30
  "sync_first",            # 28  31
  "use_lazy_deletes",      # 29  32
  "rsync_numtries\t",      # 30  33
  # Tab 4: Backup Intervals
  "retain\t\t",             # 31
  # Tab 5: Includes/Excludes
  "include_file\t",        # 32  34
  "exclude_file\t",        # 33  35
  "include\t\t\t",         # 34  36
  "exclude\t\t\t",         # 35  37
  # Tab 6: Servers
  "backup\t\t\t\t",        # 36  38
  # Tab 7: Scripts
  "backup_script\t",       # 37  39
);

# and save the config File
# Parameters is all post data from config
sub saveConfig
{
  my $counter       = 0;    # Just a counter
  my $retain_start  = 31;   # The number where retain starts
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
  
  my $retain_count    = $arguments[5];
  my $retain_counter  = 0;

  # Open the config file for writing
  open (CONFIG, ">$config_to_test") || die $!;
  foreach my $arg (@arguments)
  {
    if ( $counter > 5 )   # The last numer from extra parameter from the beginning
     {
      # If not defined, we brake off
      if (!defined $arg || $arg eq "" || $arg eq "off") {}

      # If argument is on, we used checkbox and have to be changed to 1
      elsif ( defined $arg && $arg eq "on")  
      {
        printf CONFIG ($config_parameters[$counter]."\t1\n"); 
      }
      # Retain Patterns
      elsif ($counter == $retain_start)
      {
        if ( ($retain_count != 0) && ($retain_counter++ < $retain_count) )
        {
          printf CONFIG ($config_parameters[$counter]."\t".$arg."\n");
          # Don't switch back if we reached the last member
          $retain_counter == $retain_count || $counter --;
        }
      }
      # Include Patterns
      elsif ($counter == $retain_start + 3)  # 1 + 2 while we have two schripts to include.
       {
        if ( ($include_count != 0) && ($incl_counter++ < $include_count) )
        {
          printf CONFIG ($config_parameters[$counter]."\t".$arg."\n");
          # Don't switch back if we reached the last member
          $incl_counter == $include_count || $counter --;
        }
      }
      # Exclude Patterns
      elsif ($counter == ($retain_start + 4))
      {
        if ($excl_counter++ < $exclude_count)
        {
          printf CONFIG ($config_parameters[$counter]."\t".$arg."\n");
          # Don't switch back if we reached the last member
          $excl_counter == $exclude_count || $counter --;
        }
      }
      # Servers
      elsif ($counter == ($retain_start + 5))
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
      elsif ($counter == $retain_start + 6)
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