package PearlBee::Dashboard;
use Dancer2 appname => 'PearlBee';
use Dancer2::Plugin::Auth::Tiny;
use Dancer2::Plugin::DBIC;

use PearlBee::Password;
use PearlBee::Dashboard::Posts;
use PearlBee::Dashboard::Users;
use PearlBee::Dashboard::Comments;
use PearlBee::Dashboard::Categories;
use PearlBee::Dashboard::Tags;
use PearlBee::Dashboard::Settings;

config->{'plugins'}{'Auth::Tiny'}{'logged_in_key'} = 'user';

get '/dashboard' => needs login => sub {
    redirect '/dashboard/posts';
};

post '/dashboard' => needs login => sub {
    my $user = resultset('User')->search({
        id => session('user_id'),
    });

    $user->status eq 'deactivated'
        or template 'admin/index'
             => { user   => $user   }
             => { layout => 'admin' };

    my $password1 = body_parameters->{'password1'};
    my $password2 = body_parameters->{'password2'};

    $password1 eq $password2
        or return template 'admin/index' => {
            user    => $user,
            warning => 'The passwords don\'t match!'
        } => { layout => 'admin' };

    my $password_hash = generate_hash($password1);
    $user->update({
        password => $password_hash->{'hash'},
        salt     => $password_hash->{'salt'},
        status   => 'activated',
    });

    template 'admin/index' => {
        user => $user
    } => { layout => 'admin' };
};

get '/edit' => needs login => sub {
    my $user = resultset('User')->from_session( session('user_id') )
        or redirect '/';

    template 'admin/profile' => {
        user => $user
    } => { layout => 'admin' };
};

post '/edit' => needs login => sub {
    my $user          = resultset('User')->from_session( session('user_id') );
    my $params        = body_parameters;
    my $first_name    = $params->{'first_name'};
    my $last_name     = $params->{'last_name'};
    my $email         = $params->{'email'};
    my $old_password  = delete $params->{'old_password'};
    my $new_password  = delete $params->{'new_password'};
    my $new_password2 = delete $params->{'new_password2'};

    my %update_parameters = map +(
        $_ => $params->{$_}
    ), qw<first_name last_name email>;

    if ( $old_password && $new_password && $new_password2 ) {
        my $generated_password = generate_hash($old_password, $user->salt);
        $generated_password->{'hash'} eq $user->password
            or return template 'admin/profile' => {
                user    => $user,
                warning => 'Incorrect old password!',
            } => { layout => 'admin' };


        $new_password eq $new_password2
            or return template 'admin/profile' => {
                user    => $user,
                warning => 'The new passwords don\'t match!',
            } => { layout => 'admin' };

        $generated_password = generate_hash($new_password);
        $update_parameters{'password'} = $generated_password->{'hash'};
        $update_parameters{'salt'}     = $generated_password->{'salt'};
    } elsif ( $old_password || $new_password || $new_password2 ) {
        return template 'admin/profile' => {
            user    => $user,
            warning => 'Must fill all password fields to update password',
        } => { layout => 'admin' };
    }

    $user->update(\%update_parameters);

    return template 'admin/profile' => {
        user    => $user,
        success => 'Your data was updated succesfully!',
    } => { layout => 'admin' };

    redirect '/dashboard/edit';
};

1;
