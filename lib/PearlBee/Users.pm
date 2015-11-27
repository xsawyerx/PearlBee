package PearlBee::Users;
# ABSTRACT: User-related paths
use Dancer2 appname => 'PearlBee';
use Dancer2::Plugin::Auth::Tiny;
use PearlBee::Helpers::Captcha;

get '/sign-up' => sub {
    PearlBee::Helpers::Captcha::new_captcha_code();
    template signup => {};
};

post '/sign-up' => sub {
};

get '/login' => sub {
    # if registered, just display the dashboard
    session('user') or redirect '/dashboard';
    template login => {}, { layout => 'admin' };
};

post '/login' => sub {
    my $password = params->{password};
    my $username = params->{username};

    my $user = resultset('User')->search({
        username => $username,
        -or      => [
            status => 'activated',
            status => 'deactivated'
        ]
    })->first;

    $user or redirect '/login?failed=1';

    my $password_hash = generate_hash($password, $user->salt);
    $user->password eq $password_hash->{hash}
        or redirect '/login?failed=1';

    session user_id => $user->id;

    redirect('/dashboard');
};

get '/logout' => sub {
    app->destroy_session;
    redirect '/?logout=1';
};

get '/profile' => sub {

};

prefix '/dashboard' => sub {
    get '' => needs login => sub {

    };

    get '/posts' => sub {

    };

    get '/users' => sub {

    };

    get '/settings' => sub {

    };
};

prefix '/users' => sub {
    get '/edit/:id' => sub {

    };

    post '/new' => sub {

    };

    post '/update/:id' => sub {

    };

    post '/delete/:id' => sub {

    };
};

1;
