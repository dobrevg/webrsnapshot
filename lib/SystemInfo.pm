package SystemInfo;
use strict;
use warnings;

use ConfigReader;

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
