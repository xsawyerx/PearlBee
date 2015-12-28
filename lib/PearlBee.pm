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

config->{'rbac'} = my $rbac = RBAC::Tiny->new( roles => config()->{'permissions'} );

Dancer2::Plugin::Auth::Tiny->extend(
    permission_to => sub {
        my ( $dsl, $permission, $sub ) = @_;
        return sub {
            my $user_id = $dsl->app->session('user_id')
                or $dsl->app->redirect('/login');

            my $user = resultset('User')->find({
                id     => $user_id,
                status => 'activated',
            }) or $dsl->app->redirect('/login');

            $rbac->can_role( $user->role, $permission )
                or $dsl->app->redirect('/login');

            goto &$sub;
        }
    },

    role => sub {
        my ( $dsl, $role, $sub ) = @_;
        return sub {
            my $user_id = $dsl->app->session('user_id')
                or $dsl->app->redirect('/login');

            my $user = resultset('User')->find({
                id     => $user_id,
                status => 'activated',
            }) or $dsl->app->redirect('/login');

            $user->role eq $role
                or $dsl->app->redirect('/login');

            goto &$sub;
        };
    },
);

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
