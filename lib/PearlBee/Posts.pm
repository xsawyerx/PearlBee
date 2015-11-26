package PearlBee::Posts;
# ABSTRCT: Posts-related paths
use Dancer2 appname => 'PearlBee';

prefix '/posts' => sub {
    get '/' => sub {

    };

    get '/:slug' => sub {

    };

    post '/new' => sub {

    };

    get '/edit/:id' => sub {

    };

    post '/update/:id' => sub {

    };

    post '/delete/:id' => sub {

    };
};

1;
