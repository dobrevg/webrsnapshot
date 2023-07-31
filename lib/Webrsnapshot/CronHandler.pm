package Webrsnapshot::CronHandler;

use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = {
        _rs_cron_file   => shift,
        _rs_config_files => shift,
    };
    bless $self, $class;
return $self;
}

# Read the cron file
sub getCronContent {
    my $self   = shift;
    my %result;

    # create the result hash from the rs filenames
    %result = map { $self->{_rs_config_files}[$_] => [] } 0 .. $#{$self->{_rs_config_files}};

    # If the cron file doesn't exists, just create it
    unless(-e $self->{_rs_cron_file}) { 
        open my $fc, ">", $self->{_rs_cron_file}; 
        close $fc; 
    }

    # And we open the cron file for reading
    open (CRONFILE, $self->{_rs_cron_file});
    while (<CRONFILE>) {
        # Skip blank or comment lines
        next if /^\s*$/; # Skip blank lines
        # next if /^#/;    # Skip comments
        chop;            # Remove the new line character

        # MAILTO line
        if ( $_ =~ /MAILTO/ ) {
            $result{'MAILTO'} = $_;
        }

        # Rsnapshot cron job lines
        my @cron_line = split /\s+/, $_;
        if(defined $cron_line[8] and ($_ =~ /\.conf/) ) { 
            push(@{ $result{$cron_line[8]} }, $_);
        }
    }

    # Close the cron file
    close CRONFILE;
    return \%result;
}

# Crontab content is array reference
sub writeCronContent {
    my ($self, $cronContentRef) = @_;
    my $cronfile_to_test = "/tmp/rs_cron_tmp_".time();
    my $separateLine     = "# ------------------------------------------------------------------------------";

    # Open the config file for writing
    open (CRONFILE, ">$cronfile_to_test") || return $!;  
    print CRONFILE ("# Copyright© (2013-2023) Webrsnapshot\n");
    print CRONFILE ("$separateLine\n");
    print CRONFILE ("# This is a cronjob file for the rsnapshot Server created by Webrsnapshot.\n");
    print CRONFILE ("# If you use Webrsnapshot, don't edit this file manually. It can be overwritten\n\n");

    # Write the mailto line
    printf CRONFILE ("$cronContentRef->{'cron_email'}\n\n");
    my $lastConfFile = "";

    # Iterate over all cronjobs
    foreach my $k (sort keys %$cronContentRef) {
        if ($k =~ m/cronjob_/) {
            my $confFile = substr($k, index($k, '_')+1,rindex($k, '_')-(index($k, '_')+1));
            if($lastConfFile ne $confFile) {
                $lastConfFile = $confFile;
                my $string_len = length($confFile);
                my $newSeparateLine = $separateLine;
                my $z = substr ($newSeparateLine, 2, $string_len, $confFile);
                printf CRONFILE ("\n".$newSeparateLine."\n");
            }
            printf CRONFILE ("$cronContentRef->{$k}\n");
        }
    }

    # Print End Of File.
    print CRONFILE ("\n# <EOF>-------------------------------------------------------------------------\n");

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
        system ("cp $cronfile_to_test $self->{_rs_cron_file}") == 0 or $configtest[0] = 3;
        system ("rm -f $cronfile_to_test");
        if ($configtest[0] == 3) {
            # Create an error message in case that the file can not be copied
            $configtest[0] = "Error: The file $cronfile_to_test";
            $configtest[1] = "can not be copied to $self->{_rs_cron_file}";
            $configtest[2] = 3;
        }
    } else {
        push (@configtest, "2");
    }

    return @configtest;
}

1;