package Webrsnapshot::Library;

use strict;
use warnings;

# This action will render a template
sub getRSConfigFiles {
    my ( $rs_config ) = @_;

    my @rs_config_files = ();
    # Check if we have directory or file
    if(-d $rs_config) {
        # the rsnapshot config files are in one directory
        @rs_config_files = glob($rs_config."/*.conf");
    }
    elsif(-f $rs_config) {
        # Just one rsnapshot config file
        @rs_config_files[0] = $rs_config;
    }
    else {
        exit 1;
    }
    return @rs_config_files;
}
1;