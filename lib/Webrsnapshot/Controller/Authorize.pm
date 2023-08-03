package Webrsnapshot::Controller::Authorize;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojolicious::Plugin::Authentication;
use Crypt::PBKDF2;

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

    # Define the 
    my $pbkdf2 = Crypt::PBKDF2->new(
        hash_class => 'HMACSHA3',
        hash_args => {
            sha_size => 256,
        },
        iterations => 10000,
        salt_len => 10,
    );

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
		return $self->redirect_to('/');
	} else {
		$self->flash( login_failed => 'Invalid username or password.');
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
    my ( $config_pass, $password ) = @_;

    # User PBKDF2 encryptor
    my $pbkdf2 = Crypt::PBKDF2->new(
        hash_class => 'HMACSHA3',
        hash_args => {
            sha_size => 256,
        },
        iterations => 10000,
        salt_len => 10,
    );
	if ( $pbkdf2->validate($config_pass, $password) ) {
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
