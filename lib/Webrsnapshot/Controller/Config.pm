package Webrsnapshot::Controller::Config;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use Webrsnapshot::ConfigHandler;
use Webrsnapshot::Library;

# This action will render a template
sub index ($self) {

    # Get rs_conf_id from stash
    my $rs_config_id = $self->stash('id');
    # Array with Rsnapshot config files
    my @rs_config_files = Webrsnapshot::Library::getRSConfigFiles($self->config->{rs_config});
    # Read the rsnapshot config file
    my %config = %{ new Webrsnapshot::ConfigHandler($self->config,$rs_config_files[$rs_config_id])->readConfig() };

    # Render template "default/index.html.ep" with message
    $self->render(
        tmpl           => $self->config->{template},
        rs_config_id   => $rs_config_id,
        rs_config_file => $rs_config_files[$rs_config_id],

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

# Save the rsnapshot configuration
sub save {
    my ( $self ) = @_;

    my @backup  = ();
    my @retain  = ();
    my @include = ();
    my @exclude = ();
    my @backup_exec   = ();
    my @backup_script = ();

    # Get all post variables
    my $configparams = $self->req->params->to_hash;

    # Iterate over all keys and extract the multiline entries
    foreach my $key (sort keys %$configparams) {
        # include
        if( rindex($key,'include-',0) == 0) {
            $include[substr($key, 8)+0] = $configparams->{$key};
        }

        # exclude
        if( rindex($key,'exclude-',0) == 0) {
            $exclude[substr($key, 8)+0] = $configparams->{$key};
        }

        # retain
        if( rindex($key,'retainname_',0) == 0) {
            my %retain_entry = ();
            $retain_entry{'name'}  = $configparams->{$key};
            $retain_entry{'count'} = $configparams->{'retaincount_'.(substr($key, 11)+0)};
            push( @retain, \%retain_entry );
        }

        # backup_script
        if( rindex($key,'backup_script_name_',0) == 0) {
            my %backup_script_entry = ();
            $backup_script_entry{'name'}   = $configparams->{$key};
            $backup_script_entry{'target'} = $configparams->{'backup_script_target_'.(substr($key, 19)+0)};
            push( @backup_script, \%backup_script_entry);
        }

        # backup_exec
        if( rindex($key,'backup_exec_command_',0) == 0) {
            my %backup_exec_entry = ();
            $backup_exec_entry{'command'}    = $configparams->{$key};
            $backup_exec_entry{'importance'} = $configparams->{'backup_exec_importance_'.(substr($key, 20)+0)};
            push( @backup_exec, \%backup_exec_entry);
        }

        # backup
        if( rindex($key,'hostname_',0) == 0) {
            my %backup_host = ();
            $backup_host{'hostname'} = substr($key, 9, CORE::index($key,"__")-9);
            # We continue analyse the param only if its a source
            my $sourcekey      = 'hostname_'.$backup_host{'hostname'}.'__source_';
            my $argumentskey   = 'hostname_'.$backup_host{'hostname'}.'__args_';
            my $hostnamelength = length($backup_host{'hostname'});
            if( rindex($key,$sourcekey,0) == 0 ) {
                $backup_host{'source'} = $configparams->{$sourcekey.(substr($key, 18 + $hostnamelength)+0)};
                $backup_host{'args'}   = $configparams->{$argumentskey.(substr($key, 18 + $hostnamelength)+0)};
                push( @backup, \%backup_host);
            }
        }
    }

    # Build config hash
    my %config = (
        # Root
        'config_version' => $self->param('config_version'),
        'snapshot_root'  => $self->param('snapshot_root' ),
        'include_conf'   => $self->param('include_conf' ),
        'no_create_root' => $self->param('no_create_root')?$self->param('no_create_root'):"off",
        'one_fs'         => $self->param('one_fs')?$self->param('one_fs'):"off",
        # Commands
        'cmd_rsync'          => $self->param('cmd_rsync'),
        'cmd_cp'             => $self->param('cmd_cp')?$self->param('cmd_cp'):"",
        'cmd_rm'             => $self->param('cmd_rm')?$self->param('cmd_rm'):"",
        'cmd_ssh'            => $self->param('cmd_ssh')?$self->param('cmd_ssh'):"",
        'cmd_logger'         => $self->param('cmd_logger')?$self->param('cmd_logger'):"",
        'cmd_du'             => $self->param('cmd_du')?$self->param('cmd_du'):"",
        'cmd_rsnapshot_diff' => $self->param('cmd_rsnapshot_diff')?$self->param('cmd_rsnapshot_diff'):"",
        'cmd_preexec'        => $self->param('cmd_preexec')?$self->param('cmd_preexec'):"",
        'cmd_postexec'       => $self->param('cmd_postexec')?$self->param('cmd_postexec'):"",
        # Tab - LVM Config
        'linux_lvm_cmd_lvcreate' => $self->param('linux_lvm_cmd_lvcreate')?$self->param('linux_lvm_cmd_lvcreate'):"",
        'linux_lvm_cmd_lvremove' => $self->param('linux_lvm_cmd_lvremove')?$self->param('linux_lvm_cmd_lvremove'):"",
        'linux_lvm_cmd_mount'    => $self->param('linux_lvm_cmd_mount')?$self->param('linux_lvm_cmd_mount'):"",
        'linux_lvm_cmd_umount'   => $self->param('linux_lvm_cmd_umount')?$self->param('linux_lvm_cmd_umount'):"",
        'linux_lvm_vgpath'       => $self->param('linux_lvm_vgpath')?$self->param('linux_lvm_vgpath'):"",
        'linux_lvm_snapshotname' => $self->param('linux_lvm_snapshotname')?$self->param('linux_lvm_snapshotname'):"",
        'linux_lvm_snapshotsize' => $self->param('linux_lvm_snapshotsize')?$self->param('linux_lvm_snapshotsize'):"",
        'linux_lvm_mountpath'    => $self->param('linux_lvm_mountpath')?$self->param('linux_lvm_mountpath'):"",
        # Global Config
        'rsync_numtries'         => $self->param('rsync_numtries')?$self->param('rsync_numtries'):"",
        'verbose'                => $self->param('verbose')?$self->param('verbose'):"",
        'loglevel'               => $self->param('loglevel')?$self->param('loglevel'):"",
        'logfile'                => $self->param('logfile')?$self->param('logfile'):"",
        'lockfile'               => $self->param('lockfile')?$self->param('lockfile'):"",
        'rsync_short_args'       => $self->param('rsync_short_args')?$self->param('rsync_short_args'):"",
        'rsync_long_args'        => $self->param('rsync_long_args')?$self->param('rsync_long_args'):"",
        'ssh_args'               => $self->param('ssh_args')?$self->param('ssh_args'):"",
        'du_args'                => $self->param('du_args')?$self->param('du_args'):"",
        'stop_on_stale_lockfile' => $self->param('stop_on_stale_lockfile')?$self->param('stop_on_stale_lockfile'):"off",
        'link_dest'              => $self->param('link_dest')?$self->param('link_dest'):"off",
        'sync_first'             => $self->param('sync_first')?$self->param('sync_first'):"off",
        'use_lazy_deletes'       => $self->param('use_lazy_deletes')?$self->param('use_lazy_deletes'):"off",
        # Intervals
        'retain' => \@retain,
        # Include/Exclude
        'include_file'  => $self->param('include_file')?$self->param('include_file'):"",
        'exclude_file'  => $self->param('exclude_file')?$self->param('exclude_file'):"",
        'include'       => \@include,
        'exclude'       => \@exclude,
        # Backup / Hosts 
        'backup'        => \@backup,
        # Scripts
        'backup_script' => \@backup_script,
        'backup_exec'   => \@backup_exec,
    );

    # Array with Rsnapshot config files
    my @rs_config_files = Webrsnapshot::Library::getRSConfigFiles($self->config->{rs_config});
    # Get the file id
    my $id = $self->param('rs_config_id');
    # And send everything to the ConfigHandler::saveConfig
    my $saveResult = new Webrsnapshot::ConfigHandler($self->config, $rs_config_files[$id])->saveConfig(\%config);

    # 0 - Ok
    # If returns diferent then 0, then we have a problem
    $self->flash(saved => ${$saveResult}{'exit_code'});
    $self->flash(message_text => ${$saveResult}{'message'});

    return $self->redirect_to('/'.$id.'/config');
}

# Create new rsnapshot configuration
sub touch {
    my ( $self ) = @_;

    my @backup  = ();
    my @retain  = ();
    my @include = ();
    my @exclude = ();
    my @backup_exec   = ();
    my @backup_script = ();

    my $rsync  = `which rsync`;
    my $cp     = `which cp`;
    my $rm     = `which rm`;
    my $ssh    = `which ssh`;
    my $logger = `which logger`;
    my $du     = `which du`;
    my $diff   = `which rsnapshot_diff`;

    # Build config hash
    my %config = (
        # Root
        'config_version' => '1.2',
        'snapshot_root'  => '',
        'include_conf'   => '',
        'no_create_root' => 'off',
        'one_fs'         => 'off',
        # Commands
        'cmd_rsync'          => $rsync?$rsync:"",
        'cmd_cp'             => $cp?$cp:"",
        'cmd_rm'             => $rm?$rm:"",
        'cmd_ssh'            => $ssh?$ssh:"",
        'cmd_logger'         => $logger?$logger:"",
        'cmd_du'             => $du?$du:"",
        'cmd_rsnapshot_diff' => $diff?$diff:"",
        'cmd_preexec'        => '',
        'cmd_postexec'       => '',
        # Tab - LVM Config
        'linux_lvm_cmd_lvcreate' => '',
        'linux_lvm_cmd_lvremove' => '',
        'linux_lvm_cmd_mount'    => '',
        'linux_lvm_cmd_umount'   => '',
        'linux_lvm_vgpath'       => '',
        'linux_lvm_snapshotname' => '',
        'linux_lvm_snapshotsize' => '',
        'linux_lvm_mountpath'    => '',
        # Global Config
        'rsync_numtries'         => '',
        'verbose'                => '',
        'loglevel'               => '',
        'logfile'                => '',
        'lockfile'               => '',
        'rsync_short_args'       => '-a',
        'rsync_long_args'        => '--delete --numeric-ids --relative --delete-excluded',
        'ssh_args'               => '',
        'du_args'                => '',
        'stop_on_stale_lockfile' => 'off',
        'link_dest'              => 'off',
        'sync_first'             => 'off',
        'use_lazy_deletes'       => 'off',
        # Intervals
        'retain' => \@retain,
        # Include/Exclude
        'include_file'  => '',
        'exclude_file'  => '',
        'include'       => \@include,
        'exclude'       => \@exclude,
        # Backup / Hosts 
        'backup'        => \@backup,
        # Scripts
        'backup_script' => \@backup_script,
        'backup_exec'   => \@backup_exec,
    );

    # Get the file id
    my $id = $self->stash->{id};
    # Get post variables
    my $configparams = $self->req->params->to_hash;
    # And send everything to the ConfigHandler::saveConfig
    my $saveResult = new Webrsnapshot::ConfigHandler($self->config, $self->config->{rs_config}.'/'.$configparams->{new_rs_filename})->saveConfig(\%config,"skipCheck");

    # 0 - Ok
    # If returns diferent then 0, then we have a problem
    $self->flash(saved => ${$saveResult}{'exit_code'});
    $self->flash(message_text => ${$saveResult}{'message'});

    return $self->redirect_to('/');
}

# Delete rsnapshot configuration file
sub delete {
    my ( $self ) = @_;

    # And let the ConfigHandler delete the file
    my $deleteResult = new Webrsnapshot::ConfigHandler($self->config, $self->config->{rs_config})->deleteConfig($self->stash('id'));

    # 0 - Ok
    # If returns diferent then 0, then we have a problem
    $self->flash(saved => ${$deleteResult}{'exit_code'});
    $self->flash(message_text => ${$deleteResult}{'message'});

    return $self->redirect_to('/');
}

1;
