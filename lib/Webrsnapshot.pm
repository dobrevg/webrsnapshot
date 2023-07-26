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
        $self->log->info("Config file missing: $config_file");
        $config = $self->plugin('NotYAMLConfig', {file => 'config/webrsnapshot.example.yml'});
        $self->log->info("Load example config: config/webrsnapshot.example.yml");
    }

    # Set default values if not set
    $config->{rs_config} = $config->{rs_config}?$config->{rs_config}:"/etc/rsnapshot.conf.d";
    $self->log->info("\$config->{rs_config}: ".$config->{rs_config});

    $config->{rs_cron_file} = $config->{rs_cron_file}?$config->{rs_cron_file}:"/etc/cron.d/rsnapshot";
    $self->log->info("\$config->{rs_cron_file}: ".$config->{rs_cron_file});

    $config->{template} = $config->{template}?$config->{template}:"default";
    $self->log->info("\$config->{template}: ".$config->{template});

    $config->{session_timeout} = $config->{session_timeout}?$config->{session_timeout}:"600";
    $self->log->info("\$config->{session_timeout}: ".$config->{session_timeout});

    $config->{loglines} = $config->{loglines}?$config->{loglines}:"100";
    $self->log->info("\$config->{loglines}: ".$config->{loglines});

    $config->{timeformat} = $config->{timeformat}?$config->{timeformat}:"%T";
    $self->log->info("\$config->{timeformat}: ".$config->{timeformat});

    $config->{dateformat} = $config->{dateformat}?$config->{dateformat}:"%d.%m.%Y";
    $self->log->info("\$config->{dateformat}: ".$config->{dateformat});

    $config->{rootuser} = $config->{rootuser}?$config->{rootuser}:"root";
    $self->log->info("\$config->{rootuser}: ".$config->{rootuser});

    $config->{rootpass} = $config->{rootpass}?$config->{rootpass}:"pass";
    $self->log->info("Admin password is set");

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
    $authorized->get('/cron')->to('Cron#index');
    $authorized->post('/cron')->to('Cron#save');
    $authorized->get('/:id/config' => [id => qr/\d+/])->to('Config#index');
    $authorized->post('/:id/config' => [id => qr/\d+/])->to('Config#save');
    $authorized->get('/:id/hosts' => [id => qr/\d+/])->to('Hosts#index');
    $authorized->get('/:id/log' => [id => qr/\d+/])->to('Log#index');
    $authorized->get('/:id/host/#name' => [id => qr/\d+/])->to('Host#index');
    $authorized->get('/:id/host' => [id => qr/\d+/])->to(cb => sub($c){$c->redirect_to('/'.$c->param('id').'/hosts')});
}

1;
