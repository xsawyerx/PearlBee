package PearlBee::Dashboard;
use Dancer2 appname => 'PearlBee';
use PearlBee::Dashboard::Posts;
use PearlBee::Dashboard::Users;
use PearlBee::Dashboard::Comments;
use PearlBee::Dashboard::Categories;
use PearlBee::Dashboard::Tags;

get '/dashboard' => sub {
    redirect '/dashboard/posts';
};

1;
