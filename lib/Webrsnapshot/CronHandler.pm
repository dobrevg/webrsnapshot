package CronHandler;

use strict;
use warnings;

use Webrsnapshot::Webrsnapshot;

# $_[0] config file
# @result: mailto[0], cronjob[1], cronjob[2], cronjob[3]
sub getCronContent {
	my $configfile  = $_[0];	# /etc/rsnapshot.conf
	my $cronfile	= $_[1];	# /etc/cron.d/rsnapshot
	my @result		= "";

	# And we open the cronfile for reading
	my $result_ptr = 0;
	open (CRONFILE, $cronfile);
	while (<CRONFILE>) {
		my $line = $_; 
		# We save MAILTO in array[0]
		if ("$line" =~ /MAILTO/) 		{ $result[$result_ptr++] = $line; }
		# If we meet some cronjob with rsnapshot.conf, we get it.
		if ("$line" =~ /$configfile/) 	{ $result[$result_ptr++] = $line; }
		next if /^#/;	# Ignore every comment
		chop;			# Remove the new line character
	}
	return @result;
}

# $_[0] cronfile inhalt
sub writeCronContent {
	my($cronfile, @cronArray) = @_;

	# Open the config file for writing
	open (CRONFILE, ">$cronfile") || return $!;  
	print CRONFILE ("# Copyright© (2013-2022) Webrsnapshot\n");
	print CRONFILE ("# ----------------------------------------------------------------------------\n");
	print CRONFILE ("# This is a cronjob file for the rsnapshot Server created by Webrsnapshot.\n");
	print CRONFILE ("# If you use Webrsnapshot, don't edit this file manually. It can be overwritten\n\n");

	foreach (@cronArray) {
		if (index($_, "MAILTO") != -1) { printf CRONFILE ("$_\n\n\n"); } # two empty lines after Mailto
		elsif ($_ ne "") { printf CRONFILE ("$_\n"); }
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