package ConfigWriter;

use strict;
use warnings;

# and save the config File
# Parameters is all post data from config
sub saveConfig {
	my $configfile	= shift(@_);
	my ($config) 	= shift(@_);

	# Set Timestamp for random filename
	my $config_to_test	= "/tmp/rsnapshot_".time();

	# Open the config file for writing
	open (CONFIG, ">$config_to_test") || die $!;
	
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
	# ToDo: remove default value
	if ( $config->{'no_create_root'} ne '' ) {
		if ( $config->{'no_create_root'} eq 'on' ) {
			printf CONFIG ("no_create_root\t\t\t1\n");
		}
		if ( $config->{'no_create_root'} eq 'off' ) {
			printf CONFIG ("no_create_root\t\t\t0\n");
		}
	}

	# one_fs (optional)
	# ToDo: remove default value
	if ( $config->{'one_fs'} ne '' ) {
		if ( $config->{'one_fs'} eq 'on' ) {
			printf CONFIG ("one_fs\t\t\t\t\t1\n");
		}
		if ( $config->{'one_fs'} eq 'off' ) {
			printf CONFIG ("one_fs\t\t\t\t\t0\n");
		}
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
	# ToDo: remove default value
	if ( $config->{'rsync_numtries'} ne '' ) {
		printf CONFIG ("rsync_numtries\t\t\t$config->{'rsync_numtries'}\n");
	}

	# verbose (optional)
	# ToDo: remove default value
	if ( $config->{'verbose'} ne '' ) {
		printf CONFIG ("verbose\t\t\t\t\t$config->{'verbose'}\n");
	}

	# loglevel (optional)
	# ToDo: remove default value
	if ( $config->{'loglevel'} ne '' ) {
		printf CONFIG ("loglevel\t\t\t\t$config->{'loglevel'}\n");
	}

	# logfile (optional)
	# ToDo: remove default value
	if ( $config->{'logfile'} ne '' ) {
		printf CONFIG ("logfile\t\t\t\t\t$config->{'logfile'}\n");
	}

	# lockfile (optional)
	# ToDo: remove default value
	if ( $config->{'lockfile'} ne '' ) {
		printf CONFIG ("lockfile\t\t\t\t$config->{'lockfile'}\n");
	}

	# rsync_short_args (optional)
	# ToDo: remove default value
	if ( $config->{'rsync_short_args'} ne '' ) {
		printf CONFIG ("rsync_short_args\t\t$config->{'rsync_short_args'}\n");
	}

	# rsync_long_args (optional)
	# ToDo: remove default value
	if ( $config->{'rsync_long_args'} ne '' ) {
		printf CONFIG ("rsync_long_args\t\t\t$config->{'rsync_long_args'}\n");
	}

	# ssh_args (optional)
	# ToDo: remove default value
	if ( $config->{'ssh_args'} ne '' ) {
		printf CONFIG ("ssh_args\t\t\t\t$config->{'ssh_args'}\n");
	}

	# du_args (optional)
	# ToDo: remove default value
	if ( $config->{'du_args'} ne '' ) {
		printf CONFIG ("du_args\t\t\t\t\t$config->{'du_args'}\n");
	}

	# stop_on_stale_lockfile (optional)
	# ToDo: remove default value
	if ( $config->{'stop_on_stale_lockfile'} ne '' ) {
		if ( $config->{'stop_on_stale_lockfile'} eq 'on' ) {
			printf CONFIG ("stop_on_stale_lockfile\t1\n");
		}
		if ( $config->{'stop_on_stale_lockfile'} eq 'off' ) {
			printf CONFIG ("stop_on_stale_lockfile\t0\n");
		}
	}

	# link_dest (optional)
	# ToDo: remove default value
	if ( $config->{'link_dest'} ne '' ) {
		if ( $config->{'link_dest'} eq 'on' ) {
			printf CONFIG ("link_dest\t\t\t\t1\n");
		}
		if ( $config->{'link_dest'} eq 'off' ) {
			printf CONFIG ("link_dest\t\t\t\t0\n");
		}
	}

	# sync_first (optional)
	# ToDo: remove default value
	if ( $config->{'sync_first'} ne '' ) {
		if ( $config->{'sync_first'} eq 'on' ) {
			printf CONFIG ("sync_first\t\t\t\t1\n");
		}
		if ( $config->{'sync_first'} eq 'off' ) {
			printf CONFIG ("sync_first\t\t\t\t0\n");
		}
	}

	# use_lazy_deletes (optional)
	# ToDo: remove default value
	if ( $config->{'use_lazy_deletes'} ne '' ) {
		if ( $config->{'use_lazy_deletes'} eq 'on' ) {
			printf CONFIG ("use_lazy_deletes\t\t1\n");
		}
		if ( $config->{'use_lazy_deletes'} eq 'off' ) {
			printf CONFIG ("use_lazy_deletes\t\t0\n");
		}
	}

	# Intervals ###############
	if ( @{ $config->{'retain'} } ) {
		foreach ( @{ $config->{'retain'} } ) {
			my %retain = %$_;
			printf CONFIG ("retain\t\t\t\t\t$retain{'name'}\t$retain{'count'}\n");
		}
	}

	# Include/exclude #########
	# include_file (optional)
	# ToDo: remove default value
	if ( $config->{'include_file'} ne '' ) {
		printf CONFIG ("include_file\t\t\t$config->{'include_file'}\n");
	}

	# exclude_file (optional)
	# ToDo: remove default value
	if ( $config->{'exclude_file'} ne '' ) {
		printf CONFIG ("exclude_file\t\t\t$config->{'exclude_file'}\n");
	}

	# include (optional)
	# ToDo: remove default value
	my $include = $config->{'include'};
	if ( @$include ) {
		foreach ( @$include ) {
			printf CONFIG ("include\t\t\t\t\t$_\n");
		}
	}

	# exclude (optional)
	# ToDo: create it
	# ToDo: remove default value
	my $exclude = $config->{'exclude'};
	if ( @$exclude ) {
		foreach ( @$exclude ) {
			printf CONFIG ("exclude\t\t\t\t\t$_\n");
		}
	}

	# Hosts ###################
	# backup (required)
	# ToDo: create it
	# ToDo: remove default value
	if ( @{ $config->{'backup'} } ) {
		foreach ( @{ $config->{'backup'} } ) {
			my %backup = %$_;
			printf CONFIG ("backup\t\t\t\t\t$backup{'source'}\t$backup{'hostname'}/\t$backup{'args'}\n");
		}
	}

	# Scripts #################
	# backup_script (optional)
	# ToDo: create it
	# ToDo: remove default value
	if ( @{ $config->{'backup_script'} } ) {
		foreach ( @{ $config->{'backup_script'} } ) {
			my %backup_script = %$_;
			printf CONFIG ("backup_script\t\t\t$backup_script{'name'}\t$backup_script{'target'}\n");
		}
	}
	
	# Scripts #################
	# backup_exec (optional)
	# ToDo: create it
	# ToDo: remove default value
	my $backup_exec = $config->{'backup_exec'};
	if ( @$backup_exec ) {
		foreach ( @$backup_exec ) {
			printf CONFIG ("backup_exec\t\t\t\t\t$_\n");
		}
	}

	# Close the config file
	close CONFIG;

	# Check here if the config is well formed and return any warnings and errors
	# $configtest{'message'} from STDOUT/STDERR
	# $configtest{'exit_code'} the exit code
	my %configtest = ();

	$configtest{'message'} = `rsnapshot -c $config_to_test configtest 2>&1`;
	$configtest{'exit_code'} = ${^CHILD_ERROR_NATIVE};

	# if Syntax ok, then copy the temp config file to /etc
	if ( $configtest{'exit_code'} eq 0 ) {
		my $copyStdout = `cp -f $config_to_test $configfile`;
		$configtest{'exit_code'} = ${^CHILD_ERROR_NATIVE};

		# move the Stdout from copy to return message only if the exit code is not zero
		if ( $configtest{'exit_code'} ne 0 ) {
			$configtest{'message'} = $copyStdout;
		}
	}

	system ("rm", "-f",$config_to_test);
	return \%configtest;
}

1;