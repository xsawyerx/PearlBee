package PearlBee;
# ABSTRACT: PearlBee Blog platform
use Dancer2 0.163000;

# load all components
use PearlBee::Posts;
use PearlBee::Users;
use PearlBee::Authors;
use PearlBee::Categories;
use PearlBee::Tags;

# template parameters
hook before_template => sub {
    my $tokens = shift;

    $tokens->{'blog_name'} = resultset('Setting')->first->blog_name;
    $tokens->{'app_url'}   = config->{'app_url'};
};

# main page
get '/' => sub {
    forward '/posts';
};

1;
