package PearlBee;
# ABSTRACT: PearlBee Blog platform
use Dancer2 0.163000;

# load all components
use PearlBee::Posts;
use PearlBee::Users;
use PearlBee::Authors;
use PearlBee::Categories;
use PearlBee::Tags;
use Dancer2::Plugin::DBIC;

hook before => sub {
    my $settings = resultset('Setting')->first;
    set multiuser => $settings->multiuser;
    set blog_name => $settings->blog_name;
    set app_url   => config->{'app_url'}; # FIXME why oh why?
};

# main page
get '/' => sub {
    forward '/posts';
};

1;
