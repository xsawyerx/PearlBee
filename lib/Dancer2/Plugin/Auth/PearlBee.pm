package Dancer2::Plugin::Auth::PearlBee;

use strict;
use warnings;
use Dancer2::Plugin;

register needs_permission => sub {
    my ( $dsl, $permission, $sub ) = plugin_args(@_);
    my $rbac = $dsl->config->{'rbac'};

    return sub {
        my $user_id = $dsl->app->session->read('user_id')
            or $dsl->app->redirect('/login');

        my $user = resultset('User')->from_session($user_id)
            or $dsl->app->redirect('/login');

        $rbac->can_role( $user->role, $permission )
            or $dsl->app->redirect('/login');

        var user => $user;

        goto &$sub;
    }
};

register needs_role => sub {
    my ( $dsl, $role, $sub ) = @_;
    return sub {
        my $user_id = $dsl->app->session('user_id')
            or $dsl->app->redirect('/login');

        my $user = resultset('User')->from_session($user_id)
            or $dsl->app->redirect('/login');

        $user->role eq $role
            or $dsl->app->redirect('/login');

        var user => $user;

        goto &$sub;
    };
};

register_plugin;

1;
