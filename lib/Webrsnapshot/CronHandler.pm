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
    my $separateLine     = "# ------------------------------------------------------------------------------";

    # Open the config file for writing
    open (CRONFILE, ">$self->{_rs_cron_file}") || return $!;  
    print CRONFILE ("# Copyright© (2013-2024) Webrsnapshot\n");
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

    my %configtest = ();
    $configtest{'exit_code'} = 0;
    $configtest{'message'}   = "Cron file saved successfully";
    return %configtest;
}

1;