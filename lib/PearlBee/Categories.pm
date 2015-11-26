package PearlBee::Categories;
# ABSTRACT: Categories-related paths
use Dancer2 appname => 'PearlBee';

prefix '/categories' => sub {
    get '/:name' => sub {

    };

    post '/new' => sub {

    };

    post '/update/:id' => sub {

    };

    post '/delete/:id' => sub {

    };
};

1;
