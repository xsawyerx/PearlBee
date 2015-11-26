package PearlBee;
# ABSTRACT: PearlBee Blog platform
use Dancer2 0.163000;

# load all components
use PearlBee::Posts;
use PearlBee::Users;
use PearlBee::Authors;
use PearlBee::Categories;
use PearlBee::Tags;

# main page
get '/' => sub {

};

1;
