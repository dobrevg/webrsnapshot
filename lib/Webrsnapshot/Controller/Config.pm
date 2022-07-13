package Webrsnapshot::Controller::Config;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use Webrsnapshot::ConfigHandler;

# This action will render a template
sub index ($self) {

	# Read the rsnapshot config file
	my %config = %{ new Webrsnapshot::ConfigHandler($self->config->{rs_config_file})->readConfig() };

  # Render template "default/index.html.ep" with message
  $self->render(
    tmpl           => $self->config->{template},

	# ToDo: Empty config file?!? Create new one?!?
	# Root config
	config_version => $config{'config_version'},
	snapshot_root  => $config{'snapshot_root'},
	include_conf   => $config{'include_conf'},
	no_create_root => $config{'no_create_root'},
	one_fs         => $config{'one_fs'},

	# Commands
	cmd_rsync          => $config{'cmd_rsync'},
	cmd_cp             => $config{'cmd_cp'},
	cmd_rm             => $config{'cmd_rm'},
	cmd_ssh            => $config{'cmd_ssh'},
	cmd_logger         => $config{'cmd_logger'},
	cmd_du             => $config{'cmd_du'},
	cmd_rsnapshot_diff => $config{'cmd_rsnapshot_diff'},
	cmd_preexec        => $config{'cmd_preexec'},
	cmd_postexec       => $config{'cmd_postexec'},

	# LVM Options
	linux_lvm_cmd_lvcreate => $config{'linux_lvm_cmd_lvcreate'},
	linux_lvm_cmd_lvremove => $config{'linux_lvm_cmd_lvremove'},
	linux_lvm_cmd_mount    => $config{'linux_lvm_cmd_mount'},
	linux_lvm_cmd_umount   => $config{'linux_lvm_cmd_umount'},
	linux_lvm_snapshotsize => $config{'linux_lvm_snapshotsize'},
	linux_lvm_snapshotname => $config{'linux_lvm_snapshotname'},
	linux_lvm_vgpath       => $config{'linux_lvm_vgpath'},
	linux_lvm_mountpath    => $config{'linux_lvm_mountpath'},

	# Global Options
	rsync_numtries         => $config{'rsync_numtries'},
	verbose                => $config{'verbose'},
	loglevel               => $config{'loglevel'},
	logfile                => $config{'logfile'},
	lockfile               => $config{'lockfile'},
	rsync_short_args       => $config{'rsync_short_args'},
	rsync_long_args        => $config{'rsync_long_args'},
	ssh_args               => $config{'ssh_args'},
	du_args                => $config{'du_args'},
	stop_on_stale_lockfile => $config{'stop_on_stale_lockfile'},
	link_dest              => $config{'link_dest'},
	sync_first             => $config{'sync_first'},
	use_lazy_deletes       => $config{'use_lazy_deletes'},

	# Backup Intervals
	retains => $config{'retain'},

	# Includes/Excludes
	include_file => $config{'include_file'},
	exclude_file => $config{'exclude_file'},
	includes     => $config{'include'},
	excludes     => $config{'exclude'},

	# backup Hosts
	backups =>  $config{'backup'},

	# Scripts
	backup_scripts => $config{'backup_script'},
	backup_execs   => $config{'backup_exec'},
  );
}

1;
