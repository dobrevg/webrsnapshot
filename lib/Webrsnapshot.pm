package Webrsnapshot;

use Mojo::Base 'Mojolicious', -signatures;


# This method will run once at server start
sub startup ($self) {

  my $config_file = "config/webrsnapshot.yml";
  my $config;
  if (-f $config_file) {
    # Load configuration from config file if exists
    $config = $self->plugin('NotYAMLConfig', {file => $config_file});
    $self->log->info("Loaded config file: ".$config_file);
  } else {
    # Or set default values
    $config = $self->plugin('NotYAMLConfig', {file => "config/webrsnapshot.example.yml"});
    $self->log->info("Loaded config file: config/webrsnapshot.example.yml");
  }

  $self->sessions->default_expiration(3600); # set expiry to 1 hour

  # Configure the application
  $self->secrets($config->{secrets});

  # spread the config in the whole app
  $self->helper(config => sub { $config });
  
  # Router
  my $r = $self->routes;

  # Login route to controler
  $r->get('/login')->to('Authorize#index');
  $r->post('/login')->to('Authorize#user_login');
  $r->get('/logout')->to('Authorize#user_logout');

  # And everything else only for signed user
  my $authorized = $r->under('/')->to('Authorize#is_signed');
  $authorized->get('/')->to('Home#index');
}

1;
