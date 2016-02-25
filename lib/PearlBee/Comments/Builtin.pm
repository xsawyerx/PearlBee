package PearlBee::Comments::Builtin;
use Moose;
use namespace::autoclean;
with 'PearlBee::Role::CommentsEngine';

has '+post_comment_count_tt' => (
    default => 'comments/builtin/post_comment_count.tt',
);

has '+comment_form_tt' => (
    default => 'comments/builtin/comment_form.tt',
);

has '+list_comments_tt' => (
    default => 'comments/builtin/list_comments.tt',
);

has '+comments_dashboard_link' => (
    default => sub { $_[0]->_app_config->{app_url} . '/admin/comments' },
);

__PACKAGE__->meta->make_immutable();

1;
