package PearlBee::Dashboard;
use Dancer2 appname => 'PearlBee';
use PearlBee::Dashboard::Posts;
use PearlBee::Dashboard::Users;
use PearlBee::Dashboard::Comments;

get '/dashboard' => sub {
    redirect '/dashboard/posts';
};

1;
