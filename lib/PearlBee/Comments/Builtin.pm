package PearlBee::Comments::Builtin;
use Moo;
use PearlBee::Comments::Builtin::AddComment;
use PearlBee::Comments::Builtin::Dashboard;

with 'PearlBee::Role::CommentsEngine';

has '+post_comment_count_template' => (
    default => sub { 'comments/builtin/post_comment_count.tt' },
);

has '+comment_form_template' => (
    default => sub { 'comments/builtin/comment_form.tt' },
);

has '+list_comments_template' => (
    default => sub { 'comments/builtin/list_comments.tt' },
);

has '+comments_dashboard_link' => (
    default => sub { $_[0]->_app_config->{app_url} . '/admin/comments' },
);

no Moo;
1;
