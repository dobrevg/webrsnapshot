package ConfigReader;
#######################################################################
# This file is part of Webrsnapshot - The web interface for rsnapshot
# Copyright© (2013-2017) Georgi Dobrev (dobrev.g at gmail dot com)
#
# Webrsnapshot is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Webrsnapshot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Webrsnapshot. If not, see <http://www.gnu.org/licenses/>.
#######################################################################
use strict;
use warnings;
use open ':locale';

my $configfile              = "";
# Root
my $config_version          = "";
my $snapshot_root           = "";
my $include_conf            = "";
my $no_create_root          = "";
# Optional programs and scripts used
my $cmd_cp                  = "";
my $cmd_rm	                = "";
my $cmd_rsync               = "";
my $cmd_ssh                 = "";
my $cmd_logger              = "";
my $cmd_du                  = "";
my $cmd_rsnapshot_diff      = "";
my $cmd_preexec             = "";
my $cmd_postexec            = "";
# LVM Config
my $linux_lvm_cmd_lvcreate  = "";
my $linux_lvm_cmd_lvremove  = "";
my $linux_lvm_cmd_mount     = "";
my $linux_lvm_cmd_umount    = "";
my $linux_lvm_snapshotsize  = "";
my $linux_lvm_snapshotname  = "";
my $linux_lvm_vgpath        = "";
my $linux_lvm_mountpath     = "";
# Global Options
my $verbose                 = "";    # 1 - 5, def = 2
my $loglevel                = "";    # 1 - 5, def = 3 
my $logfile                 = "";
my $lockfile                = "";
my $stop_on_stale_lockfile  = "";
my $rsync_short_args        = "";
my $rsync_long_args         = "";
my $ssh_args                = "";
my $du_args                 = "";
my $one_fs                  = "";
my $link_dest               = "";
my $sync_first              = "";
my $use_lazy_deletes        = "";
my $rsync_numtries          = "";
# Backup Intervals
my @retain                  = "";
my $retain_ptr              = 0 ;
# Includes
my $include_file            = "";
my $exclude_file            = "";
my @include                 = "";    # Array
my $include_ptr             = 0 ;
my @exclude                 = "";    # Array
my $exclude_ptr             = 0 ;
# Backups
my @backup_servers	        = "";    # Array
my $backup_servers_ptr      = 0 ;
my @backup_scripts          = "";    # Array
my $backup_scripts_ptr      = 0 ;


