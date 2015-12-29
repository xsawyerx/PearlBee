package PearlBee::Dashboard::Posts;
use Dancer2 appname => 'PearlBee';
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::Auth::PearlBee;

use PearlBee::Helpers::Pagination qw<
    get_total_pages
    get_previous_next_link
    generate_pagination_numbering
>;

use URI::Escape;

prefix '/dashboard/posts' => sub {
    get '' => needs_permission view_post => sub {
        my $page        = query_parameters->{'page'} || 1;
        my $status      = query_parameters->{'status'};
        my $nr_of_rows  = 5;
        my $search_parameters = $status ? { status => $status } : {};

        my @posts       = resultset('Post')->search( $search_parameters, { order_by => { -desc => 'created_date' }, rows => $nr_of_rows, page => $page } );
        my $count       = resultset('View::Count::StatusPost')->first;

        my ($all, $publish, $draft, $trash) = $count->get_all_status_counts;

        # FIXME: temporary override of $all because "ugh"
        #        Uses the View::Count::StatusPost
        #        which doesn't allow specifying an optional post status
        #        why have two methods instead of a method with a parameter?
        $status and $all = $count->get_status_count($status);

        my $action_url = "/dashboard/posts?status=" . uri_escape($status);
        # Calculate the next and previous page link
        my $total_pages                 = get_total_pages($all, $nr_of_rows);
        my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, $action_url);

        # Generating the pagination navigation
        my $total_posts     = $all;
        my $posts_per_page  = $nr_of_rows;
        my $current_page    = $page;
        my $pages_per_set   = 7;
        my $pagination      = generate_pagination_numbering($total_posts, $posts_per_page, $current_page, $pages_per_set);

        template 'admin/posts/list' => {
            posts         => \@posts,
            trash         => $trash,
            draft         => $draft,
            publish       => $publish,
            all           => $all,
            page          => $page,
            next_link     => $next_link,
            status        => $status,
            previous_link => $previous_link,
            action_url    => $action_url,
            pages         => $pagination->pages_in_set
        } => { layout => 'admin' };
    };

    get '/new' => needs_permission create_post => sub {
        template 'admin/posts/add' => {
            categories => [ resultset('Category')->all() ],
        } => { layout => 'admin' };
    };

    post '/new' => needs_permission create_post => sub {

    };

    get '/edit/:id' => needs_permission update_post => sub {

    };

    post '/update/:id' => needs_permission update_post => sub {

    };

    post '/delete/:id' => needs_permission delete_post => sub {

    };
};

1;
