package PearlBee::Dashboard::Posts;
use Dancer2 appname => 'PearlBee';
use Dancer2::Plugin::Auth::PearlBee;

prefix '/dashboard/posts' => sub {
    # supports optional "page"
    get '' => sub {

    };

    get '/new' => needs_permission create_post => sub {
        1;
    };

    post '/new' => needs_permission create_post => sub {

    };

    get '/edit/:id' => needs_permission update_post => sub {

    };

    post '/update/:id' => needs_permission update_post => sub {

    };

    post '/delete/:id' => needs_permission delete_post => sub {

    };
};

1;
