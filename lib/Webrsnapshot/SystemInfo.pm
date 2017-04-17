package SystemInfo;
#######################################################################
# This file is part of Webrsnapshot - The web interface for rsnapshot
# Copyright© (2013-2017) Georgi Dobrev (dobrev.g at gmail dot com)
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
# along with Webrsnapshot. If not, see <http://www.gnu.org/licenses/>.
#######################################################################
use strict;
use warnings;

use Webrsnapshot::ConfigReader;

# Gather Info about the partition allocation
sub getPartitionInfo
{
  my $parser      = new ConfigReader($_[1]?$_[1]:"/etc/rsnapshot.conf");
  my $backup_root = $parser->getSnapshotRoot();
  my @result = {};
  my $tmp_result  = `df -h $backup_root | tail -1`;
  $tmp_result =~ /^(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+/;  
  $result[0] = $1;    # Partition
  $result[1] = $2;    # Size
  $result[2] = $3;    # Used
  $result[3] = $4;    # Free
  $result[4] = $5;    # Percent
  $result[5] = $6;    # Mount point
  return @result;
}

1;
