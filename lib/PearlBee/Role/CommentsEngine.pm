package PearlBee::Role::CommentsEngine;
use Moose::Role;

has _app_config => (
    is => 'ro',
    isa => 'HashRef',
    required => 1,
);

has post_comment_count_template => (
    is => 'ro',
    isa => 'Str',
);

has comment_form_template => (
    is => 'ro',
    isa => 'Str',
);

has scripts_template => (
    is => 'ro',
    isa => 'Str',
);

has list_comments_template => (
    is => 'ro',
    isa => 'Str',
);

has comments_dashboard_link => (
    lazy => 1,
    is => 'ro',
    isa => 'Str',
    default => '',
);

1;
