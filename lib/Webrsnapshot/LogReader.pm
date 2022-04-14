package LogReader;

use strict;
use warnings;

use Webrsnapshot::ConfigReader;
use File::ReadBackwards;
use Encode;

sub getContent {
	my $parser  = new ConfigReader($_[2]?$_[2]:"/etc/rsnapshot.conf");
	my $logfile = $parser->getLogFile();
	my $result  = "";
	my $linecounter = $_[1]? $_[1]:100;

	my $bwlogfile = File::ReadBackwards->new( $logfile ) || return $!.": $logfile";
	until ( $bwlogfile->eof ) {
		if ($linecounter-- > 0) {
			$result .= decode_utf8($bwlogfile->readline);
		} else {
			last;
		}
	}
	# And destroy the parser
	$parser->DESTROY();
	return $result;
}

1;
