package Webrsnapshot::Controller::Home;

use File::Basename;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Webrsnapshot::Library;

# This action will render a template
sub index ($self) {

    # Render template "default/index.html.ep" with message
    $self->render(
      tmpl          => $self->config->{template},
      systemInfoArr => $self->getSystemInfo($self->config->{rs_config}),
    );
}

# Gather Info about the partition allocation
sub getSystemInfo {
    my ( $self, $rs_config ) = @_;

    # Array with Rsnapshot config files
    my @rs_config_files = Webrsnapshot::Library::getRSConfigFiles($rs_config);

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
            'rs_filename'          => $filename,
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
