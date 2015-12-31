package Dancer2::Plugin::Auth::PearlBee;

use strict;
use warnings;
use Dancer2::Plugin;
use URI::Escape;

register needs_permission => sub {
    my ( $dsl, $permission, $sub ) = plugin_args(@_);
    my $rbac = $dsl->config->{'rbac'};
    my $error_message = uri_escape( $rbac->{'error_message'} )
                     || "You do not have permission ($permission) to access the page";

    return sub {
        my $user = vars->{'user'}
            or $dsl->app->redirect('/login?failure="Unauthorized user"');

        $rbac->can_role( $user->role, $permission )
            or $dsl->app->redirect("/login?failure=\"$error_message\"");

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
