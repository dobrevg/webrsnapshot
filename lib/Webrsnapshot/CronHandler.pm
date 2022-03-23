package CronHandler;

use strict;
use warnings;

use Webrsnapshot::Webrsnapshot;

# $_[0] config file
# @result: mailto[0], cronjob[1], cronjob[2], cronjob[3]
sub getCronContent
{
	my $configfile = $_[0];
	# TODO: Put the file in the Config
	my $cronfile	= "/etc/cron.d/rsnapshot";
	my @retainsTMP	= Webrsnapshot::getRetainings($configfile);
	my $retainSize	= scalar(@retainsTMP);
	my @retains		= "";
	my @result		= "";

	my $retain_prt = 0;
	while ( $retainSize > $retain_prt ) {
		$retains[$retain_prt] = $retainsTMP[$retain_prt++][0];
	}

	# And we open the cronfile for reading
	my $result_ptr = 1;
	open (CRONFILE, $cronfile);
	while (<CRONFILE>) {
		my $line = $_; 
		# We save MAILTO in array[0]
		if ("$line" =~ /MAILTO/) { $result[0] = $line; }   

		# If we meet some cronjob with retain, we get it. 
		my $retain_ptr = 1;
		foreach (@retains) {
			# Skip to the next line, if we searched for all reatains already
			next if ($retainSize == ($retain_ptr-1));
			if ("$line" =~ /$retains[$retain_ptr]/) { $result[$result_ptr++] = $line; }
			$retain_ptr++;
		}
		next if /^#/;	# Ignore every comment
		chop;			# Remove the new line character
	}
	return @result;
}

# $_[0] cronfile inhalt
sub writeCronContent {
	# TODO: Put the file in the Config
	my $cronfile   = "/etc/cron.d/rsnapshot";

	# Open the config file for writing
	open (CRONFILE, ">$cronfile") || return $!;  
	print CRONFILE ("# Copyright© (2013-2015) Georgi Dobrev (dobrev.g at gmail dot com)\n");
	print CRONFILE ("# ----------------------------------------------------------------------------\n");
	print CRONFILE ("# This is a cronjob file for the rsnapshot Server created by Webrsnapshot.\n\n");

	for (my $i=1; $i<=$_[0];$i++) {
		if ($_[$i] ne "") { printf CRONFILE ("$_[$i]\n"); }
	}

	print CRONFILE ("\n# <EOF>-----------------------------------------------------------------------\n");

	# Close the crontab file
	close CRONFILE;

	# Return code from close operator
	# 0 - Ok
	# -1 - Error
	return $?;
}

1;