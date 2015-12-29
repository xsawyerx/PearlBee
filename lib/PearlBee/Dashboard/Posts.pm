package PearlBee::Dashboard::Posts;
use Dancer2 appname => 'PearlBee';
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::Auth::PearlBee;

use PearlBee::Helpers::Pagination qw<
    get_total_pages
    get_previous_next_link
    generate_pagination_numbering
>;

prefix '/dashboard/posts' => sub {
    get '' => needs_permission view_post => sub {
        my $page        = query_parameters->{'page'} || 1;
        my $nr_of_rows  = 5;
        my @posts       = resultset('Post')->search( {}, { order_by => { -desc => 'created_date' }, rows => $nr_of_rows, page => $page } );
        my $count       = resultset('View::Count::StatusPost')->first;

        my ($all, $publish, $draft, $trash) = $count->get_all_status_counts;

        # Calculate the next and previous page link
        my $total_pages                 = get_total_pages($all, $nr_of_rows);
        my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/admin/posts');

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
            previous_link => $previous_link,
            action_url    => 'admin/posts/page',
            pages         => $pagination->pages_in_set
        } => { layout => 'admin' };
    };

    get '/new' => needs_permission create_post => sub {
        1;
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
