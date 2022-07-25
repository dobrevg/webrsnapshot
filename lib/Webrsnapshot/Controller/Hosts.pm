package Webrsnapshot::Controller::Hosts;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use List::Util 'first';
use Webrsnapshot::ConfigHandler;

# This action will render a template
sub index ($self) {

	# Render template "default/index.html.ep" with message
	$self->render(
		tmpl             => $self->config->{template},
		timestampHashRef => $self->getLastBackupTime($self->config->{rs_config_file}),
	);
}

# Get the last backup Time in days for all hosts
# If no backup found unlimited is shown
sub getLastBackupTime {
	my ( $self, $rs_conf_file ) = @_;

	our $rs_configuration = new Webrsnapshot::ConfigHandler($rs_conf_file)->readConfig();
	my $backups = $rs_configuration->{backup};

	# Sort all hostnames and assign the values to an array	
	our @hostnames = ( sort keys (%$backups) );

	# Create a hash with hostname as key
	my %result = map { $_ => {} } @hostnames;

	# Open snapshot_root for reading and read all retain dirs
	opendir my($sr), $rs_configuration->{snapshot_root} || die "Couldn't open dir '$rs_configuration->{snapshot_root}': $!";
	my @retain_dirs = sort grep {!/^\./} readdir $sr;
	closedir $sr; # and close it

	foreach my $retain_dir (@retain_dirs) {
		foreach my $hostname (@hostnames) {
			$result{$hostname}{$retain_dir} = (stat($rs_configuration->{snapshot_root}."/".$retain_dir))[9];
		}
	}
	return \%result;
}

1;
