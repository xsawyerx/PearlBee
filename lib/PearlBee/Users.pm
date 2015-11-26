package PearlBee::Users;
# ABSTRACT: User-related paths
use Dancer2 appname => 'PearlBee';

get '/sign-up' => sub {

};

get '/login' => sub {

};

get '/logout' => sub {

};

get '/profile' => sub {

};

prefix '/dashboard' => sub {
    get '' => sub {

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
