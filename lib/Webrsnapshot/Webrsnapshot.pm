package Webrsnapshot;
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