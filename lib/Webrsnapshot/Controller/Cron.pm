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

	# print join("\n",@cron_content),"\n";
# 	foreach my $key (keys %config)
# {
#   print "$key => $config{$key}\n";
# }

	# Render template "default/index.html.ep" with message
	$self->render(
		tmpl => $self->config->{template},
		retains_ref => $config{retain},
		cron_content_ref => $cron_content_ref,
		rs_conf_file => $self->config->{rs_config_file},
	);
}

1;
