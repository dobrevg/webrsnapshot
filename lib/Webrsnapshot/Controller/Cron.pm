package Webrsnapshot::Controller::Cron;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use Webrsnapshot::ConfigHandler;
use Webrsnapshot::CronHandler;

# This action will render a template
sub index ($self) {

	# Read the rsnapshot config file
	my %config = %{ new Webrsnapshot::ConfigHandler($self->config->{rs_config_file})->readConfig() };

	# Read the cron file
	my $cron_content_ref = new Webrsnapshot::CronHandler(
		$self->config->{rs_cron_file},
		$self->config->{rs_config_file}
	)->getCronContent();

	# Render template "default/index.html.ep" with message
	$self->render(
		tmpl => $self->config->{template},
		retains_ref => $config{retain},
		cron_content_ref => $cron_content_ref,
		rs_conf_file => $self->config->{rs_config_file},
	);
}

# Save the cron jobs
sub save {
	my ( $self ) = @_;

	my @cronjobs	= ();
	my $cron_count	= $self->param('newcron');
	my $cron_email	= $self->param('cron_email');
	my $email_dsbl	= $self->param('email_disabled')?$self->param('email_disabled'):"off";

	if ( $email_dsbl eq "on" ) { $cronjobs[0] = "#MAILTO=\"".$cron_email."\""; }
		else { $cronjobs[0] = "MAILTO=\"".$cron_email."\""; }

	for (my $k=1; $k<$cron_count; $k++){
		my $cron_dsbl = $self->param('cron_disabled_'.$k)?$self->param('cron_disabled_'.$k):"off";
		if ( $cron_dsbl eq "on" ) { $cronjobs[$k] = "#".$self->param('cronjob_'.$k); }
		else { $cronjobs[$k] = $self->param('cronjob_'.$k); }
	}

	# And send everything to the CronHandler to save
	my @saveResult = new Webrsnapshot::CronHandler(
		$self->config->{rs_cron_file},
		$self->config->{rs_config_file}
	)->writeCronContent(\@cronjobs);

	# 0 - Ok
	# 1 - error in the rsnapshot cron file
	# 3 - error while copying the rsnapshot file
	# If returns diferent then 0, then we have a problem

	return $self->redirect_to('/cron');
}

1;