sub new
{
    my $this = {};             # Create an anonymouns hash, and #self points to it
    bless   $this;             # Connect the hash to the package
    $configfile = $_[1]?$_[1]:"/etc/rsnapshot.conf";

    # Check if rsync and rsnapshot are installed
    system ("which", "rsync")     == 0 or die "Rsync not found on this server!";
    system ("which", "rsnapshot") == 0 or die "Rsnapshot not found on this server!";
    die "$configfile is missing.\n" unless (-e $configfile);
  
    printf ("[%s] Start reading config file: $configfile\n",scalar localtime);
    open (CONFIG, $configfile) || die $!;
    while (<CONFIG>)
    {
        #print ("Readed Line: $_");
        my $temp = "";
        next if /^#/;                   # Ignore every comment 
        chop;                           # Remove the new line character
        # and start parsing the config file
        # Tab Root config
        if    ("$_" =~ /^config_version\t+(.*)/)     { $config_version     = $1; }
        elsif ("$_" =~ /^snapshot_root\t+(.*)/ )     { $snapshot_root      = $1; }
        elsif ("$_" =~ /^include_conf\t+(.*)/ )      { $include_conf       = $1; }
        elsif ("$_" =~ /^no_create_root\t+(.*)/)     { $no_create_root     = $1; }
        # Tab Optional programs and scripts used
        elsif ("$_" =~ /^cmd_cp\t+(.*)/)             { $cmd_cp             = $1; }
        elsif ("$_" =~ /^cmd_rm\t+(.*)/)             { $cmd_rm             = $1; }
        elsif ("$_" =~ /^cmd_rsync\t+(.*)/)          { $cmd_rsync          = $1; }
        elsif ("$_" =~ /^cmd_ssh\t+(.*)/)            { $cmd_ssh            = $1; }
        elsif ("$_" =~ /^cmd_logger\t+(.*)/)         { $cmd_logger         = $1; }
        elsif ("$_" =~ /^cmd_du\t+(.*)/)             { $cmd_du             = $1; }
        elsif ("$_" =~ /^cmd_rsnapshot_diff\t+(.*)/) { $cmd_rsnapshot_diff = $1; }
        elsif ("$_" =~ /^cmd_preexec\t+(.*)/)        { $cmd_preexec        = $1; }
        elsif ("$_" =~ /^cmd_postexec\t+(.*)/)       { $cmd_postexec       = $1; }
        # Tab LVM Configuration
        elsif ("$_" =~ /^linux_lvm_cmd_lvcreate\t+(.*)/) { $linux_lvm_cmd_lvcreate = $1; }
        elsif ("$_" =~ /^linux_lvm_cmd_lvremove\t+(.*)/) { $linux_lvm_cmd_lvremove = $1; }
        elsif ("$_" =~ /^linux_lvm_cmd_mount\t+(.*)/)    { $linux_lvm_cmd_mount    = $1; }
        elsif ("$_" =~ /^linux_lvm_cmd_umount\t+(.*)/)   { $linux_lvm_cmd_umount   = $1; }
        elsif ("$_" =~ /^linux_lvm_snapshotsize\t+(.*)/) { $linux_lvm_snapshotsize = $1; }
        elsif ("$_" =~ /^linux_lvm_snapshotname\t+(.*)/) { $linux_lvm_snapshotname = $1; }
        elsif ("$_" =~ /^linux_lvm_vgpath\t+(.*)/)       { $linux_lvm_vgpath       = $1; }
        elsif ("$_" =~ /^linux_lvm_mountpath\t+(.*)/)    { $linux_lvm_mountpath    = $1; }
        # Tab Global configuration
        elsif ("$_" =~ /^verbose\t+(.*)/)                { $verbose                = $1; }
        elsif ("$_" =~ /^loglevel\t+(.*)/)               { $loglevel               = $1; }
        elsif ("$_" =~ /^logfile\t+(.*)/)                { $logfile                = $1; }
        elsif ("$_" =~ /^lockfile\t+(.*)/)               { $lockfile               = $1; }
        elsif ("$_" =~ /^stop_on_stale_lockfile\t+(.*)/) { $stop_on_stale_lockfile = $1; }
        elsif ("$_" =~ /^rsync_short_args\t+(.*)/)       { $rsync_short_args       = $1; }
        elsif ("$_" =~ /^rsync_long_args\t+(.*)/)        { $rsync_long_args        = $1; }
        elsif ("$_" =~ /^ssh_args\t+(.*)/)               { $ssh_args               = $1; }
        elsif ("$_" =~ /^du_args\t+(.*)/)                { $du_args                = $1; }
        elsif ("$_" =~ /^one_fs\t+(.*)/)                 { $one_fs                 = $1; }
        elsif ("$_" =~ /^link_dest\t+(.*)/)              { $link_dest              = $1; }
        elsif ("$_" =~ /^sync_first\t+(.*)/)             { $sync_first             = $1; }
        elsif ("$_" =~ /^use_lazy_deletes\t+(.*)/)       { $use_lazy_deletes       = $1; }
        elsif ("$_" =~ /^rsync_numtries\t+(.*)/)         { $rsync_numtries         = $1; }
        # Tab 4: Backup intervals, OpenSuSE still uses interval
        # Let us support the old "interval" and the new "retain"
        elsif ("$_" =~ /^interval\t+(.*?[^\t+])\t+(.*)/ || "$_" =~ /^retain\t+(.*?[^\t+])\t+(.*)/)
        {
            my @retain_tmp = ($1, $2);
            $retain[$retain_ptr++] = (\@retain_tmp)
        }
        # Tab 5: Include und Exclude
        elsif ("$_" =~ /^include\t+(.*)/)            { $include[$include_ptr++] = $1; }
        elsif ("$_" =~ /^exclude\t+(.*)/)            { $exclude[$exclude_ptr++] = $1; }
        elsif ("$_" =~ /^include_file\t+(.*)/)       { $include_file            = $1; }
        elsif ("$_" =~ /^exclude_file\t+(.*)/)       { $exclude_file            = $1; }
        # Tab 6: Server config is complicated
        # Filter servers with extra arguments
        elsif ("$_" =~ /^backup\t+(.*[^\t+])\t+(.*?[^\t+])\t+(.*)/) 
        {
            my @servers = ($1, $2, $3);
            $backup_servers[$backup_servers_ptr++] = (\@servers);
        }
        # And then the rest without arguments
        elsif ("$_" =~ /^backup\t+(.*?[^\t+])\t+(.*)/) 
        {
            my @servers = ($1, $2, "");
            $backup_servers[$backup_servers_ptr++] = (\@servers);
        }
        # Tab 7: Scripts have to be configured
        elsif ("$_" =~ /^backup_script\t+(.*?[^\t+])\t+(.*)/) 
        { 
            my @scripts = ($1, $2);
            $backup_scripts[$backup_scripts_ptr++] = (\@scripts);
        }
        else  { }    # Unknown Line. Don't know what to do now?
    }

    # And close the file	
    close CONFIG;
    # Clear the Array pointers for the next run 
    $include_ptr        = 0;
    $exclude_ptr        = 0;
    $backup_servers_ptr = 0;
    $backup_scripts_ptr = 0;
    return  $this;             # Return the reference to the hash
}

