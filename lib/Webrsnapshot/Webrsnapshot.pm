package Webrsnapshot;
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

use Webrsnapshot::ConfigReader;

# $_[0] - is allways the config file

# Get backup directory root
sub getBackupRootDir
{
  my $parser      = new ConfigReader($_[0]);
  my $backup_root = $parser->getSnapshotRoot();
  $parser->DESTROY();
  return $backup_root;
}

# Get the names of retain (interals)
sub getRetainings
{
  my $parser     = new ConfigReader($_[0]);
  my @retainings = $parser->getRetains();
  $parser->DESTROY();
  return @retainings;
}

# Get the names of backuped hosts
# $_[0] - config file
sub getHostNames
{
  my $parser = new ConfigReader($_[0]);
  my @hosts  = $parser->getServers();
  $parser->DESTROY();

  my @result = $hosts[0][1];
  my $result_prt = 0;
  my $i = 0;
  foreach(@hosts)
  { # Get all names and move them in $result
    $result[++$result_prt] = $hosts[$i][1] if ( $result[$result_prt] ne $hosts[$i][1]);
    $i++;
  }
  foreach (@result) { $_ =~ s/\/$//g; }   # And remove the slashes at the end
  return @result;
}

1;