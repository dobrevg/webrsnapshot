package Webrsnapshot::Controller::Host;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use List::Util 'first';
use Webrsnapshot::ConfigHandler;

# This action will render a template
sub index ($self) {
	my $hostname = $self->param('name');
	my $rs_configuration = new Webrsnapshot::ConfigHandler($self->config->{rs_config_file})->readConfig();

	# Render template "default/index.html.ep" with message
	$self->render(
		tmpl       => $self->config->{template},
		hostname   => $hostname,
		backuproot => $rs_configuration->{snapshot_root},
		timestamps => $self->getAllLastBackupTimes($rs_configuration, $hostname),
		timeformat => $self->config->{timeformat},
		dateformat => $self->config->{dateformat},
	);
}

# Get the last backup Time in days for all hosts
# If no backup found unlimited is shown
sub getAllLastBackupTimes {
	my ( $self, $rs_configuration, $hostname ) = @_;

	my %result = ();

	# Open snapshot_root for reading and read all retain dirs
	opendir my($sr), $rs_configuration->{snapshot_root} || die "Couldn't open dir '$rs_configuration->{snapshot_root}.': $!";
	my @retain_dirs = sort grep {!/^\./} readdir $sr;
	closedir $sr; # and close it

	foreach my $retain_dir (@retain_dirs) {
		$result{$retain_dir} = (stat($rs_configuration->{snapshot_root}.$retain_dir))[9];
	}

	return \%result;
}

1;
