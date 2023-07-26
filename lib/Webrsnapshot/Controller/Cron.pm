package Webrsnapshot::Controller::Cron;

use File::Basename;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::Parameters;
use Webrsnapshot::ConfigHandler;
use Webrsnapshot::CronHandler;
use Webrsnapshot::Library;

# This action will render a template
sub index ($self) {

    # Get rs_conf_id from stash
    my $rs_config_id = $self->stash('id');
    # Array with Rsnapshot config files
    my @rs_config_files = Webrsnapshot::Library::getRSConfigFiles($self->config->{rs_config});

    my %all_configs;
    # Iterate oder all config files found
    for my $i (0 .. $#rs_config_files) {
        $all_configs{"$rs_config_files[$i]"} = new Webrsnapshot::ConfigHandler($rs_config_files[$i])->readConfig();
    }

    # Read the cron file
    my $cron_content_ref = new Webrsnapshot::CronHandler(
        $self->config->{rs_cron_file},
        \@rs_config_files
    )->getCronContent();

    # Render template "default/index.html.ep" with message
    $self->render(
        tmpl                => $self->config->{template},
        all_configs_ref     => \%all_configs,
        cron_content_ref    => $cron_content_ref,
        rs_config_files_ref => \@rs_config_files,
    );
}

# Save the cron jobs
sub save {
    my ( $self ) = @_;

    # All parameters from the post request
    my $allParams_ref = $self->req->body_params->to_hash;

    # parse email
    my $cron_email	= $allParams_ref->{'cron_email'};
    my $email_dsbl	= $allParams_ref->{'email_disabled'}?$allParams_ref->{'email_disabled'}:"off";
    if ( $email_dsbl eq "on" ) { $allParams_ref->{'cron_email'} = "#MAILTO=\"".$cron_email."\""; }
        else { $allParams_ref->{'cron_email'} = "MAILTO=\"".$cron_email."\""; }

    # Iterate over all available config files
    foreach my $k (sort keys %$allParams_ref) {
        if ($k =~ m/cronjob_/) {
            my $baseKey   = substr($k, CORE::index($k, '_')+1);
            my $cron_dsbl = $allParams_ref->{'cron_disabled_'.$baseKey}?$allParams_ref->{'cron_disabled_'.$baseKey}:"off";
            if ( $cron_dsbl eq "on" ) { $allParams_ref->{$k} =~ s/^(.*)/#$1/; }
                else { $allParams_ref->{$k} =~ s/^#(.*)/$1/; }
        }
    }



    # And send everything to the CronHandler to save
    my @saveResult = new Webrsnapshot::CronHandler(
        $self->config->{rs_cron_file}
    )->writeCronContent($allParams_ref);

    # 0 - Ok
    # 1 - error in the rsnapshot cron file
    # 3 - error while copying the rsnapshot file
    # If returns diferent then 0, then we have a problem
    $self->flash(saved => pop @saveResult);
    $self->flash(message_text => join(" ",@saveResult));

    return $self->redirect_to('/cron');
}

1;
