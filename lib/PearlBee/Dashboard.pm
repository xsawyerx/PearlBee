package PearlBee::Dashboard;
use Dancer2;
use PearlBee::Dashboard::Posts;
use PearlBee::Dashboard::Users;

get '/dashboard' => sub {
    redirect '/dashboard/posts';
};

1;
