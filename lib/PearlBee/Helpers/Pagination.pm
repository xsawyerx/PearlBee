package PearlBee::Helpers::Pagination;

use strict;
use warnings;
use Data::Pageset;
use URI;
use URI::QueryParam;

require Exporter;
our @ISA 		= qw(Exporter);
our @EXPORT_OK 	= qw/get_total_pages get_previous_next_link generate_pagination_numbering/;

=head

Return the total number of pages

=cut

sub get_total_pages {
	my ($nr_of_items, $nr_of_rows) = @_;

	my $total_pages = ( ($nr_of_items / $nr_of_rows) != int($nr_of_items / $nr_of_rows) ) ? int($nr_of_items / $nr_of_rows) + 1 : ($nr_of_items / $nr_of_rows);

	return $total_pages;
}

=head

Generate the urls for the next and previous buttons

=cut

sub get_previous_next_link {
    my ($page, $total_pages, $custom_link) = @_;
    my ($previous_link, $next_link) = ('#', '#');

    my $uri = URI->new($custom_link);

    if ($page > 1) {
        $previous_link = $uri->clone;
        $previous_link->query_param( page => $page  - 1 );
    }

    if ($page < $total_pages) {
        $next_link = $uri->clone;
        $next_link->query_param( page => $page  + 1 );
    }

    return ($previous_link, $next_link);
}

=head

Generate the pagination numbering for the UI

=cut

sub generate_pagination_numbering {
	my ($total_entries, $entries_per_page, $current_page, $pages_per_set) = @_;

	my $paging_jump = Data::Pageset->new({
	  'total_entries'       => $total_entries, 
	  'entries_per_page'    => $entries_per_page, 
	  # Optional, will use defaults otherwise.
	  'current_page'        => $current_page,
	  'pages_per_set'       => $pages_per_set,
	  'mode'                => 'slide'
	}); 

	return $paging_jump;	
}

1;
