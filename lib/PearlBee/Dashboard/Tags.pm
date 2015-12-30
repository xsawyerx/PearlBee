package PearlBee::Dashboard::Tags;
use Dancer2 appname => 'PearlBee';
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::Auth::PearlBee;

use PearlBee::Helpers::Util 'string_to_slug';

prefix '/dashboard/tags' => sub {
    get '' => needs_permission view_tag => sub {
        template '/admin/tags/list' => {
            tags => [ resultset('Tag')->all ],
        } => { layout => 'admin' };
    };

    post '/add' => needs_permission create_tag => sub {
        my $name = body_parameters->{'name'};
        my $slug = string_to_slug( body_parameters->{'slug'} );

        my $found_slug_or_name = resultset('Tag')->search({
            -or => [ slug => $slug, name => $name ]
        })->first;

        $found_slug_or_name
            and return template '/admin/tags/list' => {
                warning => 'The tag name or slug already exists',
                tags    => [ resultset('Tag')->all ],
            } => { layout => 'admin' };

        my %msg;
        eval {
            resultset('Tag')->create({
                name => $name,
                slug => $slug,
            });

            $msg{'success'} = 'The category was successfully added.';

            1;
        } or do {
            # FIXME: GH#9
            my $error = $@ || 'Zombie error';
            error $error;

            $msg{'warning'} = "Could not create tag: $error";
        };

        template '/admin/tags/list' => {
            tags => [ resultset('Tag')->all ],
            %msg,
        } => { layout => 'admin' };
    };

    get '/delete/:id' => needs_permission delete_tag => sub {
        my $tag_id = route_parameters->{'id'};

        eval {
            my $tag = resultset('Tag')->find($tag_id);

            # first delete many to many dependencies
            $tag->post_tags->delete;

            # then delete the tag
            $tag->delete;

            1;
        } or do {
            # FIXME: GH#9
            my $error = $@ || 'Zombie error';
            error $error;
        };

        redirect config->{'app_url'} . '/dashboard/tags';
    };


    get '/edit/:id' => needs_permission edit_tag => sub {
        my $tag_id = route_parameters->{'id'};

        template '/admin/tags/list' => {
            tag  => resultset('Tag')->find($tag_id),
            tags => [ resultset('Tag')->all ],
        } => { layout => 'admin' };
    };

    post '/edit/:id' => needs_permission edit_tag => sub {
        my $tag_id = route_parameters->{'id'};
        my $name   = body_parameters->{'name'};
        my $tag    = resultset('Tag')->find($tag_id);
        my $slug   = string_to_slug( body_parameters->{'slug'} );
        my $params = {};

        my $found_slug = resultset('Tag')->search({
            id   => { '!=' => $tag_id },
            slug => $slug,
        })->first and $params->{'warning'} = 'The tag slug already exists';

        my $found_name = resultset('Tag')->search({
            id   => { '!=' => $tag_id },
            name => $name,
        })->first and $params->{'warning'} = 'The tag name already exists';

        $params->{'warning'} or eval {
            $tag->update({
                name => $name,
                slug => $slug
            });

            $params->{'success'} = 'The tag was updated successfully';

            1;
        } or do {
            # FIXME: GH#9
            my $error = $@ || 'Zombie error';
            error $error;
            redirect '/dashboard/tags';
        };

        template '/admin/tags/list' => {
            tag  => $tag,
            tags => [ resultset('Tag')->all ],
        } => { layout => 'admin' };
    };
};

1;
