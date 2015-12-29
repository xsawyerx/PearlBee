package PearlBee::Test;
use strict;
use warnings;
use Test::More ();
use PearlBee;
use PearlBee::Model::Schema;
use Import::Into;
use Test::WWW::Mechanize::PSGI;
use HTTP::Cookies;
use parent 'Exporter';

our @EXPORT = ('app', 'mech', 'db');

sub import {
    my ($caller) = @_;

    shift->export_to_level(1);
    $_->import::into(1) for qw(strict warnings Test::More);
}

sub mech {
    my $mech = Test::WWW::Mechanize::PSGI->new( app => PearlBee->to_app );
    $mech->cookie_jar(HTTP::Cookies->new);
    return $mech;
}

sub app { PearlBee::app() }

sub db {
    my $config = PearlBee::config->{plugins}{DBIC}{default};
    return PearlBee::Model::Schema->connect(
        $config->{dsn},
        $config->{user},
        $config->{password}
    );
}

1;
