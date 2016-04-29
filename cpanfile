requires 'Moose';
requires 'Dancer2' => 0.163000;
requires 'Dancer2::Plugin::DBIC';
requires 'Dancer2::Plugin::REST';
requires 'Dancer2::Plugin::Auth::Tiny';
requires 'RBAC::Tiny' => 0.003;
requires 'DBIx::Class';
requires 'HTML::Strip';
requires 'Template::Plugin::HTML::Strip';

requires 'DateTime';
requires 'DateTime::TimeZone';

requires 'Data::GUID';
requires 'Data::Pageset';
requires 'Data::Entropy::Algorithms';
requires 'Digest';
requires 'Digest::Bcrypt';

requires 'String::Dirify';
requires 'String::Random';
requires 'String::Util';

requires 'MIME::Base64';
requires 'Email::Template';
requires 'XML::Simple';
requires 'Gravatar::URL';

# speed up Dancer2
requires 'Scope::Guard';
requires 'URL::Encode::XS';
requires 'CGI::Deurl::XS';
requires 'HTTP::Parser::XS';
requires 'Math::Random::ISAAC::XS';

# From DBIx::Class 'admin_script' group of requirements (that is, in order to
# run dbicadmin script).
# This could also be a feature, but since I suppose most people will want this,
# I'll just leave it like htis.
requires 'Getopt::Long::Descriptive'    => 0.081;
requires 'JSON::Any'                    => 1.23;
requires 'Moose'                        => 0.98;
requires 'MooseX::Types'                => 0.21;
requires 'MooseX::Types::JSON'          => 0.02;
requires 'MooseX::Types::LoadableClass' => 0.011;
requires 'MooseX::Types::Path::Class'   => 0.05;
requires 'Text::CSV'                    => 1.16;

# install using cpanm --with-feature=captcha --installdeps .
feature 'captcha', 'Use captcha for comments and user registrations' => sub {
    requires 'Authen::Captcha';
    requires 'GD';
};

# install using cpanm --with-feature=wp_import --installdeps .
feature 'wp_import', 'Import posts from WordPress' => sub {
    requires 'LWP::UserAgent';
    requires 'LWP::Simple';
    requires 'File::Path';
};
