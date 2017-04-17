package ConfigWriter;
#######################################################################
# This file is part of Webrsnapshot - The web interface for rsnapshot
# Copyright© (2013-2014) Georgi Dobrev (dobrev.g at gmail dot com)
#
# Webrsnapshot is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Webrsnapshot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################
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
  # Tab: Root config
  "config_version\t",      # 06
  "snapshot_root\t",       # 07
  "no_create_root\t",      # 08
  # Tab: Optional programs and scripts used
  "cmd_cp\t\t\t",          # 09
  "cmd_rm\t\t\t",          # 10
  "cmd_rsync\t\t",         # 11
  "cmd_ssh\t\t\t",         # 12
  "cmd_logger\t\t",        # 13
  "cmd_du\t\t\t",          # 14
  "cmd_rsnapshot_diff",    # 15
  "cmd_preexec",           # 16
  "cmd_postexec",          # 17
    # Tab: LVM Options
    "linux_lvm_cmd_lvcreate\t", # 18
    "linux_lvm_cmd_lvremove\t", # 19
    "linux_lvm_cmd_mount\t",    # 20
    "linux_lvm_cmd_umount\t",   # 21
    "linux_lvm_snapshotsize\t", # 22
    "linux_lvm_snapshotname\t", # 23
    "linux_lvm_vgpath\t",       # 24
    "linux_lvm_mountpath\t",    # 25  
  # Tab: Global Options
  "verbose\t\t\t",         # 26
  "loglevel\t\t",          # 27
  "logfile\t\t\t",         # 28
  "lockfile\t\t",          # 29
  "rsync_short_args",      # 30
  "rsync_long_args\t",     # 31
  "ssh_args\t",            # 32
  "du_args\t\t",           # 33
  "one_fs\t\t",            # 34
  "link_dest\t\t",         # 35
  "sync_first",            # 36
  "use_lazy_deletes",      # 37
  "rsync_numtries\t",      # 38
  # Tab: Backup Intervals
  "retain\t\t",             # 39
  # Tab: Includes/Excludes
  "include_file\t",        # 40
  "exclude_file\t",        # 41
  "include\t\t\t",         # 42
  "exclude\t\t\t",         # 43
  # Tab: Servers
  "backup\t\t\t\t",        # 44
  # Tab: Scripts
  "backup_script\t",       # 45
);

# and save the config File
# Parameters is all post data from config
sub saveConfig
{
  my $counter       = 0;    # Just a counter
  my $retain_start  = 39;   # The number where retain starts
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