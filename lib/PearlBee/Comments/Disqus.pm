package PearlBee::Comments::Disqus;
use Moo;
use Types::Standard qw/HashRef Str/;
with 'PearlBee::Role::CommentsEngine';

has shortname => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has '+post_comment_count_template' =>
    ( default => sub {'comments/disqus/post_comment_count'}, );

has '+list_comments_template' =>
    ( default => sub {'comments/disqus/list_comments'}, );

has '+scripts_template' => ( default => sub {'comments/disqus/scripts'}, );

has '+comments_dashboard_link' =>
    ( default => sub { 'https://' . $_[0]->shortname . '.disqus.com/admin/' },
    );

no Moo;

1;
