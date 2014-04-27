package HostSummary;
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
use Webrsnapshot::Webrsnapshot;

# $_[0] = config file
# $_[1] = host looked for
sub getBackupDirectories
{
  my $conffile = $_[0];
  my $host     = $_[1];
  my $rootdir  = Webrsnapshot::getBackupRootDir($conffile);
  # Get all interval names
  my @retains  = Webrsnapshot::getRetainings($conffile);

  # Open backupdir for reading 
  opendir my($rd), $rootdir || die "Couldn't open dir '$rootdir': $!";
  my @retain_dirs = sort grep {!/^\./} readdir $rd;
  closedir $rd; # and close it

  foreach (@retain_dirs)
  { # remove all empty folders
    opendir my($bd), $rootdir."/$_" || die "Couldn't open dir '$_': $!";
    $_ = "" if ( !(grep {!/^\./ && /$host/} readdir $bd) );
    closedir $bd;
  }

  return @retain_dirs;
}

# Get the last backup Time in days for all hosts
# If no backup found unlimited is shown
# $_[0] = config file
sub getAllLastBackupTimes
{
  my $conffile   = $_[0];
  my $rootdir    = Webrsnapshot::getBackupRootDir($conffile);
  my @hosts      = Webrsnapshot::getHostNames($conffile);
  my $host_ptr   = 0;

  foreach(@hosts)  # Process all backuped hosts
  {
    my $host          = $_;
    my @backupdirs    = getBackupDirectories($conffile, $host);
    my $last_dir_time = 0;
    foreach( @backupdirs ) # Process all directories for specific host
    {
      my $dir = $_;
      # If we have backup, get the time.
      my $curr_dir_time = 0;
      $curr_dir_time    = (stat($rootdir."/".$dir))[9] if ($dir ne "");
      $last_dir_time    = $curr_dir_time if ( $curr_dir_time > $last_dir_time);
    }
    $hosts[$host_ptr++] = $last_dir_time;
  }
  return @hosts;
}
1;
