use PearlBee::Test; # imports strict, warnings, etc

mech->get_ok( '/', 'response status is 200 for /' );

done_testing;