# Tab Root
sub getConfigVersion  { return $config_version; }
sub getSnapshotRoot   { return $snapshot_root;  }
sub getIncludeConf    { return $include_conf;   }
sub getNoCreateRoot   { return ($no_create_root ne 1) ? " ":"checked"; }
# Tab Commands
sub getCmCp           { return $cmd_cp;     }
sub getCmRm           { return $cmd_rm;     }
sub getCmRsync        { return $cmd_rsync;  }
sub getCmSsh          { return $cmd_ssh;    }
sub getCmLogger       { return $cmd_logger; }
sub getCmDu           { return $cmd_du;     }
sub getCmDiff         { return $cmd_rsnapshot_diff; }
sub getPreExec        { return $cmd_preexec;        }
sub getPostExec       { return $cmd_postexec;       }
#Tab LVM Config
sub getLinuxLvmCmdLvcreate  { return $linux_lvm_cmd_lvcreate; }
sub getLinuxLvmCmdLvremove  { return $linux_lvm_cmd_lvremove; }
sub getLinuxLvmCmdMount     { return $linux_lvm_cmd_mount;    }
sub getLinuxLvmCmdUmount    { return $linux_lvm_cmd_umount;   }
sub getLinuxLvmSnapshotsize { return $linux_lvm_snapshotsize; }
sub getLinuxLvmSnapshotname { return $linux_lvm_snapshotname; }
sub getLinuxLvmVgpath       { return $linux_lvm_vgpath;       }
sub getLinuxLvmMountpath    { return $linux_lvm_mountpath;    }
#Tab Global Config
sub getVerbose              { return $verbose;  }
sub getLogLevel             { return $loglevel; }
sub getLogFile              { return $logfile;  }
sub getLockFile             { return $lockfile; }
sub getStopOnStaleLockfile  { return ($stop_on_stale_lockfile ne 1) ? " ":"checked"; }
sub getRsyncShortArgs       { return $rsync_short_args; }
sub getRsyncLongArgs        { return $rsync_long_args;  }
sub getSshArgs              { return $ssh_args;         }
sub getDuArgs               { return $du_args;          }
sub getOneFs                { return ($one_fs ne 1)           ? " ":"checked"; }
sub getLinkDest             { return ($link_dest ne 1)        ? " ":"checked"; }
sub getSyncFirst            { return ($sync_first ne 1)       ? " ":"checked"; }
sub getUseLazyDeletes       { return ($use_lazy_deletes ne 1) ? " ":"checked"; }
sub getRsyncNumtries        { return $rsync_numtries;   }
# Tab Backup Intervals
sub getRetains        { return @retain;         }
# Tab Include/Exclude
sub getIncludeFile    { return $include_file;   }
sub getExcludeFile    { return $exclude_file;   }
sub getInclude        { return @include;        }
sub getExclude        { return @exclude;        }
# Tab Servers
sub getServers        { return @backup_servers; }
# Tab Scripts
sub getScripts        { return @backup_scripts; }

# And the Destructor
sub DESTROY {
    my $self = shift;

    # Reset all values
    # Root
    $config_version         = "";
    $snapshot_root          = "";
    $include_conf           = "";
    $no_create_root         = "";
    # Optional programs and scripts used
    $cmd_cp                 = "";
    $cmd_rm	                = "";
    $cmd_rsync              = "";
    $cmd_ssh                = "";
    $cmd_logger             = "";
    $cmd_du                 = "";
    $cmd_rsnapshot_diff     = "";
    $cmd_preexec            = "";
    $cmd_postexec           = "";
    # LVM Config
    $linux_lvm_cmd_lvcreate = "";
    $linux_lvm_cmd_lvremove = "";
    $linux_lvm_cmd_mount    = "";
    $linux_lvm_cmd_umount   = "";
    $linux_lvm_snapshotsize = "";
    $linux_lvm_snapshotname = "";
    $linux_lvm_vgpath       = "";
    $linux_lvm_mountpath    = "";
    # Global Options
    $verbose                = "";    # 1 - 5, def = 2
    $loglevel               = "";    # 1 - 5, def = 3
    $logfile                = "";
    $lockfile               = "";
    $stop_on_stale_lockfile = "";
    $rsync_short_args       = "";
    $rsync_long_args        = "";
    $ssh_args               = "";
    $du_args                = "";
    $one_fs                 = "";
    $link_dest              = "";
    $sync_first             = "";
    $use_lazy_deletes       = "";
    $rsync_numtries         = "";
    # Backup Intervals
    @retain                 = "";
    $retain_ptr             = 0 ;
    # Includes
    $include_file           = "";
    $exclude_file           = "";
    @include                = "";    # Array
    $include_ptr            = 0 ;
    @exclude                = "";    # Array
    $exclude_ptr            = 0 ;
    # Backups
    @backup_servers         = "";    # Array
    $backup_servers_ptr     = 0 ;
    @backup_scripts         = "";    # Array
    $backup_scripts_ptr     = 0 ;

    # check for an overridden destructor
    $self->SUPER::DESTROY if $self->can("SUPER::DESTROY");
    # now do your own thing before or after
}

1;
