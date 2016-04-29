package PearlBee::Role::CommentsEngine;
use Moo::Role;
use Types::Standard qw/Str HashRef ConsumerOf/;
use Carp qw/croak/;
use Sub::Quote qw/quote_sub/;
use List::Util qw/first/;

has template => (
    is       => 'ro',
    isa      => ConsumerOf ['Dancer2::Core::Role::Template'],
    required => 1,
);

has _app_config => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

has post_comment_count_template => (
    is        => 'ro',
    isa       => Str,
    predicate => 1,
);

has comment_form_template => (
    is        => 'ro',
    isa       => Str,
    predicate => 1,
);

has scripts_template => (
    is        => 'ro',
    isa       => Str,
    predicate => 1,
);

has list_comments_template => (
    is        => 'ro',
    isa       => Str,
    predicate => 1,
);

has comments_dashboard_link => (
    is        => 'ro',
    isa       => Str,
    lazy      => 1,   # you might need it to set the others
    predicate => 1,
    required  => 1,
);

my @known_attrs = qw/
    post_comment_count_template
    comment_form_template
    scripts_template
    list_comments_template
    comments_dashboard_link
    /;

sub render {
    my ( $self, $chunk ) = @_;

    first { $chunk eq $_ } @known_attrs
        or croak "Cannot render $chunk, I don't have such a template name";

    my $predicate = "has_$chunk";
    return $self->$predicate
        ? $self->template->process( $self->$chunk, {}, { layout => undef } )
        : '';
}

no Moo::Role;
1;
