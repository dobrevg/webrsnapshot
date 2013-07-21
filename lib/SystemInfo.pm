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

# Detect the operating system distro
sub getSystem
{
  my @result = {};
  my $issue  = "/etc/issue";
  my $issue_content   = "";
  my $operatingsystem = "";
  if (-r $issue)
  {
    $issue_content = `cat /etc/issue | head -1`;

    # OpenSUSE
    if ( $issue_content =~ m/openSUSE/)
    {
      $issue_content =~ 
        /^(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+/;
      $operatingsystem  = `uname -o`;
      $operatingsystem .= " ".$2." ".$3." ".$4." ";
      $operatingsystem .= `uname -i`;
    }

    # Debian
    if ( $issue_content =~ m/Debian/)
    {
      $issue_content =~ 
        /^(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+/;
      $operatingsystem  = `uname -o`;
      $operatingsystem .= " ".$1." ";
      $operatingsystem .= `cat /etc/debian_version`;
      $operatingsystem .= `uname -i`;
    }


  $result[0] = $operatingsystem;
  return @result;
  }
}
1;
