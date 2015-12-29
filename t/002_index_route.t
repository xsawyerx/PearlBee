use strict;
use warnings;
use PearlBee::Test;

my $mech = mech;

$mech->get_ok('/', 'response status is 200 for /');

done_testing;
