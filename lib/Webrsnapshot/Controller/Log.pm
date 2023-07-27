package Webrsnapshot::Controller::Log;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use Encode;
use File::ReadBackwards;
use Webrsnapshot::ConfigHandler;

# This action will render a template
sub index ($self) {

    # Render template "default/index.html.ep" with message
    $self->render(
        tmpl         => $self->config->{template},
        rs_config_id => $self->stash('id'),
        log_content  => $self->getLogContent($self->config->{rs_config}, $self->config->{loglines}),
    );
}

# Get log file content backwards
sub getLogContent {
    my ($self, $rs_config, $loglines) = @_;

    # Get rs_conf_id from stash
    my $rs_config_id = $self->stash('id');
    # Array with Rsnapshot config files
    my @rs_config_files = Webrsnapshot::Library::getRSConfigFiles($rs_config);

    my $rs_configuration = new Webrsnapshot::ConfigHandler($self->config, $rs_config_files[$rs_config_id])->readConfig();
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
