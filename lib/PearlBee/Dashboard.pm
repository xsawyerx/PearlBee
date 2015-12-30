package PearlBee::Dashboard;
use Dancer2 appname => 'PearlBee';
use PearlBee::Dashboard::Posts;
use PearlBee::Dashboard::Users;
use PearlBee::Dashboard::Comments;
use PearlBee::Dashboard::Categories;
use PearlBee::Dashboard::Tags;
use PearlBee::Dashboard::Settings;
use Dancer2::Plugin::Auth::Tiny;

config->{'plugins'}{'Auth::Tiny'}{'logged_in_key'} = 'user';

get '/dashboard' => needs login => sub {
    redirect '/dashboard/posts';
};

1;
