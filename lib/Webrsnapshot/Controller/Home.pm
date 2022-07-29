package Webrsnapshot::Controller::Home;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use Webrsnapshot::ConfigHandler;

# This action will render a template
sub index ($self) {

  # Render template "default/index.html.ep" with message
  $self->render(
    tmpl           => $self->config->{template},
	rs_config_file => $self->config->{rs_config_file},
	systemInfo     => $self->getSystemInfo($self->config->{rs_config_file}),
  );
}

# Gather Info about the partition allocation
sub getSystemInfo {
	my ( $self, $rs_conf_file ) = @_;

	my $confiHandler = new Webrsnapshot::ConfigHandler($rs_conf_file);
	my $rs_configuration = new Webrsnapshot::ConfigHandler($rs_conf_file)->readConfig();

	# Get partition info and parse result
	my $partInfo = `df -h $rs_configuration->{snapshot_root} | tail -1`;
	$partInfo =~ /^(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+/;
	my %result = (
		'rs_snapshot_root'     => $rs_configuration->{snapshot_root},
		'partitionInfoDev'     => $1,
		'partitionInfoSize'    => $2,
		'partitionInfoUsed'    => $3,
		'partitionInfoFree'    => $4,
		'partitionInfoPercent' => $5,
		'partitionInfoMountPt' => $6,
	);
	return \%result;
}

1;
