package PearlBee::Dashboard::Settings;
use Dancer2 appname => 'PearlBee';
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::Auth::PearlBee;

use PearlBee::Helpers::Util qw/generate_crypted_filename/;
use PearlBee::Helpers::Import;

use POSIX       'tzset';
use XML::Simple ':strict';
use DateTime::TimeZone;

get '/dashboard/settings' => needs_permission view_setting => sub {
    my $settings  = resultset('Setting')->first;
    my @timezones = DateTime::TimeZone->all_names;

    template 'admin/settings/index' => {
        setting   => $settings,
        timezones => \@timezones,
    } => { layout => 'admin' };
};

post '/dashboard/settings/save' => needs_permission update_setting => sub {
    my $params    = body_parameters;
    my $path       = $params->{'path'};
    my $timezone  = $params->{'timezone'};
    my $blog_name = $params->{'blog_name'};

    # bool to 0 or 1
    my $social_media = int !! $params->{'social_media'};
    my $multiuser    = int !! $params->{'multiuser'};

    my %msg;
    my $settings;
    eval {
        $settings = resultset('Setting')->first;

        $settings->update({
            timezone     => $timezone,
            social_media => ($social_media ? '1' : '0'),
            multiuser    => ($multiuser ? '1' : '0'),
            blog_name    => $blog_name
        });

        $msg{'success'} = 'The settings have been saved!';

        1;
    } or do {
        # FIXME: GH#9
        my $error = $@ || 'Zombie error';
        error $error;
        $msg{'warning'} = 'Could not save settings';
    };

    template 'admin/settings/index' => {
        setting   => $settings,
        timezones => [ DateTime::TimeZone->all_names ],
        %msg,
    } => { layout => 'admin' };
};

get '/dashboard/settings/import' => needs_permission import => sub {
    template 'admin/settings/import' => {} => { layout => 'admin' };
};

post '/dashboard/settings/wp_import' => needs_permission import => sub {
    my $import = upload('source')
        or return template 'admin/settings/import' => {
            error => 'No file chosen for import',
        } => { layout => 'admin' };

    my $import_filename = generate_crypted_filename();
    my ($ext)           = $import->filename =~ /(\.[^.]+)$/; # extract the extension
    $ext                = lc $ext;

    $ext eq '.xml'
        or return template 'admin/settings/import' => {
            error   => 'File format not supported. Please choose an .xml file!'
        } => { layout => 'admin' };

    $import_filename .= $ext;
    $import->copy_to( config->{'import_folder'} . $import_filename );

    my $xml_handler = XML::Simple->new();
    my $parsed_file = $xml_handler->XMLin(
        config->{'import_folder'} . $import_filename,
        ForceArray => 0,
        KeyAttr    => 0,
    );

    $parsed_file
        or return template 'admin/settings/import' => {
            error   => 'File format not supported. Please choose an .xml file!'
        } => { layout => 'admin' };

    my $import_handler = PearlBee::Helpers::Import->new(
        args => {
            parsed_file => $parsed_file,
            session     => session(),
        },
    );

    my $import_response =
          ( $import_handler->run_wp_import() )
        ? { success => 'Blog content successfuly imported!' }
        : { error   => 'There has been a problem with the import. Please contact support.' };

    template 'admin/settings/import'
        => $import_response => { layout => 'admin' };
};

1;
