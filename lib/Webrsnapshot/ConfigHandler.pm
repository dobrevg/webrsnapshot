package Webrsnapshot::ConfigHandler;

use strict;
use warnings;
use open ':locale';

sub new {
    my $class = shift;
    my $self = {
        _config         => shift,
        _rs_config_file => shift,
    };
    bless $self, $class;
    return $self;
}

# and save the config File
# Parameters is all post data from config
sub saveConfig {
    my ( $self, $config, $skipCheck) = @_;

    # Set Timestamp for random filename
    my $config_to_test	= "/tmp/rsnapshot_".time();

    # Open the config file for writing
    if($skipCheck) {
        open (CONFIG, ">$self->{_rs_config_file}") || die $!;
    } else {
        open (CONFIG, ">$config_to_test") || die $!;
    }
    
    # Root ####################
    # config_version (required)
    printf CONFIG ("config_version\t\t\t$config->{'config_version'}\n");

    # snapshot_root ()
    printf CONFIG ("snapshot_root\t\t\t$config->{'snapshot_root'}\n");

    # include_conf (optional)
    if ( $config->{'include_conf'} ne '' ) {
        printf CONFIG ("include_conf\t\t\t$config->{'include_conf'}\n");
    }

    # no_create_root (optional)
    if ( $config->{'no_create_root'} ne '' ) {
        if ( $config->{'no_create_root'} eq 'on' ) {
            printf CONFIG ("no_create_root\t\t\t1\n");
        }
        if ( $config->{'no_create_root'} eq 'off' ) {
            printf CONFIG ("no_create_root\t\t\t0\n");
        }
    }

    # one_fs (optional)
    if ( $config->{'one_fs'} eq 'on' ) {
        printf CONFIG ("one_fs\t\t\t\t\t1\n");
    }

    # Commands ################
    # cmd_rsync (required)
    printf CONFIG ("cmd_rsync\t\t\t\t$config->{'cmd_rsync'}\n");

    # cmd_cp (optional)
    if ( $config->{'cmd_cp'} ne '' ) {
        printf CONFIG ("cmd_cp\t\t\t\t\t$config->{'cmd_cp'}\n");
    }

    # cmd_rm (optional)
    if ( $config->{'cmd_rm'} ne '' ) {
        printf CONFIG ("cmd_rm\t\t\t\t\t$config->{'cmd_rm'}\n");
    }

    # cmd_ssh (optional)
    if ( $config->{'cmd_ssh'} ne '' ) {
        printf CONFIG ("cmd_ssh\t\t\t\t\t$config->{'cmd_ssh'}\n");
    }

    # cmd_logger (optional)
    if ( $config->{'cmd_logger'} ne '' ) {
        printf CONFIG ("cmd_logger\t\t\t\t$config->{'cmd_logger'}\n");
    }

    # cmd_du (optional)
    if ( $config->{'cmd_du'} ne '' ) {
        printf CONFIG ("cmd_du\t\t\t\t\t$config->{'cmd_du'}\n");
    }

    # cmd_rsnapshot_diff (optional)
    if ( $config->{'cmd_rsnapshot_diff'} ne '' ) {
        printf CONFIG ("cmd_rsnapshot_diff\t\t$config->{'cmd_rsnapshot_diff'}\n");
    }

    # cmd_preexec (optional)
    if ( $config->{'cmd_preexec'} ne '' ) {
        printf CONFIG ("cmd_preexec\t\t\t\t$config->{'cmd_preexec'}\n");
    }

    # cmd_postexec (optional)
    if ( $config->{'cmd_postexec'} ne '' ) {
        printf CONFIG ("cmd_postexec\t\t\t$config->{'cmd_postexec'}\n");
    }

    # LVM Config ##############
    # linux_lvm_cmd_lvcreate (optional)
    if ( $config->{'linux_lvm_cmd_lvcreate'} ne '' ) {
        printf CONFIG ("linux_lvm_cmd_lvcreate\t$config->{'linux_lvm_cmd_lvcreate'}\n");
    }

    # linux_lvm_cmd_lvremove (optional)
    if ( $config->{'linux_lvm_cmd_lvremove'} ne '' ) {
        printf CONFIG ("linux_lvm_cmd_lvremove\t$config->{'linux_lvm_cmd_lvremove'}\n");
    }

    # linux_lvm_cmd_mount (optional)
    if ( $config->{'linux_lvm_cmd_mount'} ne '' ) {
        printf CONFIG ("linux_lvm_cmd_mount\t\t$config->{'linux_lvm_cmd_mount'}\n");
    }

    # linux_lvm_cmd_umount (optional)
    if ( $config->{'linux_lvm_cmd_umount'} ne '' ) {
        printf CONFIG ("linux_lvm_cmd_umount\t$config->{'linux_lvm_cmd_umount'}\n");
    }

    # linux_lvm_vgpath (optional)
    if ( $config->{'linux_lvm_vgpath'} ne '' ) {
        printf CONFIG ("linux_lvm_vgpath\t\t$config->{'linux_lvm_vgpath'}\n");
    }

    # linux_lvm_snapshotname (optional)
    if ( $config->{'linux_lvm_snapshotname'} ne '' ) {
        printf CONFIG ("linux_lvm_snapshotname\t$config->{'linux_lvm_snapshotname'}\n");
    }

    # linux_lvm_snapshotsize (optional)
    if ( $config->{'linux_lvm_snapshotsize'} ne '' ) {
        printf CONFIG ("linux_lvm_snapshotsize\t$config->{'linux_lvm_snapshotsize'}\n");
    }

    # linux_lvm_mountpath (optional)
    if ( $config->{'linux_lvm_mountpath'} ne '' ) {
        printf CONFIG ("linux_lvm_mountpath\t\t$config->{'linux_lvm_mountpath'}\n");
    }

    # Global Config ###########
    # rsync_numtries (optional)
    if ( $config->{'rsync_numtries'} ne "" ) {
        if ( $config->{'rsync_numtries'} > 1 ) {
            printf CONFIG ("rsync_numtries\t\t\t$config->{'rsync_numtries'}\n");
        }
    }

    # verbose (optional)
    if ( $config->{'verbose'} ne "" ) {
        if ( $config->{'verbose'} != 2 ) {
            printf CONFIG ("verbose\t\t\t\t\t$config->{'verbose'}\n");
        }
    }

    # loglevel (optional)
    if ( $config->{'loglevel'} ne '' ) {
        if ( $config->{'loglevel'} != 3 ) {
            printf CONFIG ("loglevel\t\t\t\t$config->{'loglevel'}\n");
        }
    }

    # logfile (optional)
    if ( $config->{'logfile'} ne '' ) {
        printf CONFIG ("logfile\t\t\t\t\t$config->{'logfile'}\n");
    }

    # lockfile (optional)
    if ( $config->{'lockfile'} ne '' ) {
        printf CONFIG ("lockfile\t\t\t\t$config->{'lockfile'}\n");
    }

    # rsync_short_args (optional)
    if ( $config->{'rsync_short_args'} ne '' ) {
        printf CONFIG ("rsync_short_args\t\t$config->{'rsync_short_args'}\n");
    }

    # rsync_long_args (optional)
    if ( $config->{'rsync_long_args'} ne '' ) {
        printf CONFIG ("rsync_long_args\t\t\t$config->{'rsync_long_args'}\n");
    }

    # ssh_args (optional)
    if ( $config->{'ssh_args'} ne '' ) {
        printf CONFIG ("ssh_args\t\t\t\t$config->{'ssh_args'}\n");
    }

    # du_args (optional)
    if ( $config->{'du_args'} ne '' ) {
        printf CONFIG ("du_args\t\t\t\t\t$config->{'du_args'}\n");
    }

    # stop_on_stale_lockfile (optional)
    if ( $config->{'stop_on_stale_lockfile'} ne '' ) {
        if ( $config->{'stop_on_stale_lockfile'} eq 'on' ) {
            printf CONFIG ("stop_on_stale_lockfile\t1\n");
        }
    }

    # link_dest (optional)
    if ( $config->{'link_dest'} ne '' ) {
        if ( $config->{'link_dest'} eq 'on' ) {
            printf CONFIG ("link_dest\t\t\t\t1\n");
        }
    }

    # sync_first (optional)
    if ( $config->{'sync_first'} ne '' ) {
        if ( $config->{'sync_first'} eq 'on' ) {
            printf CONFIG ("sync_first\t\t\t\t1\n");
        }
    }

    # use_lazy_deletes (optional)
    if ( $config->{'use_lazy_deletes'} ne '' ) {
        if ( $config->{'use_lazy_deletes'} eq 'on' ) {
            printf CONFIG ("use_lazy_deletes\t\t1\n");
        }
    }

    # Retain ###############
    foreach my $retain_ref ( @{ $config->{'retain'} } ) {
        printf CONFIG ("retain\t\t\t\t\t$retain_ref->{'name'}\t$retain_ref->{'count'}\n");
    }

    # Include/exclude #########
    # include_file (optional)
    if ( $config->{'include_file'} ne '' ) {
        printf CONFIG ("include_file\t\t\t$config->{'include_file'}\n");
    }

    # exclude_file (optional)
    if ( $config->{'exclude_file'} ne '' ) {
        printf CONFIG ("exclude_file\t\t\t$config->{'exclude_file'}\n");
    }

    # include (optional)
    foreach ( @{ $config->{'include'} } ) {
        if( defined $_ and $_ ne '' ) {
            printf CONFIG ("include\t\t\t\t\t$_\n");
        }
    }
    

    # exclude (optional)
    foreach ( @{ $config->{'exclude'} } ) {
        if( defined $_ and $_ ne '' ) {
            printf CONFIG ("exclude\t\t\t\t\t$_\n");
        }
    }

    # Hosts ###################
    # backup (required)
    if ( @{ $config->{'backup'} } ) {
        foreach ( @{ $config->{'backup'} } ) {
            my %backup = %$_;
            printf CONFIG ("backup\t\t\t\t\t$backup{'source'}\t$backup{'hostname'}/\t$backup{'args'}\n");
        }
    }

    # Scripts #################
    # backup_script (optional)
    foreach my $backup_script_ref ( @{ $config->{'backup_script'} } ) {
        if( $backup_script_ref->{'name'} ne '' and $backup_script_ref->{'target'} ne '' ) {
            printf CONFIG ("backup_script\t\t\t$backup_script_ref->{'name'}\t$backup_script_ref->{'target'}\n");
        }
    }

    # Scripts #################
    # backup_exec (optional)
    foreach my $backup_exec_ref ( @{ $config->{'backup_exec'} } ) {
        if( $backup_exec_ref->{'command'} ne '' ) {
            if( $backup_exec_ref->{'importance'} eq 'required' ) {
                printf CONFIG ("backup_exec\t\t\t\t$backup_exec_ref->{'command'}\t$backup_exec_ref->{'importance'}\n");
            } else {
                printf CONFIG ("backup_exec\t\t\t\t$backup_exec_ref->{'command'}\n");
            }
        } 
    }

    # Close the config file
    close CONFIG;

    # Check here if the config is well formed and return any warnings and errors
    # $configtest{'message'} from STDOUT/STDERR
    # $configtest{'exit_code'} the exit code
    my %configtest = ();

    if($skipCheck) {
        $configtest{'message'} = "The file was created successfully.";
        $configtest{'exit_code'} = 0;
    } else {
        $configtest{'message'} = `rsnapshot -c $config_to_test configtest 2>&1`;
        $configtest{'exit_code'} = ${^CHILD_ERROR_NATIVE};

        # if Syntax ok, then copy the temp config file to /etc
        if ( $configtest{'exit_code'} eq 0 ) {
            $configtest{'message'} = `cp -f $config_to_test $self->{_rs_config_file}`;
            $configtest{'exit_code'} = ${^CHILD_ERROR_NATIVE};

            # if everything is ok, write successfully message
            if ( !$configtest{'message'} ) {
                $configtest{'message'} = "Config file saved successfully";
            }
        }

        # Replace every new line character with the html new line
        $configtest{'message'} =~ s/\n/<br>/g;
        system ("rm", "-f",$config_to_test);
    }
    # Return the status message
    return %configtest;
}

