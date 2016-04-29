package PearlBee::Helpers::Captcha;
use Dancer2 appname => 'PearlBee';

my $captcha;

if (config->{'captcha_enabled'}) {
    require Authen::Captcha;
    $captcha = Authen::Captcha->new(
        data_folder   => config->{'captcha_folder'},
        output_folder => config->{'captcha_folder'} . '/image',
    );
}

sub new_captcha_code {
    return 1 if ! config->{'captcha_enabled'};

    my $code = $captcha->generate_code(5);

    session secret  => $code;

    # this is a hack because Google Chrome triggers GET 2 times, and it messes up the valid captcha code
    session secrets => [] unless session('secrets');
    push @{ session('secrets') }, $code;

    return $code;
}

sub check_captcha_code {
    return 1 if ! config->{'captcha_enabled'};

    my $code = shift;

    foreach my $secret ( @{ session('secrets') || [] } ) {
        if ( $captcha->check_code( $code, $secret ) == 1 ) {
            session secrets => [];
            return 1;
        }
    }

    return;
}

1;
