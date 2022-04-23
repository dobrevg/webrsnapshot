package Webrsnapshot::Controller::Authorize;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojolicious::Plugin::Authentication;

# Show login page
sub index {
	my $self = shift;

	$self->render(
		tmpl  => $self->config->{template},
		error => $self->flash('error')
	);
}

# Post redirect from login page
sub user_login {
	my $self = shift;

	my $username = $self->param('username');   # From the login form
	my $password = $self->param('password');   # From the login form

	$self->app->plugin('authentication' => {
		autoload_user   => 1,
		session_key     => 'wickedapp',
		load_user       => sub { return $self->config->{rootuser}; },
		validate_user   => sub { 
			my ($self, $username, $password) = @_; 

			my $user_key = validate_user_login($self, $username, $password);

			if ( $user_key ) {
				$self->session(user => $user_key);
				$self->session(signed => 1);
				$self->session(expiration => $self->config->{session_timeout});   # Expires this sesison in sec
				return $user_key;
			}
			else {
				return undef;
			}
		},
	});

	my $auth_key = $self->authenticate($username, $password );

	if ( $auth_key )  {
		$self->flash( message => 'Login Success.');
		return $self->redirect_to('/');
	} else {
		$self->flash( error => 'Invalid username or password.');
		$self->redirect_to('/login');
	}
}

# Validate user from config file
sub validate_user_login {
	my ($self, $username, $password) = @_;
	my $user = $self->config->{rootuser};
	if ( $username eq $user ) {
		return ( validate_password( $self->config->{rootpass}, $password ) ) ? $username:0;
	}
	return 0;
}

# To validate the Password
sub validate_password {
	my ( $user_pass, $password ) = @_;
	if ( $user_pass eq $password ) {
		return 1
	}
}

sub is_signed {
	my $self = shift;
	my $username = $self->config->{rootuser};
	# Check session if signed and user name matches
	return 1 if ( $self->session('signed') && $self->session('user') =~  /$username/ );
	$self->redirect_to('/login');
}

# Logout user
sub user_logout {
	my $self = shift;
	# Remove session and direct to logout page
	$self->session(expires => 1);  #Kill the Session
	$self->redirect_to('/');
	#$self->render(template => "myTemplates/logout");
}

1;