sub readConfig {
    my $self = shift;

    my %config;
    my @retain;
    my %backup;
    my @include;
    my @exclude;
    my @backup_script;
    my @backup_exec;

    # Open rsnapshot config file for reading
    open (CONFIG, $self->{_rs_config_file}) || die $!;
    while (<CONFIG>) {
        next if /^#/;    # Skip comments
        next if /^\s*$/; # Skip blank lines
        chop;            # Remove the new line character

        # parse line
        my ($key, $value1, $value2, $value3) = split(/\t+/, $_, 4);

        # Root
        if( $key eq 'config_version' ) { $config{'config_version'} = $value1; }
        if( $key eq 'snapshot_root'  ) { $config{'snapshot_root'}  = $value1; }
        if( $key eq 'include_conf' )   { $config{'include_conf'}   = $value1; }
        if( $key eq 'no_create_root' ) { $config{'no_create_root'} = ($value1 ne 1)?'':'checked'; }
        if( $key eq 'one_fs' )         { $config{'one_fs'}         = ($value1 ne 1)?'':'checked'; }

        # Commands
        if( $key eq 'cmd_rsync' )          { $config{'cmd_rsync'}          = $value1; }
        if( $key eq 'cmd_cp' )             { $config{'cmd_cp'}             = $value1; }
        if( $key eq 'cmd_rm' )             { $config{'cmd_rm'}             = $value1; }
        if( $key eq 'cmd_ssh' )            { $config{'cmd_ssh'}            = $value1; }
        if( $key eq 'cmd_logger' )         { $config{'cmd_logger'}         = $value1; }
        if( $key eq 'cmd_du' )             { $config{'cmd_du'}             = $value1; }
        if( $key eq 'cmd_rsnapshot_diff' ) { $config{'cmd_rsnapshot_diff'} = $value1; }
        if( $key eq 'cmd_preexec' )        { $config{'cmd_preexec'}        = $value1; }
        if( $key eq 'cmd_postexec' )       { $config{'cmd_postexec'}       = $value1; }

        # LVM Config
        if( $key eq 'linux_lvm_cmd_lvcreate' ) { $config{'linux_lvm_cmd_lvcreate'} = $value1; }
        if( $key eq 'linux_lvm_cmd_lvremove' ) { $config{'linux_lvm_cmd_lvremove'} = $value1; }
        if( $key eq 'linux_lvm_cmd_mount' )    { $config{'linux_lvm_cmd_mount'}    = $value1; }
        if( $key eq 'linux_lvm_cmd_umount' )   { $config{'linux_lvm_cmd_umount'}   = $value1; }
        if( $key eq 'linux_lvm_vgpath' )       { $config{'linux_lvm_vgpath'}       = $value1; }
        if( $key eq 'linux_lvm_snapshotname' ) { $config{'linux_lvm_snapshotname'} = $value1; }
        if( $key eq 'linux_lvm_snapshotsize' ) { $config{'linux_lvm_snapshotsize'} = $value1; }
        if( $key eq 'linux_lvm_mountpath' )    { $config{'linux_lvm_mountpath'}    = $value1; }

        # Global config
        if( $key eq 'rsync_numtries' )         { $config{'rsync_numtries'}         = $value1; }
        if( $key eq 'verbose' )                { $config{'verbose'}                = $value1; }
        if( $key eq 'loglevel' )               { $config{'loglevel'}               = $value1; }
        if( $key eq 'logfile' )                { $config{'logfile'}                = $value1; }
        if( $key eq 'lockfile' )               { $config{'lockfile'}               = $value1; }
        if( $key eq 'rsync_short_args' )       { $config{'rsync_short_args'}       = $value1; }
        if( $key eq 'rsync_long_args' )        { $config{'rsync_long_args'}        = $value1; }
        if( $key eq 'ssh_args' )               { $config{'ssh_args'}               = $value1; }
        if( $key eq 'du_args' )                { $config{'du_args'}                = $value1; }
        if( $key eq 'stop_on_stale_lockfile' ) { $config{'stop_on_stale_lockfile'} = ($value1 ne 1)?'':'checked'; }
        if( $key eq 'link_dest' )              { $config{'link_dest'}              = ($value1 ne 1)?'':'checked'; }
        if( $key eq 'sync_first' )             { $config{'sync_first'}             = ($value1 ne 1)?'':'checked'; }
        if( $key eq 'use_lazy_deletes' )       { $config{'use_lazy_deletes'}       = ($value1 ne 1)?'':'checked'; }

        # Intervals
        if( $key eq 'interval' || $key eq 'retain' ) {
            my %retain_entry;
            $retain_entry{'name'}  = $value1;
            $retain_entry{'count'} = $value2;
            push( @retain, \%retain_entry);
        }

        # Include/Exclude
        if( $key eq 'include_file' ) { $config{'include_file'} = $value1; }
        if( $key eq 'exclude_file' ) { $config{'exclude_file'} = $value1; }

        if( $key eq 'include' ) { push( @include, $value1 ); }
        if( $key eq 'exclude' ) { push( @exclude, $value1 ); }

        # Hosts
        if( $key eq 'backup' ) {
            my $source	 = $value1;
            my $hostname = $value2;
            my $args 	 = $value3;

            # Remove tha trailing slash
            $hostname =~ s|/$||;
            # Remove reserved chars if any:., #, /, and whitespace
            $hostname =~ s/(\.|#|\/)/_/g;

            # create the source entry
            my %dirEntry;
            $dirEntry{'source'}	= $source;
            $dirEntry{'args'}	= $args;

            # If the host entry exists, just add the new source
            if ( $backup{$hostname} ) {
                my @hostArray = @{ $backup{$hostname} };
                push( @hostArray, \%dirEntry );
                $backup{$hostname} = \@hostArray;
            } 
            # Otherwise create a new host entry with the first source
            else {
                my @hostArray = ( \%dirEntry );
                $backup{$hostname} = \@hostArray;
            }
        }

        # backup_script
        if( $key eq 'backup_script' ) {
            my %backup_script_entry;
            $backup_script_entry{'name'} 	= $value1;
            $backup_script_entry{'target'} 	= $value2;
            push( @backup_script, \%backup_script_entry );
        }

        # backup_exec
        if( $key eq 'backup_exec' ) {
            my %backup_exec_entry;
            $backup_exec_entry{'command'} 		= $value1;
            $backup_exec_entry{'importance'} 	= $value2;
            push( @backup_exec, \%backup_exec_entry );
        }
    }
    # And close the file
    close CONFIG;

    # Add all missing arrays
    $config{'retain'} 		 = \@retain;
    $config{'backup'} 		 = \%backup;
    $config{'include'}		 = \@include;
    $config{'exclude'}		 = \@exclude;
    $config{'backup_script'} = \@backup_script;
    $config{'backup_exec'}	 = \@backup_exec;

    return  \%config;
}

# Delete config file
sub deleteConfig {
    my ( $self, $delete_logs ) = @_;

    # If logs have to be deletd too
    if($delete_logs) {
        my $logfile = $self->readConfig->{logfile};
        print "Logfile will be deleted: ".$logfile."\n";
        my $log_delete = `rm -f $logfile 2>&1`;
    }

    # Check here if the config is well formed and return any warnings and errors
    # $result{'message'} from STDOUT/STDERR
    # $result{'exit_code'} the exit code
    my %result = ();

    $result{'message'} = `rm -f $self->{_rs_config_file} 2>&1`;
    $result{'exit_code'} = ${^CHILD_ERROR_NATIVE};
    
    # if the exit code is zero, write sucessfuly message
    if ( $result{'exit_code'} eq 0 ) {
        $result{'message'} = "The file was deleted successfully.";
    }

    return %result;
}

1;