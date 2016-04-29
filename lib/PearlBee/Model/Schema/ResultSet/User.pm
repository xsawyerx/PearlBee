package  PearlBee::Model::Schema::ResultSet::User;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub from_session {
    my ( $self, $id, %search_args ) = @_;
    return $self->find(
        {
            id     => $id,
            status => 'activated',
            %search_args,
        }
    );
}

1;
