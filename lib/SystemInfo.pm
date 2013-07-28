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
  my $distro = getDistro();
  my $operatingsystem = "";
  
  # Linux with lsb command
  if ( $distro eq "lsbLinux" )
  {
    my $issue_content = `lsb_release -d`;
    $issue_content =~ /^(.*[^\t+])\t+(.*)/;
    $operatingsystem = $2;
  }

  # Linux with issue file
  if ( $distro eq "issueLinux" )
  {
    $operatingsystem = `cat /etc/issue | head -1`;
  }

  # FreeBSD
  if ( $distro eq "FreeBSD" ) 
  {
    $operatingsystem  = `uname -rs`;
    $operatingsystem .= " ";
    $operatingsystem .= `uname -m`;
  }

  # SunOS
  if ( $distro eq "SunOS" ) 
  {
    $operatingsystem  = `uname -a`;
  }
  $result[0] = $operatingsystem;
  return @result;
}

# Detect the distro
sub getDistro
{
  my $distro = "";
  my $lsb = `which lsb_release`; 
  chomp($lsb);

  if ( -x $lsb)
  {
    return "lsbLinux";
#    my $lsb_release = `$lsb -i`;
#
#    if ($lsb_release =~ m/Debian/)   { return "lsbLinux" } 
#    if ($lsb_release =~ m/Ubuntu/)   { return "lsbLinux" } 
#    if ($lsb_release =~ m/openSUSE/) { return "lsbLinux" } 
  }
  elsif ( -r "/etc/issue")
  {
    my $issue_content = `cat /etc/issue | head -1`;

    if ($issue_content =~ m/Fedora/) { return "issueLinux" }
  }
  else
  {
    my $uname = `uname -a`;
    if ( $uname =~ m/FreeBSD/) { return "FreeBSD"; }
    if ( $uname =~ m/SunOS/)   { return "SunOS";   }
  }
  
  return "unknown";
}
1;
