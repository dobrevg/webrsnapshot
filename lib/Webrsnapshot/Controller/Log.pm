package Webrsnapshot::Controller::Log;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use Encode;
use File::ReadBackwards;
use Webrsnapshot::ConfigHandler;

# This action will render a template
sub index ($self) {

	# Render template "default/index.html.ep" with message
	$self->render(
		tmpl => $self->config->{template},
		log_content => $self->getLogContent($self->config->{rs_config_file}, $self->config->{loglines}),
	);
}

# Get log file content backwards
sub getLogContent {
	my ($self, $rs_conf_file, $loglines) = @_;

	my $rs_configuration = new Webrsnapshot::ConfigHandler($rs_conf_file)->readConfig();
	my $logfile = $rs_configuration->{logfile};
	my $linecounter = $loglines? $loglines:100;
	my $result;

	my $bwlogfile = File::ReadBackwards->new( $logfile ) || return $!.": $logfile";
	until ( $bwlogfile->eof ) {
		if ($linecounter-- > 0) {
			$result .= decode_utf8($bwlogfile->readline);
		} else {
			last;
		}
	}
	return $result;
}

1;
