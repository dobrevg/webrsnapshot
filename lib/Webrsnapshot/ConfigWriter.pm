package ConfigWriter;

use strict;
use warnings;

## Root
my @config_parameters =
(
	# Extra Parameter for multiply Lines below
	"include_count",		# 00
	"exclude_count",		# 01
	"server_count",			# 02
	"scrips_count",			# 03
	"rs_config_file",		# 04
	"retain_count",			# 05
	# Tab: Root config
	"config_version\t",
	"snapshot_root\t",
	"include_conf\t",
	"no_create_root\t",
	# Tab: Optional programs and scripts used
	"cmd_cp\t\t\t",
	"cmd_rm\t\t\t",
	"cmd_rsync\t\t",
	"cmd_ssh\t\t\t",
	"cmd_logger\t\t",
	"cmd_du\t\t\t",
	"cmd_rsnapshot_diff",
	"cmd_preexec",
	"cmd_postexec",
	# Tab: LVM Options
	"linux_lvm_cmd_lvcreate\t",
	"linux_lvm_cmd_lvremove\t",
	"linux_lvm_cmd_mount\t",
	"linux_lvm_cmd_umount\t",
	"linux_lvm_snapshotsize\t",
	"linux_lvm_snapshotname\t",
	"linux_lvm_vgpath\t",
	"linux_lvm_mountpath\t",  
	# Tab: Global Options
	"verbose\t\t\t",
	"loglevel\t\t",
	"logfile\t\t\t",
	"lockfile\t\t",
	"stop_on_stale_lockfile\t",
	"rsync_short_args",
	"rsync_long_args\t",
	"ssh_args\t",
	"du_args\t\t",
	"one_fs\t\t",
	"link_dest\t\t",
	"sync_first",
	"use_lazy_deletes",
	"rsync_numtries\t",
	# Tab: Backup Intervals
	"retain\t\t",
	# Tab: Includes/Excludes
	"include_file\t",
	"exclude_file\t",
	"include\t\t\t",
	"exclude\t\t\t",
	# Tab: Servers
	"backup\t\t\t\t",
	# Tab: Scripts
	"backup_script\t",
);

# and save the config File
# Parameters is all post data from config
sub saveConfig {
	my $counter			= 0;	# Just a counter
	my $retain_start	= 41;	# The number where retain starts
	my @arguments		= @_;

	my $include_count	= $arguments[0];
	my $incl_counter	= 0;

	my $exclude_count	= $arguments[1];
	my $excl_counter	= 0;

	my $servers_count	= $arguments[2];
	my $servers_counter	= 0;

	my $scripts_count	= $arguments[3];
	my $scripts_counter = 0;
	# Create random config file under /tmp for configtest later
	my $configfile		= $arguments[4];
	my $config_to_test	= "/tmp/rsnapshot_".(int(rand(8999))+1000);

	my $retain_count	= $arguments[5];
	my $retain_counter	= 0;

	# Open the config file for writing
	open (CONFIG, ">$config_to_test") || die $!;
	foreach my $arg (@arguments) {
		# The last numer from extra parameter from the beginning
		if ( $counter > 5 ) {
			# If not defined, we brake off
			if (!defined $arg || $arg eq "" || $arg eq "off") {}
			# If argument is on, we used checkbox and have to be changed to 1
			elsif ( defined $arg && $arg eq "on") {
				printf CONFIG ($config_parameters[$counter]."\t1\n"); 
			} elsif ($counter == $retain_start) {
				# Retain Patterns
				if ( ($retain_count != 0) && ($retain_counter++ < $retain_count) ) {
					printf CONFIG ($config_parameters[$counter]."\t\t".$arg."\n");
					# Don't switch back if we reached the last member
					$retain_counter == $retain_count || $counter --;
				}
			# 1 + 2 while we have two schripts to include.
			} elsif ($counter == $retain_start + 3) {
				# Include Patterns
				if ( ($include_count != 0) && ($incl_counter++ < $include_count) ) {
					printf CONFIG ($config_parameters[$counter]."\t".$arg."\n");
					# Don't switch back if we reached the last member
					$incl_counter == $include_count || $counter --;
				}
			} elsif ($counter == ($retain_start + 4)) {
				# Exclude Patterns
				if ($excl_counter++ < $exclude_count) {
					printf CONFIG ($config_parameters[$counter]."\t".$arg."\n");
					# Don't switch back if we reached the last member
					$excl_counter == $exclude_count || $counter --;
				}
			} elsif ($counter == ($retain_start + 5)) {
				# Servers
				if ($servers_counter++ < $servers_count) {
					printf CONFIG ($config_parameters[$counter]."".$arg."\n");
					# Don't switch back if we reached the last member
					$servers_counter == $servers_count || $counter --;
				}
			} elsif ($counter == $retain_start + 6) {
				# Scripts
				if ($scripts_counter++ < $scripts_count) {
					printf CONFIG ($config_parameters[$counter]."\t".$arg."\n");
					# Don't switch back if we reached the last member
					$scripts_counter == $scripts_count || $counter --;
				}
			} else {
				# And everything else ... just write to the file
				printf CONFIG ($config_parameters[$counter]."\t".$arg."\n");
			}
		}
		$counter++;
	}
	# Close the config file
	close CONFIG;

	# Check here if the config is well formed and return any warnings and errors
	my @configtest = `rsnapshot -c $config_to_test configtest 2>&1`;
	# Set configtest array with following code in the last cell
	# $configtest[-1] = 0 - No Errors, File Saved
	# $configtest[-1] = 1 - Warnings, File Saved
	# $configtest[-1] = 2 - Errors, File NOT Saved

	# Check if Syntax ok
	foreach (@configtest) {
		if ("$_" =~ /^Syntax\sOK/) {
			$configtest[-1] = 0 if (scalar (@configtest) == 1);
			$configtest[-1] = 1 if (scalar (@configtest) > 1);
		}
	}
	push (@configtest, "2") if ( $configtest[-1] ne "1" && scalar (@configtest) > 1 );
	# Save the tested config file on the real place only if Syntax OK
	if ($configtest[-1] ne "2") {
		system ("cp", $config_to_test, $configfile) == 0 or $configtest[-1] = 3;
		if ($configtest[-1] == 3) {
			# Create an error message in case that the file can not be copied
			$configtest[0] = "Error: The file $config_to_test can not be copyied";
			$configtest[1] = "to $configfile";
			$configtest[2] = 3;
		}
	}
	system ("rm", "-f",$config_to_test);
	return @configtest;
}

1;