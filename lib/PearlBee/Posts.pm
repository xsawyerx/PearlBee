package PearlBee::Posts;
# ABSTRCT: Posts-related paths
use Dancer2 appname => 'PearlBee';
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::Auth::PearlBee;

use PearlBee::Helpers::Util       qw<map_posts>;
use PearlBee::Helpers::Pagination qw<get_total_pages get_previous_next_link>;
use PearlBee::Helpers::Captcha;

sub get_comments {
    my $post = shift;

    PearlBee::Helpers::Captcha::new_captcha_code();

    # Grab the approved comments for this post and the corresponding reply comments
    my @comments;
    @comments = resultset('Comment')->search({ post_id => $post->id, status => 'approved', reply_to => undef }) if ( $post );
    foreach my $comment (@comments) {
        my @comment_replies = resultset('Comment')->search({ reply_to => $comment->id, status => 'approved' }, {order_by => { -asc => "comment_date" }});
        foreach my $reply (@comment_replies) {
            my $el;
            map { $el->{$_} = $reply->$_ } ('avatar', 'fullname', 'comment_date', 'content');
            $el->{uid}->{username} = $reply->uid->username if $reply->uid;
            push(@{$comment->{comment_replies}}, $el);
        }
    }

    return @comments;
}

prefix '/posts' => sub {
    get '' => sub {
        my $nr_of_rows  = config->{'posts_on_page'}  || 5; # Number of posts per page
        my $page        = query_parameters->{'page'} || 1; # for paging
        my @posts       = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => $nr_of_rows, page => $page });
        my $nr_of_posts = resultset('Post')->search({ status => 'published' })->count;
        my @tags        = resultset('View::PublishedTags')->all();
        my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
        my @recent      = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
        my @popular     = resultset('View::PopularPosts')->search({}, { rows => 3 });

        # extract demo posts info
        my @mapped_posts = map_posts(@posts);

        # Calculate the next and previous page link
        my $total_pages                 = get_total_pages($nr_of_posts, $nr_of_rows);
        my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages);

        template 'index' => {
            posts         => \@mapped_posts,
            recent        => \@recent,
            popular       => \@popular,
            tags          => \@tags,
            categories    => \@categories,
            page          => $page,
            total_pages   => $total_pages,
            previous_link => $previous_link,
            next_link     => $next_link
        };
    };

    get '/new' => needs_permission create_post => sub {
        1;
    };

    get '/new' => needs permission_to => create_post => sub {

    };

    post '/new' => needs permission_to => create_post => sub {

    };

    get '/edit/:id' => needs permission_to => update_post => sub {

    };

    post '/update/:id' => needs permission_to => update_post => sub {

    };

    post '/delete/:id' => needs permission_to => delete_post => sub {

    };
};

get '/post/:slug' => sub {
    my $slug       = route_parameters->{'slug'};
    my $post       = resultset('Post')->find({ slug => $slug });
    my $settings   = resultset('Setting')->first;
    my @tags       = resultset('View::PublishedTags')->all();
    my @categories = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });
    my @recent     = resultset('Post')->search({ status => 'published' },{ order_by => { -desc => "created_date" }, rows => 3 });
    my @popular    = resultset('View::PopularPosts')->search({}, { rows => 3 });

    template post => {
        post       => $post,
        recent     => \@recent,
        popular    => \@popular,
        categories => \@categories,
        comments   => [ get_comments($post) ],
        setting    => $settings,
        tags       => \@tags,
      };
};

1;
