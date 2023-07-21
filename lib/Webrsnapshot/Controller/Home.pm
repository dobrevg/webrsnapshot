package Webrsnapshot::Controller::Home;

use File::Basename;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Webrsnapshot::ConfigHandler;

# This action will render a template
sub index ($self) {

  # Render template "default/index.html.ep" with message
  $self->render(
    tmpl           => $self->config->{template},
	rs_config_file => $self->config->{rs_config_file},
	systemInfoArr  => $self->getSystemInfo($self->config->{rs_config_file}),
  );
}

# Gather Info about the partition allocation
sub getSystemInfo {
	my ( $self, $rs_config_file ) = @_;
	my @rs_config_files = ();

	if(-d $rs_config_file) {
		# the rsnapshot config files are in one directory
		$self->log->info("Rsnapshot config directory: ".$rs_config_file);
		@rs_config_files = glob($rs_config_file."/*.conf");
		$self->log->info("Config files detected: " . join(", ", @rs_config_files));
	}
	elsif(-f $rs_config_file) {
		# Just one rsnapshot config file
		$self->log->info("Rsnapshot config file: ".$rs_config_file);
		@rs_config_files[0] = $rs_config_file;
	} 
	else {
		$self->log->error("Rsnapshot config: Neither a file nor a directory was found.");
		exit 1;
	}

	my @result = ();
	# Iterate oder all config files found
	for my $i (0 .. $#rs_config_files) {
		# Get filename from path
		my $filename = basename($rs_config_files[$i]);
		# Get the configuraiton saved in the file
		my $rs_configuration = new Webrsnapshot::ConfigHandler($rs_config_files[$i])->readConfig();
		# Get partition info and parse result
		my $partInfo = `df -h $rs_configuration->{snapshot_root} | tail -1`;
		$partInfo =~ /^(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+(.*[^\s+])\s+/;
		my %systemInfo = (
			'rs_filename'		   => $filename,
			'rs_snapshot_root'     => $rs_configuration->{snapshot_root},
			'partitionInfoDev'     => $1,
			'partitionInfoSize'    => $2,
			'partitionInfoUsed'    => $3,
			'partitionInfoFree'    => $4,
			'partitionInfoPercent' => $5,
			'partitionInfoMountPt' => $6,
		);
    	
		# Add systeminfo
		push @result, \%systemInfo;
	}	
	return \@result;
}

1;
