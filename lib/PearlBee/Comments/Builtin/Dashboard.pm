package PearlBee::Comments::Builtin::Dashboard;
use Dancer2 appname => 'PearlBee';
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::Auth::PearlBee;

use PearlBee::Helpers::Pagination qw<
    get_total_pages
    get_previous_next_link
    generate_pagination_numbering
>;

use URI::Escape;

sub change_comment_state {
    my ( $id, $state ) = @_;
    my $post = resultset('Comment')->find($id);
    my $user = var('user');

    # FIXME: these methods check if the user is authorized
    #        we should put this action elsewhere
    eval {
        $post->$state($user);
        1;
    } or do {
        # FIXME: don't just report the error, show the user as well
        #        GH#9
        my $error = $@ || 'Zombie error';
        error $error;
    };

    return request->header('Referer') || '/dashboard/comments';
}

prefix '/dashboard/comments' => sub {
    get '/?' => needs_permission view_comment => sub {
        my $page              = query_parameters->{'page'}   || 1;
        my $status            = query_parameters->{'status'} || '';
        my $nr_of_rows        = 5;
        my $search_parameters = $status ? { status => $status } : {};

        my @comments = resultset('Comment')->search($search_parameters, { order_by => { -desc => "comment_date" }, rows => $nr_of_rows, page => $page });
        my $count    = resultset('View::Count::StatusComment')->first;

        my ($all, $approved, $trash, $spam, $pending) = $count->get_all_status_counts;
        my $status_count                              = $count->get_status_count($status);

        # FIXME: temporary override of $all because "ugh"
        #        Uses the View::Count::StatusPost
        #        which doesn't allow specifying an optional post status
        #        why have two methods instead of a method with a parameter?
        $status and $all = $count->get_status_count($status);

        
        my $action_url = "/dashboard/comments?status=" . uri_escape($status);
        # Calculate the next and previous page link
        my $total_pages                 = get_total_pages($all, $nr_of_rows);
        my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, $action_url);

        # Generating the pagination navigation
        my $total_comments  = $all;
        my $posts_per_page  = $nr_of_rows;
        my $current_page    = $page;
        my $pages_per_set   = 7;
        my $pagination      = generate_pagination_numbering($total_comments, $posts_per_page, $current_page, $pages_per_set);


        template '/admin/comments/list' => {
            comments      => \@comments,
            all           => $all,
            approved      => $approved,
            spam          => $spam,
            pending       => $pending,
            trash         => $trash,
            page          => $page,
            next_link     => $next_link,
            previous_link => $previous_link,
            action_url    => $action_url,
            pages         => $pagination->pages_in_set
        } => { layout => 'admin' };
    };

    foreach my $state (qw<approve trash spam pending>) {
        get "/$state/:id" => needs_permission update_comment => sub {
            my $new_url = change_comment_state(
                route_parameters->{'id'},
                $state,
            );

            redirect $new_url;
        };
    }
};

1;
