package PearlBee::Dashboard::Categories;
use Dancer2 appname => 'PearlBee';
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::Auth::PearlBee;

prefix '/dashboard/categories' => sub {
    get '/?' => needs_permission view_category => sub {
        my @categories = resultset('Category')->search({
            name => { '!=' => 'Uncategorized'}
        });

        template '/admin/categories/list' => {
            categories => \@categories,
        } => { layout => 'admin' };
    };

    post '/add' => needs_permission create_category => sub {
        my $name   = body_parameters->{'name'};
        my $slug   = string_to_slug( body_parameters->{'slug'} );
        my $params = {};

        my $found_slug_or_name = resultset('Category')->search({
            -or => [ slug => $slug, name => $name ]
        })->first;

        # FIXME: when we have a proper notification system,
        #        this should actually redirect to /dashboard/categories
        #        with the warning
        $found_slug_or_name
            and return template '/admin/categories/list' => {
                categories => [
                    resultset('Category')->search({
                        name => { '!=' => 'Uncategorized' }
                    })
                ],

                warning => 'The category name or slug already exists',
            };

        eval {
            my $user     = var('user');
            my $category = resultset('Category')->create({
                name    => $name,
                slug    => $slug,
                user_id => $user->{'id'},
            });

            1;
        } or do {
            # FIXME: GH#9
            my $error = $@ || 'Zombie error';
            error $error;
        };

        # FIXME: proper notification as above :)
        template '/admin/categories/list' => {
            success    => 'The cateogry was successfully added.',
            categories => [
                resultset('Category')->search({
                    name => { '!=' => 'Uncategorized' }
                }),
            ],
        } => { layout => 'admin' };
    };

    get '/delete/:id' => needs_permission delete_category => sub {
        my $id = route_parameters->{'id'};

        eval {
            my $category = resultset('Category')->find( $id );
            $category->safe_cascade_delete();

            1;
        } or do {
            # FIXME: GH#9
            my $error = $@ || 'Zombie error';
            error $error;
            return template '/admin/categories/list' => {
                warning    => 'Something went wrong.',
                categories => [
                    resultset('Category')->search({
                        name => { '!=' => 'Uncategorized' }
                    })
                ],
            } => { layout => 'admin' };
        };

        redirect config->{'app_url'} . '/dashboard/categories';
    };

    get '/edit/:id' => needs_permission update_category => sub {
        my $category_id = route_parameters->{'id'};

        template '/admin/categories/list' => {
            category   => resultset('Category')->find($category_id),
            categories => [
                resultset('Category')->search({
                    name => { '!=' => 'Uncategorized' }
                })
            ],
        } => { layout => 'admin' };
    };

    post '/edit/:id' => needs_permission update_category => sub {
        my $category_id = route_parameters->{'id'};
        my $name        = body_parameters->{'name'};
        my $category    = resultset('Category')->find($category_id);

        my $params     = {};
        my $slug       = string_to_slug( body_parameters->{'slug'} );
        my $found_slug = resultset('Category')->search({
            id   => { '!=' => $category_id },
            slug => $slug,
        })->first and $params->{'warning'} = 'The category slug already exists';

        my $found_name = resultset('Category')->search({
            id   => { '!=' => $category_id },
            name => $name,
        })->first and $params->{'warning'} = 'The category name already exists';

        $params->{'warning'} or eval {
            $category->update({
                name => $name,
                slug => $slug
            });

            $params->{'success'} = 'The category was updated successfully';

            1;
        } or do {
            # FIXME: GH#9
            my $error = $@ || 'Zombie error';
            error $error;
            redirect '/dashboard/categories';
        };

        template '/admin/categories/list' => {
            category   => $category,
            categories => [
                resultset('Category')->search({
                    name => { '!=' => 'Uncategorized' }
                }),
            ],
        } => { layout => 'admin' };
    };
};

1;
