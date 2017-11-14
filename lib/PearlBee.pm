package PearlBee;

# ABSTRACT: PearlBee Blog platform
use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;

BEGIN {
    our $is_static = config->{static} || '';
    use if !$PearlBee::is_static, 'PearlBee::Dashboard';
}

# has to be *after* the configuration is set above
use Dancer2::Plugin::Auth::PearlBee;

# load all components
use PearlBee::Posts;
use PearlBee::Users;
use PearlBee::Authors;
use PearlBee::Categories;
use PearlBee::Tags;
use PearlBee::Comments;

hook before => sub {
    my $settings = resultset('Setting')->first;
    set multiuser => $settings->multiuser;
    set blog_name => $settings->blog_name;
    set app_url   => config->{'app_url'}; # FIXME why oh why?

    if ( my $id = session->read('user_id') ) {
        var user => resultset('User')->from_session($id);
    }

    if ( request->dispatch_path =~ /^(.*)\.html$/ ) { forward $1; }
};

# main page
get '/' => sub {
    forward '/posts';
};

1;
