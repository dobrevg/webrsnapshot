package Webrsnapshot::Controller::Home;
use Mojo::Base 'Mojolicious::Controller', -signatures;

# This action will render a template
sub index ($self) {

  # Render template "default/index.html.ep" with message
  $self->render(
    tmpl=> $self->config->{template},
    msg => 'Welcome to the Home#index!'
  );
}

1;
