package PearlBee;
# ABSTRACT: PearlBee Blog platform
use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::Auth::Tiny;

# load all components
use PearlBee::Posts;
use PearlBee::Users;
use PearlBee::Authors;
use PearlBee::Categories;
use PearlBee::Tags;

use RBAC::Tiny;

config->{'rbac'} = RBAC::Tiny->new( roles => config()->{'permissions'} || {} );

hook before => sub {
    my $settings = resultset('Setting')->first;
    set multiuser => $settings->multiuser;
    set blog_name => $settings->blog_name;
    set app_url   => config->{'app_url'}; # FIXME why oh why?
    if ( request->dispatch_path =~ /^(.*)\.html$/ ) { forward $1; }
};

# main page
get '/' => sub {
    forward '/posts';
};

1;
