package Webrsnapshot::CronHandler;

use strict;
use warnings;

sub new {
	my $class = shift;
	my $self = {
		_rs_cron_file   => shift,
		_rs_config_file => shift,
	};
	bless $self, $class;
	return $self;
}

# Read the cron file
sub getCronContent {
	my $self   = shift;
	my @result;

	# ToDo: Check if file exists
	# And we open the cron file for reading
	open (CRONFILE, $self->{_rs_cron_file});
	while (<CRONFILE>) {
		# MAILTO
		if ( $_ =~ /MAILTO/ ) {
			push(@result, $_) ;
		}

		# rsnapshot cronjobs (containing the config file)
		if ( $_ =~ /$self->{_rs_config_file}/ ) {
			push(@result, $_) ;
		}

		next if /^\s*$/; # Skip blank lines
		next if /^#/;    # Skip comments
		chop;            # Remove the new line character
	}

	# Close the cron file
	close CRONFILE;

	return \@result;
}

# $_[0] cronfile inhalt
sub writeCronContent {
	my($cronfile, @cronArray) = @_;
	my $cronfile_to_test	= "/tmp/cron_tmp_".(int(rand(8999))+1000);

	# Open the config file for writing
	open (CRONFILE, ">$cronfile_to_test") || return $!;  
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

	# Check here if the config is well formed and return any warnings and errors
	my @configtest = `crontab $cronfile_to_test 2>&1`;
	# Set configtest array with following code in the last cell
	# $configtest[-1] = 0 - No Errors, File Saved
	# $configtest[-1] = 2 - Error, wrong cron format
	# $configtest[-1] = 3 - Error, File not Saved

	# We have correct cron file
	if ( scalar @configtest == 0 ) {
		push (@configtest, "0");
		system ("cp $cronfile_to_test $cronfile") == 0 or $configtest[0] = 3;
		if ($configtest[0] == 3) {
			# Create an error message in case that the file can not be copied
			$configtest[0] = "Error: The file $cronfile_to_test";
			$configtest[1] = "can not be copied to $cronfile";
			$configtest[2] = 3;
		}
	} else {
		push (@configtest, "2");
	}

	return @configtest;
}

1;