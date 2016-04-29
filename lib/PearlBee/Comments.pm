package PearlBee::Comments;
use Dancer2 appname => 'PearlBee';
use Dancer2::Core;
use Module::Runtime qw(use_module compose_module_name);
use Carp qw(croak);

my $name            = config->{comments} || 'builtin';
my $camelized       = Dancer2::Core::camelize($name);
my $component_class = compose_module_name( 'PearlBee::Comments', $camelized );

use_module($component_class);

my $config = config->{'comments_engines'}{$name} || {};
$config->{'_app_config'} = config;
$config->{'template'}    = app->template_engine;

my $Engine = $component_class->new( $config );

if ( !$Engine->does('PearlBee::Role::CommentsEngine') ) {
    croak "Engine $name does not use role CommentsEngine";
}

hook before_template_render => sub {
    my ($tokens) = @_;
    $tokens->{'comments_engine'} = $Engine;
};

1;
