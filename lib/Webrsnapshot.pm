package Webrsnapshot;

use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup ($self) {

  my $config_file = 'config/webrsnapshot.yml';
  my $config;
  if (-f $config_file) {
    # Load configuration from config file if exists
    $config = $self->plugin('NotYAMLConfig', {file => $config_file});
    $self->log->info("Loaded config file: ".$config_file);
  } else {
    # Or set default values
    $self->log->info("Exit: Config file missing: ".$config_file);
    exit 1;
  }

  # Configure the application
  $self->secrets($config->{secrets});

  # Router
  my $r = $self->routes;

  # Login route to controler
  $r->get('/login')->to('Authorize#index');
  $r->post('/login')->to('Authorize#user_login');
  $r->get('/logout')->to('Authorize#user_logout');

  # And everything else only for signed user
  my $authorized = $r->under('/')->to('Authorize#is_signed');
  $authorized->get('/')->to('Home#index');
  $authorized->get('/hosts')->to('Hosts#index');
  $authorized->get('/host/#name')->to('Host#index');
  $authorized->get('/host')->to(cb => sub($c){$c->redirect_to('/hosts')});
  $authorized->get('/log')->to('Log#index');
  $authorized->get('/cron')->to('Cron#index');
  $authorized->post('/cron')->to('Cron#save');
  $authorized->get('/config')->to('Config#index');
  $authorized->post('/config')->to('Config#save');
}

1;
