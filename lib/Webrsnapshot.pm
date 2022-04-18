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
  

  # Configure the application
  $self->secrets($config->{secrets});

  # spread the config in the whole app
  $self->helper(config => sub { $config });
  
  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('Home#index');
}

1;
