use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Deep;
use List::MoreUtils qw( first_index );

BEGIN {
    {
        package MyApp::Schema::Result::Artist;
        use base 'DBIx::Class::Core';
        __PACKAGE__->table('people');
        __PACKAGE__->add_columns(
            id   => 'int',
            type => 'int',
        );
        __PACKAGE__->set_primary_key('id');
        __PACKAGE__->has_many('albums', 'MyApp::Schema::Result::Album', 'artist_id');
    }

    {
        package MyApp::Schema::Result::Producer;
        use base 'DBIx::Class::Core';
        __PACKAGE__->table('people');
        __PACKAGE__->add_columns(
            id   => 'int',
            type => 'int',
        );
        __PACKAGE__->set_primary_key('id');
        __PACKAGE__->has_many('albums', 'MyApp::Schema::Result::Producer', 'producer_id');
    }

    {
        package MyApp::Schema::Result::Album;
        use base 'DBIx::Class::Core';
        __PACKAGE__->table('albums');
        __PACKAGE__->add_columns(
            id          => 'int',
            artist_id   => 'int',
            producer_id => 'int',
        );
        __PACKAGE__->set_primary_key('id');
        __PACKAGE__->belongs_to('artist',   'MyApp::Schema::Result::Artist',   'artist_id');
        __PACKAGE__->belongs_to('producer', 'MyApp::Schema::Result::Producer', 'producer_id');
    }

    {
        package MyApp::Schema;
        use base 'DBIx::Class::Schema';
        __PACKAGE__->register_class(Artist   => 'MyApp::Schema::Result::Artist');
        __PACKAGE__->register_class(Album    => 'MyApp::Schema::Result::Album');
        __PACKAGE__->register_class(Producer => 'MyApp::Schema::Result::Producer');
        __PACKAGE__->load_components('TopoSort');
    }
}

use Test::DBIx::Class qw(:resultsets);

sub is_before {
    my ($list, $first, $second) = @_;
    my $f = first_index { $_ eq $first } @$list;
    my $s = first_index { $_ eq $second } @$list;
    return $f < $s;
}

my $graph = Schema->toposort_graph(Schema);
my @tables = $graph->toposort();

ok(
    $graph->has_edge('Artist', 'Album'),
    'Album depends on Artist',
);
ok(
    $graph->has_edge('Producer', 'Album'),
    'Album depends on Producer',
);
ok(
    is_before(\@tables, 'Artist', 'Album'),
    "Artist is before Album",
);
ok(
    is_before(\@tables, 'Producer', 'Album'),
    "Producer is before Album",
);

done_testing;
